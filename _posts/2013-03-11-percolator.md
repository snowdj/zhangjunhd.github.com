---
layout: post
title: "Percolator"
description: ""
category: tech
tags: [google, Bigtable, Percolator]
---
{% include JB/setup %}
paper review:[Large-scale Incremental Processing Using Distributed Transactions and Notiﬁcations](http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/zh-CN//pubs/archive/36726.pdf)

<!--break-->
##1 Introduction
Consider the task of building an index of the web that can be used to answer search queries. The indexing system starts by crawling every page on the web and processing them while maintaining a set of invariants on the index. 

This is a bulk-processing task that can be expressed as a series of MapReduce operations: one for clustering duplicates, one for link inversion, etc. It’s easy to maintain invariants since MapReduce limits the parallelism of the computation; all documents finish one processing step before starting the next. For example, when the indexing system is writing inverted links to the current highest-PageRank URL, we need not worry about its PageRank concurrently changing; a previous MapReduce step has already determined its PageRank.

Now, consider how to update that index after recrawling some small portion of the web. It’s not sufficient to run the MapReduces over just the new pages since, for example, there are links between the new pages and the rest of the web. The MapReduces must be run again over the entire repository, that is, over both the new pages and the old pages.

An ideal data processing system for the task of maintaining the web search index would be optimized for `incremental processing`.

##2 Design
Percolator provides two main abstractions for performing incremental processing at large scale: ACID transactions over a random-access repository and observers, a way to organize an incremental computation.

A Percolator system consists of three binaries that run on every machine in the cluster: a Percolator worker, a Bigtable tablet server, and a GFS chunkserver. All observers are linked into the Percolator worker, which scans the Bigtable for changed columns (“notifications”) and invokes the corresponding observers as a function call in the worker process. The observers perform transactions by sending read/write RPCs to Bigtable tablet servers, which in turn send read/write RPCs to GFS chunkservers. The system also depends on two small services: the timestamp oracle and the lightweight lock service. The timestamp oracle provides strictly increasing timestamps: a property required for correct operation of the snapshot isolation protocol. Workers use the lightweight lock service to make the search for dirty notifications more efficient.

![1](/assets/2013-03-11-percolator/1.png)

The design of Percolator was influenced by the requirement to run at massive scales and the lack of a requirement for extremely low latency. Relaxed latency requirements let us take, for example, a lazy approach to cleaning up locks left behind by transactions running on failed machines. This lazy, simple-to-implement approach potentially delays transaction commit by tens of seconds. This delay would not be acceptable in a DBMS running OLTP tasks, but it is tolerable in an incremental processing system building an index of the web. Percolator has no central location for transaction management; in particular, it lacks a global deadlock detector. This increases the latency of conflicting transactions but allows the system to scale to thousands of machines.

####2.1 Bigtable overview
The challenge, then, in implementing Percolator is providing the features that Bigtable does not: multirow transactions and the observer framework.

####2.2 Transactions
Percolator provides cross-row, cross-table transactions with ACID snapshot-isolation semantics.

Figure 2 shows a simplified version of clustering documents by a hash of their contents. In this example, if Commit() returns false, the transaction has conflicted (in this case, because two URLs with the same content hash were processed simultaneously) and should be retried after a backoff. Calls to Get() and Commit() are blocking; parallelism is achieved by running many transactions simultaneously in a thread pool.

    bool UpdateDocument(Document doc) {
      Transaction t(&cluster);
      t.Set(doc.url(), "contents", "document", doc.contents());
      int hash = Hash(doc.contents());
      
      // dups table maps hash → canonical URL
      string canonical;
      if (!t.Get(hash, "canonical-url", "dups", &canonical)) {
        // No canonical yet; write myself in
        t.Set(hash, "canonical-url", "dups", doc.url());
      } // else this document already exists, ignore new copy
      return t.Commit();
    }

Figure 2: Example usage of the Percolator API to perform basic checksum clustering and eliminate documents with the same content.

Percolator stores multiple versions of each data item using Bigtable’s timestamp dimension. Multiple versions are required to provide snapshot isolation, which presents each transaction with the appearance of reading from a stable snapshot at some timestamp. Writes appear in a different, later, timestamp. Snapshot isolation protects against write-write conflicts: if transactions A and B, running concurrently, write to the same cell, at most one will commit. Snapshot isolation does not provide serializability; in particular, transactions running under snapshot isolation are subject to write skew. The main advantage of snapshot isolation over a serializable protocol is more efficient reads. Because any timestamp represents a consistent snapshot, reading a cell requires only performing a Bigtable lookup at the given timestamp; acquiring locks is not necessary. Figure 3 illustrates the relationship between transactions under snapshot isolation.

![2](/assets/2013-03-11-percolator/2.png)

Figure 6 shows the pseudocode for Percolator transactions, and Figure 4 shows the layout of Percolator data and metadata during the execution of a transaction. These various metadata columns used by the system are described in Figure 5. 

![3-1](/assets/2013-03-11-percolator/3-1.png)

![3-2](/assets/2013-03-11-percolator/3-2.png)

Figure 4: This figure shows the Bigtable writes performed by a Percolator transaction that mutates two rows. The transaction transfers 7 dollars from Bob to Joe. Each Percolator column is stored as 3 Bigtable columns: data, write metadata, and lock metadata. Bigtable’s timestamp dimension is shown within each cell; 12: “data” indicates that “data” has been written at Bigtable timestamp 12. Newly written data is shown in boldface.

![4](/assets/2013-03-11-percolator/4.png)

    class Transaction {
      struct Write { Row row; Column col; string value; };
      vector<Write> writes ;
      int start ts ;
      
      Transaction() : start ts (oracle.GetTimestamp()) {}
      void Set(Write w) { writes .push back(w); }
      bool Get(Row row, Column c, string* value) {
        while (true) {
          bigtable::Txn T = bigtable::StartRowTransaction(row);
          // Check for locks that signal concurrent writes.
          if (T.Read(row, c+"lock", [0, start ts ])) {
            // There is a pending lock; try to clean it and wait
            BackoffAndMaybeCleanupLock(row, c);
            continue;
          }
          
          // Find the latest write below our start timestamp.
          latest write = T.Read(row, c+"write", [0, start ts ]);
          if (!latest write.found()) return false; // no data
          int data ts = latest write.start timestamp();
          *value = T.Read(row, c+"data", [data ts, data ts]);
          return true;
        }
      }
      
    // Prewrite tries to lock cell w, returning false in case of conflict.
      bool Prewrite(Write w, Write primary) {
        Column c = w.col;
        bigtable::Txn T = bigtable::StartRowTransaction(w.row);
        
        // Abort on writes after our start timestamp ...
        if (T.Read(w.row, c+"write", [start ts , ∞])) return false;
        // ... or locks at any timestamp.
        if (T.Read(w.row, c+"lock", [0, ∞])) return false;
        
        T.Write(w.row, c+"data", start ts , w.value);
        T.Write(w.row, c+"lock", start ts ,
          {primary.row, primary.col}); // The primary’s location.
        return T.Commit();
      }
      
      bool Commit() {
        Write primary = writes [0];
        vector<Write> secondaries(writes .begin()+1, writes .end());
        if (!Prewrite(primary, primary)) return false;
        for (Write w : secondaries)
          if (!Prewrite(w, primary)) return false;
          
        int commit ts = oracle .GetTimestamp();
        
        // Commit primary first.
        Write p = primary;
        bigtable::Txn T = bigtable::StartRowTransaction(p.row);
        if (!T.Read(p.row, p.col+"lock", [start ts , start ts ]))
          return false; // aborted while working
        T.Write(p.row, p.col+"write", commit ts,
          start ts ); // Pointer to data written at start ts .
        T.Erase(p.row, p.col+"lock", commit ts);
        if (!T.Commit()) return false; // commit point
        
        // Second phase: write out write records for secondary cells.
        for (Write w : secondaries) {
          bigtable::Write(w.row, w.col+"write", commit ts, start ts );
          bigtable::Erase(w.row, w.col+"lock", commit ts);
        }
        return true;
      }
    }  // class Transaction

Figure 6: Pseudocode for Percolator transaction protocol.

####2.3 Timestamps
The timestamp oracle is a server that hands out timestamps in strictly increasing order. Since every transaction requires contacting the timestamp oracle twice, this service must scale well.

####2.4 Notifications
Transactions let the user mutate the table while maintaining invariants, but users also need a way to trigger and run the transactions. In Percolator, the user writes code (“observers”) to be triggered by changes to the table, and we link all the observers into a binary running alongside every tablet server in the system. Each observer registers a function and a set of columns with Percolator, and Percolator invokes the function after data is written to one of those columns in any row.

Percolator applications are structured as a series of observers; each observer completes a task and creates more work for “downstream” observers by writing to the table.

To provide these semantics for notifications, each observed column has an accompanying “acknowledgment” column for each observer, containing the latest start timestamp at which the observer ran. When the observed column is written, Percolator starts a transaction to process the notification. The transaction reads the observed column and its corresponding acknowledgment column. If the observed column was written after its last acknowledgment, then we run the observer and set the acknowledgment column to our start timestamp. Otherwise, the observer has already been run, so we do not run it again. Note that if Percolator accidentally starts two transactions concurrently for a particular notification, they will both see the dirty notification and run the observer, but one will abort because they will conflict on the acknowledgment column. We promise that at most one observer will commit for each notification.

To implement notifications, Percolator needs to efficiently find dirty cells with observers that need to be run.

To identify dirty cells, Percolator maintains a special “notify” Bigtable column, containing an entry for each dirty cell. When a transaction writes an observed cell, it also sets the corresponding notify cell. The workers perform a distributed scan over the notify column to find dirty cells. After the observer is triggered and the transaction commits, we remove the notify cell. Since the notify column is just a Bigtable column, not a Percolator column, it has no transactional properties and serves only as a hint to the scanner to check the acknowledgment column to determine if the observer should be run.

To make this scan efficient, Percolator stores the notify column in a separate Bigtable locality group so that scanning over the column requires reading only the millions of dirty cells rather than the trillions of total data cells. Each Percolator worker dedicates several threads to the scan. For each thread, the worker chooses a portion of the table to scan by first picking a random Bigtable tablet, then picking a random key in the tablet, and finally scanning the table from that position. Since each worker is scanning a random region of the table, we worry about two workers running observers on the same row concurrently. While this behavior will not cause correctness problems due to the transactional nature of notifications, it is inefficient. To avoid this, each worker acquires a lock from a lightweight lock service before scanning the row. This lock server need not persist state since it is advisory and thus is very scalable.
