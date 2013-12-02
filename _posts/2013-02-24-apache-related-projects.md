---
layout: post
title: "Apache Hadoop-Related Projects Design Architecture"
description: ""
category: tech
tags: [Hadoop, Ambari, Flume, HDFS, MapReduce, message]
---
{% include JB/setup %}

##Apache Hadoop-Related Projects List

- [Ambari][1] : Deployment, configuration and monitoring
- [Flume][2]:Collection and import of log and event data
- [MapReduce][4]: Parallel computation on server clusters
- [HDFS][5] Distributed redundant filesystem for Hadoop
- [HBase][3]:Column-oriented database scaling to billions of rows, see [part2][21]
- [Zookeeper][6]:Configuration management and coordination, see [part3][22]
- [Pig][7]:High-level programming language for Hadoop computations, see [part4][23]
- [Hive][8]: Data warehouse with SQL-like access, see [part7][25]
- [Oozie][9]: Orchestration and workflow management, see [part6][24]
- [Sqoop][10]: Imports data from relational databases, see [part7][25]
- [HCatalog][11]: Schema and data type sharing over Pig, Hive and MapReduce, see [part8][26]
- [Whirr][12]: Cloud-agnostic deployment of clusters, see [part8][26]
- [Mahout][13]: Library of machine learning and data mining algorithms, see [part8][26]

<!--break-->

##Ambari
Apache Ambari is a web-based tool for provisioning, managing, and monitoring Apache Hadoop clusters.

1. High level architecture of Ambari  
![Ambari architecture](/assets/2013-02-24-apache-related-project/high_level_arch.png)

2. Design of Ambari Agent
![Ambari agent design](/assets/2013-02-24-apache-related-project/agent_arch.png)

3. Design of Ambari Server
![Ambari server design](/assets/2013-02-24-apache-related-project/server_arch.jpeg)

##Flume
Apache Flume is a distributed, reliable, and available system for efficiently collecting, aggregating and moving large amounts of log data from many different sources to a centralized data store.
 
An `Event` is a unit of data that flows through a Flume agent. A `Source` consumes `Event`s having a specific format, and those Events are delivered to the `Source` by an external source like a web server. When a `Source` receives an `Event`, it stores it into one or more `Channel`s. The `Channel` is a passive store that holds the `Event` until that `Event` is consumed by a `Sink`. A `Sink` is responsible for removing an `Event` from the `Channel` and putting it into an external repository like HDFS or forwarding it to the Source at the next hop of the flow. The `Source` and `Sink` within the given agent run asynchronously with the `Event`s staged in the `Channel`.

![Flume data flow model](http://flume.apache.org/_images/DevGuide_image00.png)

##MapReduce
1. Programming Model  
   The `Map` phase starts by reading a collection of values or key/value pairs from an input source. It then invokes a user-defined function, the `Mapper`, on each element, independently and in parallel.
			    
		     map (in_key, in_value) -> list(out_key, intermediate_value)
    The `Shuffle` phase takes the key/value pairs emitted by the Mappers and groups together all the key/value pairs with the same key. It then outputs each distinct key and a stream of all the value   - th that key to the next phase.  
    
    The `Reduce` phase takes the key-grouped data emitted by the Shuffle phase and invokes a user-defined function, the `Reducer`, on each distinct key-and-values group, independently and in parallel.  

		    reduce (out_key, list(intermediate_value)) -> list(out_value)
2. Execution
![Map reduce execution](http://research.google.com/archive/mapreduce-osdi04-slides/index-auto-0007-0001.gif)

3. Parallel Execution  
    A separate user-defined `Combiner` function can be specified to perform partial combining of values associated with a given key during the Map phase. Each Map worker will keep a cache of key/value pairs that have been emitted from the Mapper, and strive to combine locally as much as possible before sending the combined key/value pairs on to the Shuffle phase.  
    
    A user-defined `Sharder` function can be specified that selects which Reduce worker machine should receive the group for a given key. A user-defined Sharder can be used to aid in load balancing. It also can be used to sort the output keys into Reduce “buckets,” with all the keys of the ith Reduce worker being ordered before all the keys of the i + 1st Reduce worker. Since each Reduce worker processes keys in lexicographic order, this kind of Sharder can be used to produce sorted output.
![Map reduce parallel execution](http://research.google.com/archive/mapreduce-osdi04-slides/index-auto-0008-0001.gif)

##HDFS
1. NameNode and DataNodes  
    HDFS has a master/slave architecture. An HDFS cluster consists of a single `NameNode`, a master server that manages the file system namespace and regulates access to files by clients. In addition, there are a number of `DataNode`s, usually one per node in the cluster, which manage storage attached to the nodes that they run on. 
![HDFS arch](http://hadoop.apache.org/docs/r1.1.1/images/hdfsarchitecture.gif)

2. Data Replication  
    HDFS is designed to reliably store very large files across machines in a large cluster. It stores each file as a sequence of `block`s; all blocks in a file except the last block are the same size. The blocks of a file are replicated for fault tolerance.
![HDFS datanodes](http://hadoop.apache.org/docs/r1.1.1/images/hdfsdatanodes.gif)

    For the common case, when the replication factor is three, __HDFS’s placement policy is to put one replica on one node in the local rack, another on a node in a different (remote) rack, and the last on a different node in the same remote rack.__ This policy cuts the inter-rack write traffic which generally improves write performance. The chance of rack failure is far less than that of node failure; this policy does not impact data reliability and availability guarantees. However, it does reduce the aggregate network bandwidth used when reading data since a block is placed in only two unique racks rather than three. __With this policy, the replicas of a file do not evenly distribute across the racks. One third of replicas are on one node, two thirds of replicas are on one rack, and the other third are evenly distributed across the remaining racks.__ This policy improves write performance without compromising data reliability or read performance.

    To minimize global bandwidth consumption and read latency, HDFS tries to satisfy a read request from a replica that is closest to the reader.

    On startup, the NameNode enters a special state called `Safemode`. Replication of data blocks does not occur when the NameNode is in the Safemode state. The NameNode receives Heartbeat and Blockreport messages from the DataNodes. A Blockreport contains the list of data blocks that a DataNode is hosting. Each block has a specified minimum number of replicas. A block is considered safely replicated when the minimum number of replicas of that data block has checked in with the NameNode. After a configurable percentage of safely replicated data blocks checks in with the NameNode (plus an additional 30 seconds), the NameNode exits the Safemode state.

3. The Persistence of File System Metadata  
   The NameNode uses a transaction log called the `EditLog` to persistently record every change that occurs to file system metadata. The NameNode uses a file in its local host OS file system to store the EditLog.

   The entire file system namespace, including the mapping of blocks to files and file system properties, is stored in a file called the `FsImage`. The FsImage is stored as a file in the NameNode’s local file system too.

   When the NameNode starts up, it reads the FsImage and EditLog from disk, applies all the transactions from the EditLog to the in-memory representation of the FsImage, and flushes out this new version into a new FsImage on disk. It can then truncate the old EditLog because its transactions have been applied to the persistent FsImage. This process is called a `checkpoint`.


4. Robustness  
    4.1 Data Disk Failure, Heartbeats and Re-Replication  
    Each DataNode sends a `Heartbeat` message to the NameNode periodically. A network partition can cause a subset of DataNodes to lose connectivity with the NameNode. The NameNode detects this condition by the absence of a Heartbeat message. The NameNode marks DataNodes without recent Heartbeats as dead and does not forward any new IOrequests to them. Any data that was registered to a dead DataNode is not available to HDFS any more. DataNode death may cause the replication factor of some blocks to fall below their specified value. The NameNode constantly tracks which blocks need to be replicated and initiates replication whenever necessary. The necessity for `re-replication` may arise __due to many reasons__: a DataNode may become unavailable, a replica may become corrupted, a hard disk on a DataNode may fail, or the replication factor of a file may be increased.  
    
    4.2 Cluster Rebalancing  
    The HDFS architecture is compatible with data `rebalancing` schemes. A scheme might automatically move data from one DataNode to another if the free space on a DataNode falls below a certain threshold.

    4.3 Data Integrity  
    When a client creates an HDFS file, it computes a `checksum` __of each block__ of the file and stores these checksums in a separate hidden file in the same HDFS namespace. When a client retrieves file contents it verifies that the data it received from each DataNode matches the checksum stored in the associated checksum file. If not, then the client can opt to retrieve that block from another DataNode that has a replica of that block.

    4.4 Metadata Disk Failure  
    NameNode can be configured to support maintaining multiple copies of the FsImage and EditLog. Any update to either the FsImage or EditLog causes each of the FsImages and EditLogs to get updated __synchronously__.

    4.5 Snapshots  
    Snapshots support storing a copy of data at a particular instant of time. One usage of the snapshot feature may be to roll back a corrupted HDFS instance to a previously known good point in time.

5. Data Organization  
    5.1 Data Blocks  
    A typical block size used by HDFS is __64 MB__.  
    
    5.2 Staging  
    HDFS client caches the file data into a temporary local file. Application writes are transparently redirected to this temporary local file. When the local file accumulates data worth over one HDFS block size, the client contacts the NameNode. The NameNode inserts the file name into the file system hierarchy and allocates a data block for it. The NameNode responds to the client request with the identity of the DataNode and the destination data block. Then the client flushes the block of data from the local temporary file to the specified DataNode. When a file is closed, the remaining un-flushed data in the temporary local file is transferred to the DataNode. The client then tells the NameNode that the file is closed. At this point, the NameNode commits the file creation operation into a persistent store. If the NameNode dies before the file is closed, the file is lost.

    5.3 Replication Pipelining  
    When the local file accumulates a full block of user data, the client retrieves a list of DataNodes from the NameNode. This list contains the DataNodes that will host a replica of that block. The client then flushes the data block to the first DataNode. The first DataNode starts receiving the data in small `portions` __(4 KB)__, writes each portion to its local repository and transfers that portion to the second DataNode in the list. The second DataNode, in turn starts receiving each portion of the data block, writes that portion to its repository and then flushes that portion to the third DataNode. Finally, the third DataNode writes the data to its local repository. Thus, a DataNode can be receiving data from the previous one in the pipeline and at the same time forwarding data to the next one in the pipeline. Thus, the data is pipelined from one DataNode to the next.

6. Space Reclamation  
    6.1 File Deletes and Undeletes  
    When a file is deleted by a user or an application, it is not immediately removed from HDFS. Instead, HDFS first renames it to a file in the `/trash` directory. The file can be restored quickly as long as it remains in /trash. A file remains in /trash for a configurable amount of time. After the expiry of its life in /trash, the NameNode deletes the file from the HDFS namespace. The deletion of a file causes the blocks associated with the file to be freed.

    6.2 Decrease Replication Factor  
    When the replication factor of a file is reduced, the NameNode selects excess replicas that can be deleted. The next Heartbeat transfers this information to the DataNode. The DataNode then removes the corresponding blocks and the corresponding free space appears in the cluster.


[1]:http://incubator.apache.org/ambari/ "Apache Ambari"
[2]:http://flume.apache.org/ "Apache Flume"
[3]:http://hbase.apache.org/ "Apache Hbase"
[4]:http://wiki.apache.org/hadoop/MapReduce "Apache MapReduce"
[5]:http://hadoop.apache.org/docs/r1.1.1/hdfs_desig5.html "HDFS Architecture Guide"
[6]:http://zookeeper.apache.org/ "Apache Zookeeper"
[7]:http://pig.apache.org/ "Apache Pig"
[8]:http://hive.apache.org/ "Apache Hive"
[9]:http://oozie.apache.org/ "Apache Oozie"
[10]:http://sqoop.apache.org/ "Apache Sqoop"
[11]:http://incubator.apache.org/hcatalog/ "Apache Hcatalog"
[12]:http://whirr.apache.org/ "Apache whirr"
[13]:http://mahout.apache.org/ "Apache Mahout"

[20]:http://zhangjunhd.github.com/2013/02/24/apache-related-projects/
[21]:http://zhangjunhd.github.com/2013/02/25/apache-hbase/
[22]:http://zhangjunhd.github.com/2013/03/01/zookeeper/
[23]:http://zhangjunhd.github.com/2013/03/03/pig/
[24]:http://zhangjunhd.github.com/2013/03/04/oozie/
[25]:http://zhangjunhd.github.com/2013/03/04/hive/
[26]:http://zhangjunhd.github.com/2013/03/06/apache-related-projects2/