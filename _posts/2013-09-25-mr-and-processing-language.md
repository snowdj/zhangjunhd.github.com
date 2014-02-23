---
layout: post
title: "MapReduce数据处理模型"
description: "1.google mapreduce论文；2.mapreduce-merge增加一个merge阶段极其如何实现sql；3.mapreduce online，中间文件不落地，直接push给reducer"
category: 云计算
tags: [MapReduce]
---
{% include JB/setup %}

###1 [MapReduce: Simplified Data Processing on Large Clusters][1]
####1.1 Programming Model
* `Map`, written by the user, takes an input pair and produces a set of intermediate key/value pairs. 
* The `Reduce` function, also written by the user, accepts an intermediate key I and a set of values for that key. It merges together these values to form a possibly smaller set of values. The intermediate values are supplied to the user’s reduce function via an iterator.

####1.2 Implementation
* Execution Overview
    * The Map invocations are distributed across multiple machines by automatically partitioning the input data into a set of `M splits`.
    * Reduce invocations are distributed by partitioning the intermediate key space into `R pieces` using a partitioning function (e.g., hash(key) mod R).

![1](/assets/2013-09-25-mr-and-processing-language/mr.png)

* Master Data Structures
    * For each map task and reduce task, it stores the state (idle, in-progress, or completed), and the identity of the worker machine (for non-idle tasks).
    * For each completed map task, the master stores the locations and sizes of the R intermediate file regions produced by the map task. Updates to this location and size information are received as map tasks are completed. The information is pushed incrementally to workers that have in-progress reduce tasks.
* Fault Tolerance
    * Worker Failure
        * The master pings every worker periodically. If no response is received from a worker in a certain amount of time, the master marks the worker as failed.
        * Any map tasks completed by the worker are reset back to their initial idle state.
        * Any map task or reduce task in progress on a failed worker is also reset to idle and becomes eligible for rescheduling.
        * Completed map tasks are re-executed on a failure because their output is stored on the local disk(s) of the failed machine and is therefore inaccessible. Completed reduce tasks do not need to be re-executed since their output is stored in a global file system.
        * When a map task is executed first by worker A and then later executed by worker B (because A failed), all workers executing reduce tasks are notified of the re-execution. Any reduce task that has not already read the data from worker A will read the data from worker B.
    * Master Failure:Current implementation aborts the MapReduce computation if the master fails. Clients can check for this condition and retry the MapReduce operation if they desire.
    * Semantics in the Presence of Failures
        * When the user-supplied map and reduce operators are `deterministic` functions of their input values, our distributed implementation produces the same output as would have been produced by a non-faulting sequential execution of the entire program.
        * We rely on atomic commits of map and reduce task outputs to achieve this property.
* Locality:most input data is read locally and consumes no network bandwidth.
* Task Granularity
    * The master must make O(M + R) scheduling decisions and keeps O(M ∗ R) state in memory as described above.
    * R is often constrained by users because the output of each reduce task ends up in a separate output file.
* Backup Tasks:When a MapReduce operation is close to completion, the master schedules backup executions of the remaining in-progress tasks. The task is marked as completed whenever either the primary or the backup execution completes.

####1.3 Refinements
* Partitioning Function
    * A default partitioning function is provided that uses hashing (e.g. “hash(key) mod R”). This tends to result in fairly well-balanced partitions.
    * The user of the MapReduce library can provide a special partitioning function.
* Ordering Guarantees
    * We guarantee that within a given partition, the intermediate key/value pairs are processed in increasing key order. 
    * Which is useful when the output file format needs to support efficient random access lookups by key, or users of the output find it convenient to have the data sorted.
* Combiner Function：We allow the user to specify an optional Combiner function that does partial merging of this data before it is sent over the network.
* Input and Output Types：The MapReduce library provides support for reading input data in several different formats.
* Side-effects：In some cases, users of MapReduce have found it convenient to produce auxiliary files as additional outputs from their map and/or reduce operators.
* Skipping Bad Records：If the user code generates a signal,the signal handler sends a “last gasp” UDP packet that contains the sequence number to the MapReduce master. When the master has seen more than one failure on a particular record, it indicates that the record should be skipped when it issues the next re-execution of the corresponding Map or Reduce task.
* Local Execution：To help facilitate debugging, profiling, and small-scale testing, we have developed an alternative implementation of the MapReduce library that sequentially executes all of the work for a MapReduce operation on the local machine.
* Status Information：The master runs an internal HTTP server and exports a set of status pages for human consumption. 
* Counters：The MapReduce library provides a counter facility to count occurrences of various events.

###2 [Map-Reduce-Merge: Simplified Relational Data Processing on Large Clusters][2]

The Map-Reduce-Merge model enables processing multiple heterogeneous datasets. The signatures of the Map-Reduce-Merge primitives are listed below, where α, β, γ represent dataset lineages, k means keys, and v stands for value entities.

    map: (k1, v1)α → [(k2, v2)]α
    reduce: (k2,[v2])α → (k2,[v3])α
    merge: ((k2,[v3])α,(k3,[v4])β) → [(k4,v5)]γ

![mrm1](/assets/2013-09-25-mr-and-processing-language/mrm1.png)

In this new model, the map function transforms an input key/value pair (k1,v1) into a list of intermediate key/value pairs [(k2 , v2 )]. The reduce function aggregates the list of values [v2] associated with k2 and produces a list of values [v3], which is also associated with k2. Note that inputs and outputs of both functions belong to the same lineage, say α. Another pair of map and reduce functions produce the intermediate output (k3,[v4]) from another lineage, say β. Based on keys k2 and k3, the merge function combines the two reduced outputs from different lineages into a list of key/value outputs [(k4,v5)]. This final output becomes a new lineage, say γ. If α = β, then this merge function does a `self-merge`, similar to self-join in relational algebra.

####2.1 Implementation
* A call to a map function (`mapper`) processes a key/value pair, and a call to a reduce function (`reducer`) processes a key-grouped value collection, a `merger` processes two pairs of key/values, that each comes from a distinguishable source.
* At the Merge phase, users might want to apply different data-processing logic on data based on their sources. An example is the build and probe phases of a `hash join`[J注1], where build programming logic is applied on one table then probe the other. To accommodate this pattern, a `processor` is a user-defined function that processes data from one source only. Users can define two processors in Merge.

![mrm2](/assets/2013-09-25-mr-and-processing-language/mrm2.png)

* After map and reduce tasks are about done, a Map-Reduce-Merge coordinator launches mergers on a cluster of nodes (see Fig. 2). When a merger starts up, it is assigned with a merger number. Using this number, a user-definable module called `partition selector` can determine from which reducers this merger retrieves its input data. Mappers and reducers are also assigned with a number. For mappers, this number represents the input file split. For reducers, this number represents an input bucket, in which mappers partition and store their output data to. For Map-Reduce users, these numbers are simply system implementation detail, but in Map-Reduce-Merge, users utilize these numbers to associate input/output between mergers and reducers in partition selectors.
* A merger reads data from two sources, so it can be viewed as having two logical iterators. These iterators usually move forward as their mapper/reducer counterparts, but their relative movement against each others can be instrumented to implement a user-defined merge algorithm. Our Map-Reduce-Merge framework provides a user-configurable module (`iterator-manager`) that it is called for the information that controls the movement of these `configurable iterators`.

![mrm3](/assets/2013-09-25-mr-and-processing-language/mrm3.png)

* `Partition Selector` In a merger, a user-defined partition selector function determines which data partitions produced by up-stream reducers should be retrieved then merged. This function is given the current merger’s number and two collections of reducer numbers, one for each data source. Users define logic in the selector to remove unrelated reducers from the collections. Only the data from the reducers left in the collections will be read and merged in the merger.
* `Processors` A processor is the place where users can define logic of processing data from an individual source. Processors can be defined if the hash join algorithm is implemented in Merge, where the first processor builds a hash table on the first source, and the second probes it while iterating through the second data source.
* `Merger` In the merge function, users can implement data processing logic on data merged from two sources where this data satisfies a merge condition.
* `Configurable Iterators` As indicated, by manipulating relative iteration of a merger’s two logical iterators, users can implement different merge algorithms.For algorithms like nested-loop joins, iterators are configured to move as looping variables in a nested loop. For algorithms like sort-merge joins, iterators take turns when iterating over two sorted collections of records. For hash-join-like algorithms, these two iterators scan over their data in separate passes. The first scans its data and builds a hash table, then the second scans its data and probes the already built hash table.

####2.2 APPLICATIONS TO RELATIONAL DATA PROCESSING
In our implementation, the Map-Reduce-Merge model assumes that a dataset is mapped into a relation R with an attribute set (schema) A. In map, reduce, and merge functions, users choose attributes from A to form two subsets: K and V . K represents the schema of the “key” part of a Map-Reduce-Merge record and V the “value” part. For each tuple t of R, this implies that t is concatenated by two field sets: k and v,where K is the schema of k and V is the schema of v.

* `Projection` For each tuple t = (k,v) of the input relation, users can define a mapper to transform it into a projected output tuple t′ = (k′,v′), where k′ and v′ are typed by schema K′ and V ′, respectively. K′ and V ′ are subsets of A. Namely, using mappers only can implement relational algebra’s projection operator.
* `Aggregation` At the Reduce phase, Map-Reduce (as well as Map-Reduce-Merge) performs the sort-by-key and group-by-key functions to ensure that the input to a reducer is a set of tuples t = (k, [v]) in which [v] is the collection of all the values associated with the key k. A reducer can call aggregate functions on this grouped value list. Namely, reducers can easily implement the “group by” clause and “aggregate” operators in SQL.
* `Generalized Selection` Mappers, reducers, and mergers can all act as filters and implement the selection operator. If a selection condition is on attributes of one data source, then it can be implemented in mappers. If a selection condition is on aggregates or a group of values from one data source, then it can be implemented in reducers. If a selection condition involves attributes or aggregates from more than one sources, then it can be implemented in mergers. Straightforward filtering conditions that involve only one relation in a SQL query’s “where” and “having” clauses can be implemented using mappers and reducers, respectively. Mergers can implement complicated filtering conditions involving more than one relations, however, this filtering can only be accomplished after join (or Cartesian product) operations are properly configured and executed.
* `Joins` § 1.3 describes in detail how joins can be implemented using mergers with the help from mappers and reducers.
* `Set Union` Assume the union operation (as well as other set operations described below) is performed over two relations. In Map-Reduce-Merge, each relation will be processed by Map-Reduce, and the sorted and grouped outputs of the reducers will be given to a merger. In each reducer, duplicated tuples from the same source can be skipped easily. The mappers for the two sources should share the same range partitioner, so that a merger can receive records within the same key range from the two reducers. The merger can then iterate on each input simultaneously and produce only one tuple if two input tuples from different sources are duplicates. Non-duplicated tuples are produced by this merger as well.
* `Set Intersection` First, partitioned and sorted MapReduce outputs are sent to mergers as described in the last item. A merger can then iterate on each input simultaneously and produce tuples that are shared by the two reducer outputs.
* `Cartesian Product` In a Map-Reduce-Merge task, the two reducer sets will produce two sets of reduced partitions. A merger is configured to receive one partition from the first reducer (F) and the complete set of partitions from the second one (S). This merger can then form a nested loop to merge records in the sole F partition with the ones in every S partition.
* `Rename` It is trivial to emulate Rename in Map-Reduce-Merge, since map, reduce, and merge functions can select, rearrange, compare, and process attributes based on their indexes in the “key” and “value” subsets.

####2.3 Map-Reduce-Merge Implementations of Relational Join Algorithms
* `Sort-Merge Join` Instead of using a `hash partitioner`, users can configure the framework to use a `range partitioner` in mappers.
    * Map: Use a range partitioner in mappers, so that records are partitioned into ordered buckets, each is over a mutually exclusive key range and is designated to one reducer.
    * Reduce: For each Map-Reduce lineage, a reducer reads the designated buckets from all the mappers. Data in these buckets are then merged into a sorted set. This sorting procedure can be done completely at the reducer side, if necessary, through an external sort. Or, mappers can sort data in each buckets before sending them to reducers. Reducers can then just do the merge part of the `merge sort` using a priority queue.
    * Merge: A merger reads from two sets of reducer outputs that cover the same key range. Since these reducer outputs are sorted already, this merger simply does the merge part of the `sort-merge join`.
* `Hash Join` One important issue in distributed computing and parallel databases is to keep workload and storage balanced among nodes. One strategy is to disseminate records to nodes based on their hash values. Another approach is to run a preprocessing Map-Reduce task to scan the whole dataset and build a data density. Here we show how to implement `hash join` using the Map-Reduce-Merge framework:
    * Map: Use a common hash partitioner in both mappers, so that records are partitioned into hashed buckets, each is designated to one reducer.
    * Reduce: For each Map-Reduce lineage, a reducer reads from every mapper for one designated partition. Using the same hash function from the partitioner, records from these partitions can be grouped and aggregated using a hash table, requires maintaining a hashtable either in memory or disk.
    * Merge: A merger reads from two sets of reducer outputs that share the same hashing buckets. One is used as a `build` set and the other `probe`. After the partitioning and grouping are done by mappers and reducers, the build set can be quite small, so these sets can be hash-joined in memory. Notice that, the number of reduce/merge sets must be set to an optimally large number in order to support an in-memory hash join, otherwise, an external hash join is required.
* `Block Nested-Loop Join` The Map-Reduce-Merge implementation of the `block nested-loop` join algorithm is very similar to the one for the hash join. Instead of doing an in-memory hash, a nested loop is implemented. The partitioning and grouping done by mappers and reducers concentrate the join sets, so this parallel nested-loop join can enjoy a high selectivity in each merger.

####2.4 OPTIMIZATIONS
1. Optimal Reduce-Merge Connections
    * For mergers, because data is already partitioned and even sorted after Map and Reduce phases, they do not need to connect to every reducer in order to get their data. The selector function in mergers can choose pertinent reduced partitions for merging.
    * If one input dataset is much larger than the other, then it would be inefficient to partition both datasets into the same number of reducers. One can choose different numbers for RA and RB, but the selection logic is more complicated.
    * Selector logic can also be quite complicated in the case of θ-join.
    * Before feeding data from selected reducer partitions to a user-defined merger function, these tuples can be compared and see if they should be merged or not. In short, this comparison can be done in a user-defined `matcher` that is simply a fine-grained selector.
2. Combining Phases
    * `ReduceMap, MergeMap`: Reducer and merger outputs are usually fed into a down-stream mapper for a subsequent join operation. These outputs can simply be sent directly to a co-located mapper in the same process without storing them in secondary storage first.
    * `ReduceMerge`: A merger usually takes two sets of reducer partitions. This merger can be combined with one of the reducers and gets its output directly while remotely reads data from the other set of reducers.
    * `ReduceMergeMap`: An straightforward combination of ReduceMerge and MergeMap becomes ReduceMergeMap.
    * Another way of reducing disk accesses is to replace disk read-writes with network read-writes.

###3 [MapReduce Online][4]
####3.1 Background
1. Programming Model
    * To use MapReduce, the programmer expresses their desired computation as a series of `jobs`. The input to a job is a list of `records` (key-value pairs). Each job consists of two steps:
        * First, a user-defined `map` function is applied to each record to produce a list of intermediate key-value pairs.
        * Second, a user-defined `reduce` function is called once for each distinct key in the map output, and passed the list of intermediate values associated with that key.
        * Optionally, the user can supply a `combiner` function. A combiner emits an output value that summarizes the input values it was passed.
2. Hadoop Architecture
    * The master, called the `JobTracker`, is responsible for accepting jobs from clients, dividing those jobs into tasks, and assigning those tasks to be executed by worker nodes.
    * Each worker runs a `TaskTracker` process that manages the execution of the tasks currently assigned to that node.
    * A `heartbeat` protocol between each TaskTracker and the JobTracker is used to update the JobTracker’s bookkeeping of the state of running tasks, and drive the scheduling of new tasks: if the JobTracker identifies free TaskTracker slots, it will schedule further tasks on the TaskTracker.
3. Map Task Execution
    * Each map task is assigned a portion of the input file called a `split`. The execution of a map task is divided into two phases.
        * The `map` phase reads the task’s split from HDFS, parses it into records (key/value pairs), and applies the map function to each record.
        * After the map function has been applied to each input record, the `commit` phase registers the final output with the TaskTracker, which then informs the JobTracker that the task has finished executing.
4. Reduce Task Execution
    * The execution of a reduce task is divided into three phases.
        * The `shuffle` phase fetches the reduce task’s input data. Each reduce task is assigned a partition of the key range produced by the map step, so the reduce task must fetch the content of this partition from every map task’s output.
        * The `sort` phase groups records with the same key together.
        * The `reduce` phase applies the user-defined reduce function to each key and corresponding list of values.

####3.2 Pipelined MapReduce

![mr-online](/assets/2013-09-25-mr-and-processing-language/mr_1.png)

1. Pipelining Within A Job
    * Reduce tasks traditionally issue HTTP requests to `pull` their output from each TaskTracker. To support pipelining, we modified the map task to instead `push` data to reducers as it is produced.
    * Na ̈ıve Pipelining
        * Each reduce task contacts every map task upon initiation of the job, and opens a socket which will be used to pipeline the output of the map function. As each map output record is produced, the mapper determines which partition (reduce task) the record should be sent to, and immediately sends it via the appropriate socket.
        * A reduce task accepts the pipelined data it receives from each map task and stores it an in-memory buffer, spilling sorted runs of the buffer to disk as needed. Once the reduce task learns that every map task has completed, it performs a final merge of all its sorted runs and applies the user-defined reduce function as normal, writing the output to HDFS.
    * Refinements
        * Problems:
            * First, it is possible that there will not be enough slots available to schedule every task in a new job.
            * Opening a socket between every map and reduce task also requires a large number of TCP connections.
        * Solutions:
            * If a reduce task has not yet been scheduled, any map tasks that produce records for that partition simply write them to disk. Once the reduce task is assigned a slot, it can then fetch the records from the map task, as in stock Hadoop.
            * To reduce the number of concurrent TCP connections, each reducer can be configured to pipeline data from a bounded number of mappers at once; the reducer will pull data from the remaining map tasks in the traditional Hadoop manner.
    * Granularity of Map Output
        * Problems:
            * Combiners allow “map-side preaggregation”: By eagerly pipelining each record as it is produced, there is no opportunity for the map task to apply a combiner function.
            * Eager pipelining moves some of the sorting work from the mapper to the reducer: In the na ̈ıve pipelining design, map tasks send output records in the order in which they are generated, so the reducer must perform a full external sort.
        * Solutions:
            * Instead of sending the buffer contents to reducers directly, we instead wait for the buffer to grow to a threshold size. The mapper then applies the combiner function, sorts the output by partition and reduce key.
            * A second thread monitors the spill files, and sends them to the pipelined reducers. This has the effect of `adaptively` moving load from the reducer to the mapper or vice versa, depending on which node is the current bottleneck.

2. Pipelining Between Jobs
    * In our modified version of Hadoop, the reduce tasks of one job can optionally pipeline their output directly to the map tasks of the next job, sidestepping the need for expensive fault-tolerant storage in HDFS for what amounts to a temporary file.

3. Fault Tolerance
    * To simplify fault tolerance, the reducer treats the output of a pipelined map task as “tentative” until the JobTracker informs the reducer that the map task has committed successfully.
    * The reducer can merge together spill files generated by the same uncommitted mapper, but won’t combine those spill files with the output of other map tasks until it has been notified that the map task has committed.
    * Envision introducing a “checkpoint” concept: as a map task runs, it will periodically notify the JobTracker that it has reached offset x in its input split. The JobTracker will notify any connected reducers; map task output that was produced before offset x can then be merged by reducers with other map task output as normal.
    * To avoid duplicate results, if the map task fails, the new map task attempt resumes reading its input at offset x. This technique also has the benefit of reducing the amount of redundant work done after a map task failure.

####3.3 Online Aggregation
1. Single-Job Online Aggregation:We can support online aggregation by simply applying the reduce function to the data that a reduce task has received so far. We call the output of such an intermediate reduce operation a `snapshot`. Applications can consume snapshots by polling HDFS in a predictable location.
2. Multi-Job Online Aggregation:Suppose that j1 and j2 are two MapReduce jobs, and j2 consumes the output of j1. When j1’s reducers compute a snapshot to perform online aggregation, that snapshot is written to HDFS, and also sent directly to the map tasks of j2. The map and reduce steps for j2 are then computed as normal, to produce a snapshot of j2’s output. This process can then be continued to support online aggregation for an arbitrarily long sequence of jobs.

####3.4 Continuous Queries
1. Continuous MapReduce Jobs
    * We added an optional “flush” API that allows map functions to force their current output to reduce tasks. When a reduce task is unable to accept such data, the mapper framework stores it locally and sends it at a later time.
    * To support continuous reduce tasks, the user-defined reduce function must be periodically invoked on the map output available at that reducer. Applications will have different requirements for how frequently the reduce function should be invoked: possible choices include periods based on wall-clock time, logical time (e.g. the value of a field in the map task output), and the number of input rows delivered to the reducer.
2. Prototype Monitoring System
    * Our monitoring system is composed of `agents` that run on each monitored machine and record statistics of interest (e.g. load average, I/O operations per second, etc.).
    * Each agent is implemented as a continuous map task: rather than reading from HDFS, the map task instead reads from various continuous system-local data streams (e.g. /proc).
    * Each agent forwards statistics to an `aggregator` that is implemented as a continuous reduce task.

----

###J注
1. [Join的三种方式][3]
    * `Hash join`是将一个表（通常是小一点的那个表）做hash运算，将列数据存储到hash列表中，从另一个表中抽取记录，做hash运算，到hash列表中找到相应的值，做匹配。
    * `Nested loops`是从一张表中读取数据，访问另一张表（通常是索引）来做匹配，nested loops适用的场合是当一个关联表比较小的时候，效率会更高。
    * `Merge Join`是先将关联表的关联列各自做排序，然后从各自的排序表中抽取数据，到另一个排序表中做匹配，因为merge join需要做更多的排序，所以消耗的资源更多。通常来讲，能够使用merge join的地方，hash join都可以发挥更好的性能。


[1]: http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/zh-CN//archive/mapreduce-osdi04.pdf
[2]: http://www.cs.duke.edu/courses/cps399.28/current/papers/sigmod07-YangDasdanEtAl-map_reduce_merge.pdf
[3]: http://blog.csdn.net/tianlesoftware/article/details/5826546
[4]: http://www.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-136.pdf
