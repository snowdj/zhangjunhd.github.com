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
    
    Writes are done in write-ahead log(WAL) first, then stored in memory and flushed to disk on regular intervals or based on size. Meanwhile small flushes are merged in the background to keep number of files small.
    
    Reads read memory stores first and then disk based files second.
   
    Deletes are handled with “tombstone” markers.

    Atomicity is on row level no matter how many columns.  
    ![api arch](/assets/2013-02-25-apache-hbase/arch.png)

    __3.1 Write Ahead Log(WAL)__

    3.2 MemStore
    
    3.3 Compactions
    
    3.4 Block Cache
    
    3.5 Region Splits
    
    3.6 Auto Sharding
    
    3.7 Column Family
    
    3.8 Storage Separation 

 

[1]:http://incubator.apache.org/ambari/ "Apache Ambari"
[2]:http://flume.apache.org/ "Apache Flume"
[3]:http://hbase.apache.org/ "Apache Hbase"
[4]:http://wiki.apache.org/hadoop/MapReduce "Apache MapReduce"
[5]:http://hadoop.apache.org/docs/r1.1.1/hdfs_design.html "HDFS Architecture Guide"
[10]:http://zhangjunhd.github.com/2013/02/24/apache-related-projects/

