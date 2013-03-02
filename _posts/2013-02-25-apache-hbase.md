---
layout: post
title: "Apache HBase"
description : ""
category: tech
tags: [hadoop, HBase]
---
{% include JB/setup %}

##Apache Hadoop-Related Projects List

- [Ambari][1] : Deployment, configuration and monitoring, see [part1][10]
- [Flume][2]:Collection and import of log and event data, see [part1][10]
- [MapReduce][4]: Parallel computation on server clusters, see [part1][10]
- [HDFS][5] Distributed redundant filesystem for Hadoop, see [part1][10]
- [HBase][3]:Column-oriented database scaling to billions of rows
- [Zookeeper][6]:Configuration management and coordination, see [part3][11]

<!--break-->

##HBase
1. Data Model  
    HBase is a sparse, multi-dimensional, sorted map. All concepts are as below:
    * `Row` and `Column`(or `Column Qualifier` or `Column Key`)  
    ![Row and Column](/assets/2013-02-25-apache-hbase/rowkey-columnkey.png)
   
    * {row, column, timestamp} -> `cell`  
    ![cell](/assets/2013-02-25-apache-hbase/cell.png)
    
    * `Regin` and `Column Family`  
    ![regin and column family](/assets/2013-02-25-apache-hbase/regin-columnfamily.png)

    `Table` is made up of any number if regions. `Region` is specified by its startKey and endKey. For example:
      
        Empty table: (Table, NULL, NULL)
        Two-region table: (Table, NULL, “com.cloudera.www”) and (Table, “com.cloudera.www”, NULL)

    Tables are sorted by `Row` in lexicographical order. Table schema only defines its column families. Each family consists of any number of columns. Each column consists of any number of versions. Columns only exist when inserted, NULLs are free. Columns within a family are sorted and stored together.Everything except table names are byte[].

        (Table, Row, Family:Column, Timestamp) -> Value

2. Operators
    Operations are based on row keys.
   * Single-row operations:Put/Get/Scan
   * Multi-row operations:Scan/MultiPut
   * No built-in joins (use MapReduce)

3. Architecture  
    HBase uses HDFS (or similar) as its reliable storage layer(Handles checksums, replication, failover). Master manages cluster. RegionServer manage data. ZooKeeper is for bootstraps and coordinates cluster.  
    
    Writes are done in write-ahead log(`WAL`) first, then stored in memory and flushed to disk on regular intervals or based on size. Meanwhile small flushes are merged in the background to keep number of files small.
    
    Reads read memory stores first and then disk based files second.
   
    Deletes are handled with “tombstone” markers.

    Atomicity is on row level no matter how many columns.  
    ![api arch](/assets/2013-02-25-apache-hbase/arch.png)
    
    High level architecture  
    ![api arch2](/assets/2013-02-25-apache-hbase/high_arch.png)

    3.1 HLog  
    It append mutations to a single HLog per Region Server, co-mingling mutations for different region in the same physical log file. It avoids duplicating log reads by first sorting the WAL entries in order of the keys ⟨table, row name, log sequence number⟩. In the sorted output, all mutations for a particular region are contiguous and can therefore be read efficiently with one disk seek followed by a sequential read.     
    ![wal](/assets/2013-02-25-apache-hbase/wal.png)
    
    ![wal2](/assets/2013-02-25-apache-hbase/wal2.png)

    3.2 MemStore and HFile  
    After data is written to the WAL the RegionServer saves KeyValues in memory store. It flushs to disk based on size(default size is `64MB`) as `HFile`. It Uses `snapshot` mechanism to write flush to disk while still serving from it and accepting new data at the same time. HFile consists of six parts， as Data Block，Meta Block，File Info，Data Block Index，Meta Block Index and Trailer(Magic Number).  
    ![hfile](/assets/2013-02-25-apache-hbase/hfile.png)
    
    3.3 Compactions  
    There are two types of compactions, `Minor` and `Major` Compactions. Minor Compactions combine last “few” flushes and triggered by number of storage files. Major Compactions rewrite all storage files to drop deleted data and those values exceeding TTL and/or number of versions and triggered by time threshold.
    
    3.4 Block Cache  
    It Assign a large part of the JVM heap as block caches in the RegionServer process to optimize reads on subsequent columns and rows.
    
    3.5 Region Splits  
    Region Splits are triggered by configured maximum file size of any store file and run as asynchronous thread on RegionServer. Splits are fast and nearly instant as reference files are pointed to original region files and represent each half of the split. Also compactions take care of splitting original files into new region directories.
    
    3.6 Auto Sharding  
    Region is the unit of scalability in HBase. Regions are composed of sorted, contiguous range of rows. They are moved around for load balancing and failover. Moreover, they are splited automatically or manually to scale with growing data.  
    ![Sharding](/assets/2013-02-25-apache-hbase/region.png)
    
    3.7 Column Family  
    A table should use only a few column families as which caused many files that need to stay open per region plus class overhead per family. It is best used when logical separation between data and meta columns. Sorting per family can be used to convey application logic or access pattern.
    
    3.8 Storage Separation  
    Column Families allow for separation of data. It is used by Columnar Databases for fast analytical queries, but on column level only. It Allows different or no compression depending on the content type.  
    ![columnfamily](/assets/2013-02-25-apache-hbase/columnfamily.png)

[1]:http://incubator.apache.org/ambari/ "Apache Ambari"
[2]:http://flume.apache.org/ "Apache Flume"
[3]:http://hbase.apache.org/ "Apache Hbase"
[4]:http://wiki.apache.org/hadoop/MapReduce "Apache MapReduce"
[5]:http://hadoop.apache.org/docs/r1.1.1/hdfs_design.html "HDFS Architecture Guide"
[6]:http://zookeeper.apache.org/ "Apache Zookeeper"
[10]:http://zhangjunhd.github.com/2013/02/24/apache-related-projects/
[11]:http://zhangjunhd.github.com/2013/03/01/zookeeper/

