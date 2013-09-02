---
layout: post
title: "Megastore"
description: ""
category: tech
tags: [megastore, paper, google, bigtable]
---
{% include JB/setup %}
paper review:[Megastore: Providing Scalable, Highly Available Storage for Interactive Services](http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/zh-CN//pubs/archive/36971.pdf)

<!--break-->
##2. TOWARD AVAILABILITY AND SCALE
In contrast to our need for a storage platform that is global, reliable, and arbitrarily large in scale, our hardware building blocks are geographically confined, failure-prone, and suffer limited capacity. We must bind these components into a unified ensemble offering greater throughput and reliability.

To do so, we have taken a two-pronged approach:

* for availability, we implemented a synchronous, fault-tolerant log replicator optimized for long distance-links；
* for scale, we partitioned data into a vast space of small databases, each with its own replicated log stored in a per-replica NoSQL datastore.

####2.1 Replication
#####2.1.1 Strategies
We evaluated common strategies for wide-area replication:

**Asynchronous Master/Slave** A master node replicates write-ahead log entries to at least one slave. Log appends are acknowledged at the master in parallel with transmission to slaves. The master can support fast ACID transactions but risks downtime or data loss during failover to a slave. A consensus protocol is required to mediate mastership.

**Synchronous Master/Slave** A master waits for changes to be mirrored to slaves before acknowledging them, allowing failover without data loss. Master and slave failures need timely detection by an external system.

**Optimistic Replication** Any member of a homogeneous replica group can accept mutations, which are asynchronously propagated through the group. Availability and latency are excellent. However, the global mutation ordering is not known at commit time, so transactions are impossible.

####2.1.2 Enter Paxos
We decided to use Paxos, a proven, optimal, fault-tolerant consensus algorithm with no requirement for a distinguished master. We replicate a write-ahead log over a group of symmetric peers. Any node can initiate reads and writes. Each log append blocks on acknowledgments from a majority of replicas, and replicas in the minority catch up as they are able—the algorithm’s inherent fault tolerance eliminates the need for a distinguished “failed” state. 

Even with fault tolerance from Paxos, there are limitations to using a single log. With replicas spread over a wide area, communication latencies limit overall throughput. Moreover, progress is impeded when no replica is current or a majority fail to acknowledge writes. In a traditional SQL database hosting thousands or millions of users, using a synchronously replicated log would risk interruptions of widespread impact. So to improve availability and throughput we use multiple replicated logs, each governing its own partition of the data set.

####2.2 Partitioning and Locality
#####2.2.1 Entity Groups
To scale throughput and localize outages, we partition our data into a collection of `entity groups`, each independently and synchronously replicated over a wide area. The underlying data is stored in a scalable NoSQL datastore in each datacenter (see Figure 1).

Entities within an entity group are mutated with single-phase ACID transactions (for which the commit record is replicated via Paxos). Operations across entity groups could rely on expensive two-phase commits, but typically leverage Megastore’s efficient asynchronous messaging. A transaction in a sending entity group places one or more messages in a queue; transactions in receiving entity groups atomically consume those messages and apply ensuing mutations.

Note that we use asynchronous messaging between logically distant entity groups, not physically distant replicas. All network traffic between datacenters is from replicated operations, which are synchronous and consistent.

Indexes local to an entity group obey ACID semantics; those across entity groups have looser consistency. See Figure 2 for the various operations on and between entity groups.

![1](/assets/2013-05-02-megastore/1.png)

####2.2.2 Selecting Entity Group Boundaries
The entity group defines the a priori grouping of data for fast operations. Boundaries that are too fine-grained force excessive cross-group operations, but placing too much unrelated data in a single group serializes unrelated writes, which degrades throughput.

####2.2.3 Physical Layout
We use Google’s Bigtable for scalable fault-tolerant storage within a single datacenter, allowing us to support arbitrary read and write throughput by spreading operations across multiple rows.

We minimize latency and maximize throughput by letting applications control the placement of data: through the selection of Bigtable instances and specification of locality within an instance.

To minimize latency, applications try to keep data near users and replicas near each other. They assign each entity group to the region or continent from which it is accessed most. Within that region they assign a triplet or quintuplet of replicas to datacenters with isolated failure domains.

For low latency, cache efficiency, and throughput, the data for an entity group are held in contiguous ranges of Bigtable rows. Our schema language lets applications control the placement of hierarchical data, storing data that is accessed together in nearby rows or denormalized into the same row.

##3. A TOUR OF MEGASTORE
####3.1 API Design Philosophy

####3.2 Data Model
Megastore tables are either `entity group root` tables or `child` tables. Each child table must declare a single distinguished foreign key referencing a root table, illustrated by the ENTITY GROUP KEY annotation in Figure 3.

    CREATE SCHEMA PhotoApp;
    
    CREATE TABLE User {
      required int64 user_id;
      required string name;
    } PRIMARY KEY(user_id), ENTITY GROUP ROOT;
    
    CREATE TABLE Photo {
      required int64 user_id;
      required int32 photo_id;
      required int64 time;
      required string full_url;
      optional string thumbnail_url;
      repeated string tag;
    } PRIMARY KEY(user_id, photo_id),
      IN TABLE User,
      ENTITY GROUP KEY(user_id) REFERENCES User;
    
    CREATE LOCAL INDEX PhotosByTime ON Photo(user_id, time);
    
    CREATE GLOBAL INDEX PhotosByTag ON Photo(tag) STORING (thumbnail_url);
Figure 3: Sample Schema for Photo Sharing Service

#####3.2.1 Pre-Joining with Keys
Note how the Photo and User tables in Figure 3 share a common user id key prefix. The IN TABLE User directive instructs Megastore to colocate these two tables into the same Bigtable, and the key ordering ensures that Photo entities are stored adjacent to the corresponding User. This mechanism can be applied recursively to speed queries along arbitrary join depths. Thus, users can force hierarchical layout by manipulating the key order.

#####3.2.2 Indexes
Secondary indexes can be declared on any list of entity properties, as well as fields within protocol buffers. We distinguish between two high-level classes of indexes: local and global (see Figure 2). A `local index` is treated as separate indexes for each entity group. It is used to find data within an entity group. In Figure 3, PhotosByTime is an example of a local index. The index entries are stored in the entity group and are updated atomically and consistently with the primary entity data.

A `global index` spans entity groups. It is used to find entities without knowing in advance the entity groups that contain them. The PhotosByTag index in Figure 3 is global and enables discovery of photos marked with a given tag, regardless of owner. Global index scans can read data owned by many entity groups but are not guaranteed to reflect all recent updates.

Megastore offers additional indexing features:

**Storing Clause.** Accessing entity data through indexes is normally a two-step process: first the index is read to find matching primary keys, then these keys are used to fetch entities. We provide a way to denormalize portions of entity data directly into index entries. By adding the STORING clause to an index, applications can store additional properties from the primary table for faster access at read time. For example, the PhotosByTag index stores the photo thumbnail URL for faster retrieval without the need for an additional lookup.

**Repeated Indexes.** Megastore provides the ability to index repeated properties and protocol buffer sub-fields. Repeated indexes are a efficient alternative to child tables. PhotosByTag is a repeated index: each unique entry in the tag property causes one index entry to be created on behalf of the Photo.

**Inline Indexes.** Inline indexes provide a way to denormalize data from source entities into a related target entity: index entries from the source entities appear as a virtual repeated column in the target entry. An inline index can be created on any table that has a foreign key referencing another table by using the first primary key of the target entity as the first components of the index, and physically locating the data in the same Bigtable as the target.

Inline indexes are useful for extracting slices of information from child entities and storing the data in the parent for fast access. Coupled with repeated indexes, they can also be used to implement many-to-many relationships more efficiently than by maintaining a many-to-many link table.

The PhotosByTime index could have been implemented as an inline index into the parent User table. This would make the data accessible as a normal index or as a virtual repeated property on User, with a time-ordered entry for each contained Photo.

#####3.2.3 Mapping to Bigtable

![2](/assets/2013-05-02-megastore/2.png)

Within the Bigtable row for a root entity, we store the transaction and replication metadata for the entity group, including the transaction log. Storing all metadata in a single Bigtable row allows us to update it atomically through a single Bigtable transaction.

Each index entry is represented as a single Bigtable row; the row key of the cell is constructed using the indexed property values concatenated with the primary key of the indexed entity. For example, the PhotosByTime index row keys would be the tuple (user id, time, primary key) for each photo. Indexing repeated fields produces one index entry per repeated element. For example, the primary key for a photo with three tags would appear in the PhotosByTag index thrice.

####3.3 Transactions and Concurrency Control
Each Megastore entity group functions as a mini-database that provides serializable ACID semantics. A transaction writes its mutations into the entity group’s write-ahead log, then the mutations are applied to the data.

Bigtable provides the ability to store multiple values in the same row/column pair with different timestamps. We use this feature to implement multiversion concurrency control (MVCC): when mutations within a transaction are applied, the values are written at the timestamp of their transaction. Readers use the timestamp of the last fully applied transaction to avoid seeing partial updates. Readers and writers don’t block each other, and reads are isolated from writes for the duration of a transaction.

Megastore provides `current`, `snapshot`, and `inconsistent` reads. Current and snapshot reads are always done within the scope of a single entity group. When starting a current read, the transaction system first ensures that all previously committed writes are applied; then the application reads at the timestamp of the latest committed transaction. For a snapshot read, the system picks up the timestamp of the last known fully applied transaction and reads from there, even if some committed transactions have not yet been applied. Megastore also provides inconsistent reads, which ignore the state of the log and read the latest values directly. This is useful for operations that have more aggressive latency requirements and can tolerate stale or partially applied data.

A write transaction always begins with a current read to determine the next available log position. The commit operation gathers mutations into a log entry, assigns it a timestamp higher than any previous one, and appends it to the log using Paxos. The protocol uses optimistic concurrency: though multiple writers might be attempting to write to the same log position, only one will win. The rest will notice the victorious write, abort, and retry their operations. Advisory locking is available to reduce the effects of contention. Batching writes through session affinity to a particular frontend server can avoid contention altogether.

The complete transaction lifecycle is as follows:

1. **Read**: Obtain the timestamp and log position of the last committed transaction.
2. **Application logic**: Read from Bigtable and gather writes into a log entry.
3. **Commit**: Use Paxos to achieve consensus for appending that entry to the log.
4. **Apply**: Write mutations to the entities and indexes in Bigtable.
5. **Clean up**: Delete data that is no longer required.

#####3.3.1 Queues
Queues provide transactional messaging between entity groups. They can be used for cross-group operations, to batch multiple updates into a single transaction, or to defer work.

#####3.3.2 Two-Phase Commit
Megastore supports two-phase commit for atomic updates across entity groups. Since these transactions have much higher latency and increase the risk of contention, we generally discourage applications from using the feature in favor of queues.

##4. REPLICATION
####4.1 Overview
Megastore’s replication system provides a single, consistent view of the data stored in its underlying replicas. Reads and writes can be initiated from any replica, and ACID semantics are preserved regardless of what replica a client starts from. Replication is done per entity group by synchronously replicating the group’s transaction log to a quorum of replicas. Writes typically require one round of interdatacenter communication, and healthy-case reads run locally. Current reads have the following guarantees:

* A read always observes the last-acknowledged write.
* After a write has been observed, all future reads observe that write. (A write might be observed before it is acknowledged.)

####4.4 Megastore’s Approach
####4.4.1 Fast Reads
We set an early requirement that current reads should usually execute on any replica without inter-replica RPCs. Since writes usually succeed on all replicas, it was realistic to allow local reads everywhere. These `local reads` give us better utilization, low latencies in all regions, fine-grained read failover, and a simpler programming experience.

We designed a service called the `Coordinator`, with servers in each replica’s datacenter. A coordinator server tracks a set of entity groups for which its replica has observed all Paxos writes. For entity groups in that set, the replica has sufficient state to serve local reads.

####4.4.2 Fast Writes
To achieve fast single-roundtrip writes, Megastore adapts the pre-preparing optimization used by master-based approaches. In a master-based system, each successful write includes an implied prepare message granting the master the right to issue accept messages for the next log position. If the write succeeds, the prepares are honored, and the next write skips directly to the accept phase. Megastore does not use dedicated masters, but instead uses `leaders`.

We run an independent instance of the Paxos algorithm for each log position. The leader for each log position is a distinguished replica chosen alongside the preceding log position’s consensus value. The leader arbitrates which value may use proposal number zero. The first writer to submit a value to the leader wins the right to ask all replicas to accept that value as proposal number zero. All other writers must fall back on two-phase Paxos.

Since a writer must communicate with the leader before submitting the value to other replicas, we minimize writer-leader latency. We designed our policy for selecting the next write’s leader around the observation that most applications submit writes from the same region repeatedly. This leads to a simple but effective heuristic: use the closest replica.

####4.4.3 Replica Types
So far all replicas have been `full` replicas, meaning they contain all the entity and index data and are able to service current reads. We also support the notion of a `witness` replica. Witnesses vote in Paxos rounds and store the write-ahead log, but do not apply the log and do not store entity data or indexes, so they have lower storage costs. They are effectively tie breakers and are used when there are not enough full replicas to form a quorum. Because they do not have a coordinator, they do not force an additional roundtrip when they fail to acknowledge a write.

`Read-only` replicas are the inverse of witnesses: they are non-voting replicas that contain full snapshots of the data. Reads at these replicas reflect a consistent view of some point in the recent past. For reads that can tolerate this staleness, read-only replicas help disseminate data over a wide geographic area without impacting write latency.

##4.5 Architecture

![3](/assets/2013-05-02-megastore/3.png)

Each application server has a designated `local replica`. The client library makes Paxos operations on that replica durable by submitting transactions directly to the local Bigtable. To minimize wide-area roundtrips, the library submits remote Paxos operations to stateless intermediary `replication servers` communicating with their local Bigtables.

Client, network, or Bigtable failures may leave a write abandoned in an indeterminate state. Replication servers periodically scan for incomplete writes and propose no-op values via Paxos to bring them to completion.

##4.6 Data Structures and Algorithms
####4.6.1 Replicated Logs
Each replica stores mutations and metadata for the log entries known to the group. To ensure that a replica can participate in a write quorum even as it recovers from previous outages, we permit replicas to accept out-of-order proposals. We store log entries as independent cells in Bigtable.

We refer to a log replica as having “holes” when it contains an incomplete prefix of the log. Figure 6 demonstrates this scenario with some representative log replicas for a single Megastore entity group. Log positions 0-99 have been fully scavenged and position 100 is partially scavenged, because each replica has been informed that the other replicas will never request a copy. Log position 101 was accepted by all replicas. Log position 102 found a bare quorum in A and C. Position 103 is noteworthy for having been accepted by A and C, leaving B with a hole at 103. A conflicting write attempt has occurred at position 104 on replica A and B preventing consensus.

![4](/assets/2013-05-02-megastore/4.png)

####4.6.2 Reads
In preparation for a current read (as well as before a write), at least one replica must be brought up to date: all mutations previously committed to the log must be copied to and applied on that replica. We call this process `catchup`.
Omitting some deadline management, the algorithm for a current read (shown in Figure 7) is as follows:

![5](/assets/2013-05-02-megastore/5.png)

1. **Query Local**: Query the local replica’s coordinator to determine if the entity group is up-to-date locally.
2. **Find Position**: Determine the highest possibly-committed log position, and select a replica that has applied through that log position.

   1. (Local read) If step 1 indicates that the local replica is up-to-date, read the highest accepted log position and timestamp from the local replica.
   2. (Majority read) If the local replica is not up-to-date (or if step 1 or step 2a times out), read from a majority of replicas to find the maximum log position that any replica has seen, and pick a replica to read from. We select the most responsive or up-to-date replica, not always the local replica.

3. **Catchup**: As soon as a replica is selected, catch it up to the maximum known log position as follows:

   1. For each log position in which the selected replica does not know the consensus value, read the value from another replica. For any log positions without a known-committed value available, invoke Paxos to propose a no-op write. Paxos will drive a majority of replicas to converge on a single value—either the no-op or a previously proposed write.
   2. Sequentially apply the consensus value of all unapplied log positions to advance the replica’s state to the distributed consensus state.
   3. In the event of failure, retry on another replica.

4. **Validate**: If the local replica was selected and was not previously up-to-date, send the coordinator a validate message asserting that the (entity group,replica) pair reflects all committed writes. Do not wait for a reply— if the request fails, the next read will retry.
5. **Query Data**: Read the selected replica using the timestamp of the selected log position. If the selected replica becomes unavailable, pick an alternate replica, perform catchup, and read from it instead. The results of a single large query may be assembled transparently from multiple replicas.

Note that in practice 1 and 2.1 are executed in parallel.

####4.6.3 Writes
Having completed the read algorithm, Megastore observes the next unused log position, the timestamp of the last write, and the next leader replica. At commit time all pending changes to the state are packaged and proposed, with a timestamp and next leader nominee, as the consensus value for the next log position. If this value wins the distributed consensus, it is applied to the state at all full replicas; otherwise the entire transaction is aborted and must be retried from the beginning of the read phase.

As described above, coordinators keep track of the entity groups that are up-to-date in their replica. If a write is not accepted on a replica, we must remove the entity group’s key from that replica’s coordinator. This process is called `invalidation`. Before a write is considered committed and ready to apply, all full replicas must have accepted or had their coordinator invalidated for that entity group.

The write algorithm (shown in Figure 8) is as follows:

![6](/assets/2013-05-02-megastore/6.png)

1. **Accept Leader**: Ask the leader to accept the value as proposal number zero. If successful, skip to step 3.
2. **Prepare**: Run the Paxos Prepare phase at all replicas with a higher proposal number than any seen so far at this log position. Replace the value being written withthe highest-numbered proposal discovered, if any.
3. **Accept**: Ask remaining replicas to accept the value. If this fails on a majority of replicas, return to step 2 after a randomized backoff.
4. **Invalidate**: Invalidate the coordinator at all full replicas that did not accept the value. Fault handling at this step is described in Section 4.7 below.
5. **Apply**: Apply the value’s mutations at as many replicas as possible. If the chosen value differs from that originally proposed, return a conflict error.

Step 1 implements the “fast writes” of Section 4.4.2. Writers using single-phase Paxos skip Prepare messages by sending an Accept command at proposal number zero. The next leader replica selected at log position n arbitrates the value used for proposal zero at n + 1. Since multiple proposers may submit values with proposal number zero, serializing at this replica ensures only one value corresponds with that proposal number for a particular log position.

In a traditional database system, the `commit point` (when the change is durable) is the same as the `visibility point` (when reads can see a change and when a writer can be no- tified of success). In our write algorithm, the commit point is after step 3 when the write has won the Paxos round, but the visibility point is after step 4. Only after all full replicas have accepted or had their coordinators invalidated can the write be acknowledged and the changes applied. Acknowledging before step 4 could violate our consistency guarantees: a current read at a replica whose invalidation was skipped might fail to observe the acknowledged write.

##4.7 Coordinator Availability
####4.7.1 Failure Detection
We use Google’s Chubby lock service: coordinators obtain specific Chubby locks in remote datacenters at startup. To process requests, a coordinator must hold a majority of its locks. If it ever loses a majority of its locks from a crash or network partition, it will revert its state to a conservative default, considering all entity groups in its purview to be out-of-date. Subsequent reads at the replica must query the log position from a majority of replicas until the locks are regained and its coordinator entries are revalidated.

Writers are insulated from coordinator failure by testing whether a coordinator has lost its locks: in that scenario, a writer knows that the coordinator will consider itself invalidated upon regaining them.

This algorithm risks a brief (tens of seconds) write outage when a datacenter containing live coordinators suddenly becomes unavailable—all writers must wait for the coordinator’s Chubby locks to expire before writes can complete (much like waiting for a master failover to trigger). Unlike after a master failover, reads and writes can proceed smoothly while the coordinator’s state is reconstructed. This brief and rare outage risk is more than justified by the steady state of fast local reads it allows.

The coordinator liveness protocol is vulnerable to asymmetric network partitions. If a coordinator can maintain the leases on its Chubby locks, but has otherwise lost contact with proposers, then affected entity groups will experience a write outage. In this scenario an operator performs a manual step to disable the partially isolated coordinator. We have faced this condition only a handful of times.

####4.7.2 Validation Races
In addition to availability issues, protocols for reading and writing to the coordinator must contend with a variety of race conditions. Invalidate messages are always safe, but validate messages must be handled with care. Races between validates for earlier writes and invalidates for later writes are protected in the coordinator by always sending the log position associated with the action. Higher numbered in- validates always trump lower numbered validates. There are also races associated with a crash between an invalidate by a writer at position n and a validate at some position m < n. We detect crashes using a unique epoch number for each incarnation of the coordinator: validates are only allowed to modify the coordinator state if the epoch remains unchanged since the most recent read of the coordinator.













