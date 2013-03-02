---
layout: post
title: "Apache Zookeeper"
description: ""
category: tech
tags: [zookeeper, zab]
---
{% include JB/setup %}

- [Ambari][1] : Deployment, configuration and monitoring, see [part1][10]
- [Flume][2]:Collection and import of log and event data, see [part1][10]
- [MapReduce][4]: Parallel computation on server clusters, see [part1][10]
- [HDFS][5] Distributed redundant filesystem for Hadoop, see [part1][10]
- [HBase][3]:Column-oriented database scaling to billions of rows, see [part2][11]
- [Zookeeper][6]:Configuration management and coordination

<!--break-->

#1 The ZooKeeper service

##1.1 Terminology
we use `client` to denote a user of the ZooKeeper service, `server` to denote a process providing the ZooKeeper service, and `znode` to denote an in-memory data node in the ZooKeeper data, which is organized in a hierarchical namespace referred to as the `data tree`.

##1.2 Service overview
To refer to a given znode, we use the standard UNIX notation for file system paths. For example, we use /A/B/C to denote the path to znode C, where C has B as its parent and B has A as its parent. All znodes store data, and all znodes, except for ephemeral znodes, can have children.  
![znode](/assets/2013-03-01-zookeeper/node.png)

There are two types of znodes that a client can create:

* `Regular`: Clients manipulate regular znodes by creating and deleting them explicitly;
* `Ephemeral`: Clients create such znodes, and they either delete them explicitly, or let the system remove them automatically when the session that creates them terminates (deliberately or due to a failure).

Additionally, when creating a new znode, a client can set a `sequential flag`. Nodes created with the sequential flag set have the value of a monotonically increasing counter appended to its name. If n is the new znode and p is the parent znode, then the sequence value of n is never smaller than the value in the name of any other sequential znode ever created under p.

ZooKeeper implements `watche`s to allow clients to receive timely notifications of changes without requiring polling.

When a client issues a read operation with a watch flag set, the operation completes as normal except that the server promises to notify the client when the information returned has changed.

Watches are one-time triggers associated with a session; they are unregistered once triggered or the session closes.

__Data model__  
The data model of ZooKeeper is essentially a file system with a simplified API and only full data reads and writes.

Unlike files in file systems, znodes are not designed for general data storage. Instead, znodes map to abstractions of the client application, typically corresponding to meta-data used for coordination purposes.

__Sessions__  
A client connects to ZooKeeper and initiates a session. Sessions have an associated timeout. ZooKeeper considers a client faulty if it does not receive anything from its session for more than that timeout. A session ends when clients explicitly close a session handle or ZooKeeper detects that a clients is faulty.  
![session](/assets/2013-03-01-zookeeper/session.png)

##1.3 Client API

* create(znode, data, flags)
   * Flags(`REGULAR`, `EPHEMERAL`, `SEQUENTIAL`) denote the type of the znode
* delete(znode, version)
* exists(znode, watch)
* getData(znode, watch)
* setData(znode, data, version)
* getChildren(znode, watch)
* sync()
   * Waits for all updates pending at the start of the operation to be propagated to the Zookeeper server that the client is connected to

##1.4 ZooKeeper guarantees

ZooKeeper has two basic ordering guarantees:

* __Linearizable writes__: all requests that update the state of ZooKeeper are serializable and respect precedence;
* __FIFO client order__: all requests from a given client are executed in the order that they were sent by the client.

In ZooKeeper, writes are linearizable, but reads might not be.  To boost performance, Zookeeper has local reads. A server serving a read request might not have been a part of a write quorum of some previous operation， so a read might return a stale value.  
![read1](/assets/2013-03-01-zookeeper/read1.png)

![read2](/assets/2013-03-01-zookeeper/read2.png)

To guarantee that a given read operation returns the latest updated value, a client calls `sync` followed by the read operation.

The FIFO order guarantee of client operations together with the global guarantee of sync enables the result of the read operation to reflect any changes that happened before the sync was issued.

##1.5 Examples of primitives

__Configuration Management__  
In its simplest form configuration is stored in a znode, zc. Processes start up with the full pathname of zc. Starting processes obtain their configuration by reading zc with the watch flag set to true. If the configuration in zc is ever updated, the processes are notified and read the new configuration, again setting the watch flag to true.

__Rendezvous__  
We handle this scenario with ZooKeeper using a rendezvous znode, zr, which is an node created by the client. The client passes the full pathname of zr as a startup parameter of the master and worker processes. When the master starts it fills in zr with information about addresses and ports it is using. When workers start, they read zr with watch set to true. If zr has not been filled in yet, the worker waits to be notified_when zr is updated. If zr is an ephemeral node, master and worker processes can watch for zr to be deleted and clean themselves up when the client ends.

__Group Membership__  
Specifically, we use the fact that ephemeral nodes allow us to see the state of the session that created the node. We start by designating a znode, zg to represent the group. When a process member of the group starts, it creates an ephemeral child znode under zg. If each process has a unique name or identifier, then that name is used as the name of the child znode; otherwise, the process creates the znode with the SEQUENTIAL flag to obtain a unique name assignment.

After the child znode is created under zg the process starts normally. It does not need to do anything else. If the process fails or ends, the znode that represents it under zg is automatically removed.

Processes can obtain group information by simply listing the children of zg. If a process wants to monitor changes in group membership, the process can set the watch flag to true and refresh the group information (always setting the watch flag to true) when change notifications are received.

__Simple Locks__  
The simplest lock implementation uses “lock files”. The lock is represented by a znode. To acquire a lock, a client tries to create the designated znode with the EPHEMERAL flag. If the create succeeds, the client holds the lock. Otherwise, the client can read the znode with the watch flag set to be notified if the current leader dies. A client releases the lock when it dies or explicitly deletes the znode. Other clients that are waiting for a lock try again to acquire a lock once they observe the znode being deleted.

While this simple locking protocol works, it does have some problems. 

* First, it suffers from the herd effect. If there are many clients waiting to acquire a lock, they will all vie for the lock when it is released even though only one client can acquire the lock. 
* Second, it only implements exclusive locking.

__Simple Locks without Herd Effect__  
We define a lock znode l to implement such locks. Intuitively we line up all the clients requesting the lock and each client obtains the lock in order of request arrival.

    Lock
    1 n = create(l + “/lock-”, EPHEMERAL|SEQUENTIAL) 
    2 C = getChildren(l, false)
    3 if n is lowest znode in C, exit
    4 p = znode in C ordered just before n
    5 if exists(p, true) wait for watch event 6 goto 2

    Unlock
    1 delete(n)

__Read/Write Locks__  
To implement read/write locks we change the lock procedure slightly and have separate read lock and write lock procedures. The unlock procedure is the same as the global lock case.

    Write Lock
    1 n = create(l + “/write-”, EPHEMERAL|SEQUENTIAL) 
    2 C = getChildren(l, false)
    3 if n is lowest znode in C, exit
    4 p = znode in C ordered just before n
    5 if exists(p, true) wait for event 6 goto 2

    Read Lock
    1 n = create(l + “/read-”, EPHEMERAL|SEQUENTIAL)
    2 C = getChildren(l, false)
    3 if no write znodes lower than n in C, exit
    4 p = write znode in C ordered just before n
    5 if exists(p, true) wait for event
    6 goto 3

__Double Barrier__  
Double barriers enable clients to synchronize the beginning and the end of a computation. When enough processes, defined by the barrier threshold, have joined the barrier, processes start their computation and leave the barrier once they have finished.

We represent a barrier in ZooKeeper with a znode, referred to as b. Every process p registers with b – by creating a znode as a child of b – on entry, and unregisters – removes the child – when it is ready to leave. Processes can enter the barrier when the number of child znodes of b exceeds the barrier threshold. Processes can leave the barrier when all of the processes have removed their children. We use watches to efficiently wait for enter and exit conditions to be satisfied. To enter, processes watch for the existence of a ready child of b that will be created by the process that causes the number of children to exceed the barrier threshold. To leave, processes watch for a particular child to disappear and only check the exit condition once that znode has been removed.

#2 ZooKeeper Implementation  
![zk2](/assets/2013-03-01-zookeeper/zk2.jpeg)

Every ZooKeeper server services clients. Clients connect to exactly one server to submit its requests. Read requests are serviced from the local replica of each server database. Requests that change the state of the service, write requests, are processed by an agreement protocol.  
![zk](/assets/2013-03-01-zookeeper/zk.png)

__Atomic Broadcast__  
All requests that update ZooKeeper state are forwarded to the leader. The leader executes the request and broadcasts the change to the ZooKeeper state through [Zab][20], an atomic broadcast protocol. The server that receives the client request responds to the client when it delivers the corresponding state change.

__Replicated Database__  
Each replica has a copy in memory of the ZooKeeper state. When a ZooKeeper server recovers from a crash, it needs to recover this internal state. Replaying all delivered messages to recover state would take prohibitively long after running the server for a while, so ZooKeeper uses periodic snapshots and only requires redelivery of messages since the start of the snapshot. We call ZooKeeper snapshots `fuzzy snapshots` since we do not lock the ZooKeeper state to take the snapshot; instead, we do a depth first scan of the tree atomically reading each znode’s data and meta-data and writing them to disk. Since the resulting fuzzy snapshot may have applied some subset of the state changes delivered during the generation of the snapshot, the result may not correspond to the state of ZooKeeper at any point in time. However, since state changes are `idempotent`, we can apply them twice as long as we apply the state changes in order.

__Request processor__  
Upon receiving a write request, the leader calculates in what state system will be after the write is applied. It transforms the operation in the transactional update. Such transactional updates are then processed by ZAB, DB. It guarantees idempotency of updates to the DB originating from the same operation. Idempotency is important not only since ZAB may redeliver a message upon recovery not during normal operation but also allows more efficient DB snapshots.

__Client-Server Interactions__  
When a server processes a write request, it also sends out and clears notifications relative to any watch that corresponds to that update. Servers process writes in order and do not process other writes or reads concurrently. This ensures strict succession of notifications. Note that servers handle notifications locally. Only the server that a client is connected to tracks and triggers notifications for that client.  
![write](/assets/2013-03-01-zookeeper/write.png)

Read requests are handled locally at each server.  
![read](/assets/2013-03-01-zookeeper/read.png)

To detect client session failures, ZooKeeper uses timeouts. The leader determines that there has been a failure if no other server receives anything from a client session within the session timeout. If the client sends requests frequently enough, then there is no need to send any other message. Otherwise, the client sends heartbeat messages during periods of low activity. If the client cannot communicate with a server to send a request or heartbeat, it connects to a different ZooKeeper server to re-establish its session. To prevent the session from timing out, the ZooKeeper client library sends a heartbeat after the session has been idle for s/3 ms and switch to a new server if it has not heard from a server for 2s/3 ms, where s is the session timeout in milliseconds.

[1]:http://incubator.apache.org/ambari/ "Apache Ambari"
[2]:http://flume.apache.org/ "Apache Flume"
[3]:http://hbase.apache.org/ "Apache Hbase"
[4]:http://wiki.apache.org/hadoop/MapReduce "Apache MapReduce"
[5]:http://hadoop.apache.org/docs/r1.1.1/hdfs_design.html "HDFS Architecture Guide"
[6]:http://zookeeper.apache.org/ "Apache Zookeeper"
[10]:http://zhangjunhd.github.com/2013/02/24/apache-related-projects/
[11]:http://zhangjunhd.github.com/2013/02/25/apache-hbase/
[20]:http://zhangjunhd.github.com/2013/02/28/zab/
