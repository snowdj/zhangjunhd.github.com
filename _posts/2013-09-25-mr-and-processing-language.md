---
layout: post
title: "MapReduce数据处理模型"
description: ""
category: 云计算
tags: [MapReduce, Pig, Scope, Dryad, LINQ, Sawzall]
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







####23 [SCOPE: Easy and Efficient Parallel Processing of Massive Data Sets][4]

#####23.1 PLATFORM OVERVIEW

![2](/assets/2013-09-25-mr-and-processing-language/scope1.png)

An application is modeled as a dataflow graph: a directed acyclic graph (DAG) with vertices representing processes and edges representing data flows. The runtime component of the execution engine is called the `Job Manager`. The JM is the central and coordinating process for all processing vertices within an application. The primary function of the JM is to construct the runtime DAG from the compile time representation of a DAG and execute over it. The JM schedules a DAG vertex onto the system processing nodes when all the inputs are ready, monitors progress, and, on failure, re-executes part of the DAG.

`Dryad` implements a job manager and a graph building language for composing vertices of computation and edges of communication channels between the vertices.

#####23.2 SCOPE Scripting Language

The SCOPE scripting language resembles SQL but with C# expressions.

* Input and Output
* Select and Join
* Expressions and Functions
* User-Defined Operators
  * Process
  * Reduce
  * Combine
  * Importing Scripts

#####23.3 SCOPE Execution

* SCOPE Compilation
  * The result of the compilation is an internal parse tree. SCOPE has an option to translate the parsed tree directly to a physical execution plan using default plans for each command.
  * A physical execution plan is, in essence, a specification of Cosmos job.
* SCOPE Optimization
  * The SCOPE optimizer is a transformation-based optimizer based on the `Cascades` framework. 
* Runtime Optimization

####24 [DryadLINQ: A System for General-Purpose Distributed Data-Parallel Computing Using a High-Level Language][5]

#####24.1 DryadLINQ Execution Overview

![3](/assets/2013-09-25-mr-and-processing-language/DryadLINQ1.png)

* Step 1. A .NET user application runs. It creates a DryadLINQ expression object. Because of LINQ’s `deferred evaluation`, the actual execution of the expression has not occurred.
* Step 2. The application calls `ToDryadTable` triggering a data-parallel execution. The expression object is handed to DryadLINQ.
* Step 3. DryadLINQ compiles the LINQ expression into a distributed Dryad execution plan. It performs: 
  * (a) the decomposition of the expression into subexpressions, each to be run in a separate Dryad vertex; 
  * (b) the generation of code and static data for the remote Dryad vertices;
  * (c) the generation of serialization code for the required data types.
* Step 4. DryadLINQ invokes a custom, DryadLINQ-specific, Dryad job manager. The job manager may be executed behind a cluster firewall.
* Step 5. The job manager creates the job graph using the plan created in Step 3. It schedules and spawns the vertices as resources become available.
* Step 6. Each Dryad vertex executes a vertex-specific program (created in Step 3b).
* Step 7. When the Dryad job completes successfully it writes the data to the output table(s).
* Step 8. The job manager process terminates, and it returns control back to DryadLINQ. DryadLINQ creates the local DryadTable objects encapsulating the outputs of the execution. These objects may be used as inputs to subsequent expressions in the user program. Data objects within a DryadTable output are fetched to the local context only if explicitly dereferenced.
* Step 9. Control returns to the user application. The iterator interface over a DryadTable allows the user to read its contents as .NET objects.
* Step 10. The application may generate subsequent DryadLINQ expressions, to be executed by a repetition of Steps 2–9.

#####24.2 LINQ

The base type for a LINQ collection is `IEnumerable<T>`. From a programmer’s perspective, this is an abstract dataset of objects of type T that is accessed using an iterator interface. LINQ also defines the `IQueryable<T>` interface which is a subtype of `IEnumerable<T>` and represents an (unevaluated) expression constructed by combining LINQ datasets using LINQ operators. We need make only two observations about these types: (a) in general the programmer neither knows nor cares what concrete type implements any given dataset’s IEnumerable interface; and (b) DryadLINQ composes all LINQ expressions into IQueryable objects and defers evaluation until the result is needed, at which point the expression graph within the IQueryable is optimized and executed in its entirety on the cluster. Any IQueryable object can be used as an argument to multiple operators, allowing efficient re-use of common subexpressions.

#####24.3 DryadLINQ Constructs

The inputs and outputs of a DryadLINQ computation are represented by objects of type `DryadTable<T>`, which is a subtype of `IQueryable<T>`.

The inputs and outputs of a DryadLINQ computation are specified using the `GetTable<T>` and `ToDryadTable<T>` operators.

DryadLINQ offers two data re-partitioning operators: `HashPartition<T,K>` and `RangePartition<T,K>`. These operators are needed to enforce a partitioning on an output dataset and they may also be used to override the optimizer’s choice of execution plan.

The remaining new operators are `Apply` and `Fork`, which can be thought of as an “escape-hatch” that a programmer can use when a computation is needed that cannot be expressed using any of LINQ’s built-in operators. `Apply` takes a function f and passes to it an iterator over the entire input collection, allowing arbitrary streaming computations. The `Fork` operator is very similar to Apply except that it takes a single input and generates multiple output datasets. This is useful as a performance optimization to eliminate common subcomputations, e.g.

#####24.4 DryadLINQ Optimizations

* Static Optimizations
  * Pipelining
  * Removing redundancy
  * Eager Aggregation
  * I/O reduction
* Dynamic Optimizations
* Optimizations for OrderBy
* Execution Plan for MapReduce

####25 [Dryad: Distributed Data-Parallel Programs from Sequential Building Blocks][6]

#####25.1 SYSTEM OVERVIEW

![dryad1](/assets/2013-09-25-mr-and-processing-language/dryad1.png)

#####25.2 DESCRIBING A DRYAD GRAPH

![dryad2](/assets/2013-09-25-mr-and-processing-language/dryad2.png)

![dryad3](/assets/2013-09-25-mr-and-processing-language/dryad3.png)


This is a [research prototype][7] of the Dryad and DryadLINQ data-parallel processing frameworks running on Hadoop YARN.

####26 [MapReduce Online][8]

![mr-online](/assets/2013-09-25-mr-and-processing-language/mr_1.png)

####27 [Interpreting the Data: Parallel Analysis with Sawzall][9]

#####27.1 Sawzall Language Overview

    i: int;      # a simple integer declaration
    i: int = 0;  # a declaration with an initial value
    
    f: float;
    s: string = "1.234";
    f = float(s);
    
    string(1234, 16);
    string(utf8_bytes, "UTF-8");
    
    b: bytes = "Hello, world!\n";
    b: bytes = bytes("Hello, world!\n", "UTF-8");
    
    input: bytes = next_record_from_input();
    
    proto "some_record.proto" # define ’Record’
    r: Record = input;         # convert input to Record

#####27.2 Aggregators

* Collection:

        c: table collection of string;
* Sample:

        s: table sample(100) of string;
* Sum:

        s: table sum of { count: int, revenue: float };
* Maximum:

        m: table maximum(10) of string weight length: int;
* Quantile:

        q: table quantile(101) of response_in_ms: int;
* Top:

        t: table top(10) of language: string;
* Unique:

        u: table unique(10000) of string;

######27.3 Indexed Aggregators

    table top(1000) [country: string][hour: int] of request: string;
    
    t1: table sum[country: string] of int
    #equivalent to the values collected by
    t2: table collection of country: string
    
    t1["china"] = 123456
    t1["japan"] = 142367

####28 [Map-Reduce-Merge: Simplified Relational Data Processing on Large Clusters][10]
see [paper review: Map-Reduce-Merge][11]

####29 [Improving MapReduce Performance in Heterogeneous Environments][12]
see [paper review: Improving MapReduce Performance in Heterogeneous Environments][13]

####30 [HANDLING DATA SKEW IN MAPREDUCE][14]
#####30.1 Contribution

* We present a new cost model that takes into account non-linear reducers and skewed data distributions, and we propose an efficient algorithm to estimate the cost in a distributed environment.
* We propose two load balancing algorithms that are based on our cost model and evenly distribute the load on the reducers. The first algorithm, fine partitioning, splits the data into a fixed number of partitions, estimates their cost, and distributes them appropriately. The second approach, dynamic fragmentation, controls the cost of the partitions while they are created.

#####30.2 DATA SKEW IN MapReduce
A good data distribution tries to balance the clus- ters such that all reducers will require roughly the same time for processing. There are two aspects which need to be considered.

1. Number of Clusters. 
2. Difficulty of Clusters. 

The first of these two points can be solved by using an appropriate hash function for partitioning the data. The second point describes two challenges which can not be handled by optimal hashing: clusters of varying size and clusters of varying complexity.

![skew](/assets/2013-09-25-mr-and-processing-language/skew1.png)

#####30.3 COST MODEL

Current Situation

1. Skewed Key Frequencies.
2. Skewed Tuple Sizes.
3. Skewed Execution Times.

Optimal Solution

In order to balance the workload on the reducers, we need to know the amount of work required for every cluster. Typically, the work per cluster depends either on the number of tuples in the cluster, or on the byte size of the cluster, or both these parameters. Therefore, while creating the clusters, we monitor for every cluster C(k) the number of tuples it contains, |C(k)|, and its (byte) size, ∥C(k)∥. Based on the complexity of the reducer algorithm, we can then calculate the weight, w(|C(k)|,∥C(k)∥), i.e.

#####30.4 LOAD BALANCING

* Fine Partitioning
  * By creating more partitions than there are reducers (i. e., by choosing p > r, in contrast to current MapReduce systems where p = r), we retain some degree of freedom for balancing the load on the reducers. 

![skew2](/assets/2013-09-25-mr-and-processing-language/skew2.png)

* Dynamic Fragmentation
  * With the fine partitioning approach presented above, some partitions may grow excessively large, making a good load balancing impossible. In this section we present a strategy which dynamically splits very large partitions into smaller fragments. We define a partition to be very large if it exceeds the average partition size by a predefined factor. Similar to partitions, fragments are containers for multiple clusters. In contrast to partitions, however, the number of fragments may vary from mapper to mapper.

![skew3](/assets/2013-09-25-mr-and-processing-language/skew3.png)

#####30.5 Reducer Slow-start

Empirical evaluations show a fast convergence of the assignments after r mappers are completed.

[1]: http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/zh-CN//archive/mapreduce-osdi04.pdf
[2]: http://infolab.stanford.edu/~usriv/papers/pig-latin.pdf
[3]: http://zhangjunhd.github.io/2013/03/03/pig/
[4]: http://research.microsoft.com/en-us/um/people/jrzhou/pub/Scope.pdf
[5]: http://research.microsoft.com/en-us/projects/dryadlinq/dryadlinq.pdf
[6]: https://www.cs.cmu.edu/afs/cs.cmu.edu/Web/People/15712/papers/isard07.pdf
[7]: https://github.com/MicrosoftResearchSVC/Dryad "Dryad github"
[8]: http://www.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-136.pdf
[9]: http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/zh-CN//archive/sawzall-sciprog.pdf
[10]: http://www.cs.duke.edu/courses/cps399.28/current/papers/sigmod07-YangDasdanEtAl-map_reduce_merge.pdf
[11]: http://zhangjunhd.github.io/2013/08/24/map-reduce-merge/
[12]: http://www.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-183.pdf
[13]: http://zhangjunhd.github.io/2013/07/11/improving-mapreduce-performance-in-heterogeneous-environments/
[14]: http://www-db.in.tum.de/research/publications/conferences/closer2011-100.pdf