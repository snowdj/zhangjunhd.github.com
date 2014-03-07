---
layout: post
title: "MR and Processing Language3"
description: ""
category: 云计算
tags: [MapReduce, Incoop, HaLoop, Twister, Nectar, Comet, Dryad]
---
{% include JB/setup %}

MapReduce相关文章 review 41-50

####43 [Incoop: MapReduce for Incremental Computations][4]

In Incoop, computations can respond automatically and efficiently to modifications to their input data by reusing intermediate results from previous computations, and incrementally updating the output according to the changes in the input.

![2](/assets/2013-10-10-mr-and-processing-language3/incoop1.png)

In particular, the design of Incoop contains the following new techniques that we incorporated into the Hadoop MapReduce framework:

* **Incremental HDFS**. Instead of relying on HDFS to store the input to MapReduce jobs, we devise a file system called Inc-HDFS that provides mechanisms to identify similarities in the input data of consecutive job runs. The idea is to split the input into chunks whose boundaries depend on the file contents so that small changes to input do not change all chunk boundaries. Inc-HDFS therefore partitions the input in a way that maximizes the opportunities for reusing results from previous computations, while preserving compatibility with HDFS, by offering the same interface and semantics.

![3](/assets/2013-10-10-mr-and-processing-language3/incoop2.png)

* **Contraction phase**. We propose techniques for controlling the granularity of tasks so that large tasks can be divided into smaller subtasks that can be re-used even when the large tasks cannot. This is particularly challenging in Reduce tasks, whose granularity depends solely on their input. Our solution is to introduce a new Contraction phase that leverages Combiner functions, normally used to reduce network traffic by anticipating a small part of the processing done by Reducer tasks, to control the granularity of the Reduce tasks.

![4](/assets/2013-10-10-mr-and-processing-language3/incoop3.png)

![5](/assets/2013-10-10-mr-and-processing-language3/incoop4.png)

* **Memoization-aware scheduler**. To improve effectiveness of memoization, we propose an affinity-based scheduler that uses a work stealing algorithm to minimize the amount of data movement across machines. Our new scheduler strikes a balance between exploiting the locality of previously computed results and executing tasks on any available machine to prevent straggling effects.

####44 [HaLoop: Efﬁcient Iterative Data Processing on Large Clusters][5]

* First, HaLoop exposes a new application programming interface to users that simplifies the expression of iterative MapReduce programs (Section 2.2). 
* Second, HaLoop’s master node contains a new loop control module that repeatedly starts new map-reduce steps that compose the loop body, until a user-specified stopping condition is met (Section 2.2). 
* Third, HaLoop uses a new task scheduler for iterative applications that leverages data locality in these applications (Section 3). 
* Fourth, HaLoop caches and indexes application data on slave nodes (Section 4).

![6](/assets/2013-10-10-mr-and-processing-language3/haloop.png)

![7](/assets/2013-10-10-mr-and-processing-language3/haloop2.png)

####45 [Twister: A Runtime for Iterative MapReduce][6]

`Twister` is an enhanced MapReduce runtime with an extended programming model that supports iterative MapReduce computations efficiently. It uses a publish/subscribe messaging infrastructure for communication and data transfers, and supports long running map/reduce tasks, which can be used in “configure once and use many times” approach. In addition it provides programming extensions to MapReduce with “broadcast” and “scatter” type data transfers.

![8](/assets/2013-10-10-mr-and-processing-language3/twister.png)

Twister architecture comprises of three main entities; (i) client side driver (Twister Driver) that drives the entire MapReduce computation, (ii) Twister Daemon running on every worker node, and (iii) the broker network. During the initialization of the runtime, Twister starts a daemon process in each worker node, which then establishes a connection with the broker network to receive commands and data. The daemon is responsible for managing map/reduce tasks assigned to it, maintaining a worker pool to execute map and reduce tasks, notifying status, and finally responding to control events. The client side driver provides the programming API to the user and converts these Twister API calls to control commands and input data messages sent to the daemons running on worker nodes via the broker network.

![9](/assets/2013-10-10-mr-and-processing-language3/twister2.png)

Twister uses a publish/subscribe messaging infrastructure to handle four types of communication needs; (i) sending/receiving control events, (ii) send data from the client side driver to the Twister daemons, (iii) intermediate data transfer between map and reduce tasks, and (iv) send the outputs of the reduce tasks back to the client side driver to invoke the combine operation.

####46 [Nectar: Automatic Management of Data and Computation in Data Centers][7]

With Nectar, the results of a computation, called derived datasets, are uniquely identified by the program that computes it, and together with the program are automatically managed by a data center wide caching service. All computations and uses of derived datasets are controlled by the system. The system automatically regenerates a derived dataset from its program if it is determined missing. Nectar greatly improves data center management and resource utilization: obsolete or infrequently used derived datasets are automatically garbage collected, and shared common computations are computed only once and reused by others.

![10](/assets/2013-10-10-mr-and-processing-language3/nectar.png)

A Nectar-managed data center offers the following four advantages.

1. Efficient space utilization. Nectar implements a cache server that manages the storage, retrieval, and eviction of the results of all computations (i.e., derived datasets). As well, Nectar retains the description of the computation that produced a derived dataset. Since programmers do not directly manage datasets, Nectar has considerable latitude in optimizing space: it can remove unused or infrequently used derived datasets and recreate them on demand by rerunning the computation. This is a classic tradeoff of storage and computation.

2. Reuse of shared sub-computations. Many applications running in the same data center share common sub-computations. Since Nectar automatically caches the results of subcomputations, they will be computed only once and reused by others. This significantly reduces redundant computations, resulting in better resource utilization.

3. Incremental computations. Many data center applications repeat the same computation on a sliding window of an incrementally augmented dataset. Again, caching in Nectar enables us to reuse the results of old data and only compute incrementally for the newly arriving data.

4. Ease of content management. With derived datasets uniquely named by LINQ expressions, and automatically managed by Nectar, there is little need for developers to manage their data manually. In particular, they don’t have to be concerned about remembering the location of the data. Executing the LINQ expression that produced the data is sufficient to access the data, and incurs negligible overhead in almost all cases because of caching. This is a significant advantage because most data center applications consume a large amount of data from diverse locations and keeping track of the requisite filepath information is often a source of bugs.

![11](/assets/2013-10-10-mr-and-processing-language3/nectar2.png)

![12](/assets/2013-10-10-mr-and-processing-language3/nectar3.png)

####47 [Caching Function Calls Using Precise Dependencies][8]

#####Efficient Caching

As described previously, the dependencies for each function call are divided into two groups, `primary` and `secondary`.

* The primary dependencies are determined at the call site, before the function is evaluated. The primary dependencies normally include the body of the function being invoked and the values of the function’s arguments that are of scalar types.
* The secondary key represents the names on which the function dynamically depends, as well as the values of those names in the evaluation context.

#####Computing Dependencies

To describe the key ideas used in our dependency calculation, we define a subset of the Vesta modeling language. Table 1 gives the subset language’s syntax.

Here, `Literal` is the set of literals, and `Id` is the set of identifiers. Every expression is evaluated in some `evaluation context`, which is a mapping from variable names to values. 

![13](/assets/2013-10-10-mr-and-processing-language3/cfunc1.png)

![14](/assets/2013-10-10-mr-and-processing-language3/cfunc2.png)

####48 [Comet: Batched Stream Processing for Data Intensive Distributed Computing][9]

#####INTRODUCTION
Our study further reveals that the redundancy is due to correlations among queries. The workload exhibits `temporal correlations`, where it is common to have a series of queries involving the same recurring computations on the same data stream in different time windows. The workload further exhibits `spatial correlations`, where a data stream is often the target of multiple queries involving different but somewhat overlapping computations. 

To expose temporal correlations among queries, we introduce `Batched Stream Processing` (BSP) to model recurring (batch) computations on incrementally bulk-appended data streams.

#####COMET DESIGN

Each single bulk update creates a `segment` of the data stream; different segments are differentiated with their timestamps that indicate their arrival times. Recurring computations form a `query series`, where each query instance in a query series is triggered when new segment(s) are appended.

With query series, execution of an earlier query in a query series is aware of future query executions in the same query series, thereby offering opportunities for optimizations.

* First, an execution of an earlier query could piggyback statistical properties of input data streams or intermediate data; such statistical information could guide effective optimizations of later queries. 

* Second, in cases where consecutive queries in a query series have overlapping computations (e.g., when query series operate on a sliding window spanning multiple segments), these queries can be rewritten to expose the results of common intermediate computations (similar to materialized views in database systems) to be used by later queries in the same query series.

* More importantly, with query series, query execution is now mostly driven by bulk updates to input streams rather than by submissions from users. Queries in different query series that operate on the same input stream can now be aligned and optimized together as one aggregated query. This helps remove redundancies, which are spatial correlations across query series.

Comet allows users to submit a query series by specifying the period and the number of recurrences of the computations. We use the following terms to define the computation units in an execution:

* `S-query`. An S-query is a single query occurrence of a query series; it can access one or more segments on one or more streams.
* `SS-query`. Intuitively, an SS-query is a sub-computation of an S-query that can be executed when a new segment arrives. We associate with each SS-query a timestamp indicating its planned execution time. It is usually equal to the maximum timestamp of the segments it accesses: arrival of the segment with the maximum timestamp triggers execution of the SS-query. An S-query can be decomposed into one or more SS-queries in a normalization process.
* `Jumbo-query`. A jumbo-query is a set of SS-queries with the same timestamp; that is, a jumbo query includes all SS-queries that can be executed together, thereby leveraging any common I/O and computations among these SS-queries.

Figure 5 shows how query series are processed in Comet. When a query series is submitted, Comet normalizes it into a sequence of SS-queries and combines them with their corresponding jumbo-queries. This allows Comet to align query series based on the segments they involve.

![15](/assets/2013-10-10-mr-and-processing-language3/comet1.png)

#####INTEGRATION INTO DRYADLINQ

![16](/assets/2013-10-10-mr-and-processing-language3/comet2.png)

* Overview
  * Translate a query into its logical plan. DryadLINQ applies logical optimizations, including early filtering and removal of redundant operators.
  * Transform the logical plan to a physical plan with physical operators.
  * Encapsulate the physical plan to a Dryad execution graph.
  * Generate C# code for each vertex in the Dryad execution graph, with optimizations including pipelining and removal of unnecessary nodes. Each vertex in the Dryad execution graph has several physical operator nodes. The vertices are deployed to different machines for distributed executions.

![17](/assets/2013-10-10-mr-and-processing-language3/comet3.png)

* Cost Model
  * Comet collects statistics during query executions, e.g., input and output sizes for each operator, as well as cost of custom functions, and stores such information in the catalog for cost analysis.
  * The integrated cost model focuses on estimation of total disk and network I/O. At each stage, Comet can take the input size of a query and use the relationship between input and output sizes from a previous run of the same execution to estimate the amount of I/O.

* Normalization
The normalization phase converts a given DryadLINQ S-query into a sequence of SS-queries, each of which is triggered when a segment of an input stream becomes available.

![18](/assets/2013-10-10-mr-and-processing-language3/comet4.png)

* Logical Optimization
  * Shared computations.
  * Reused view across jumbo-queries.
* Physical Optimization
  * Shared scan.
  * Shared shuffling.

####50 [DryadInc: Reusing work in large-scale computations][11]

#####Introduction

An interesting common feature of these applications is that the input data (a) continuously grows and (b) old data does not change.

In this paper we are investigating the problem of `incrementalizing` the computation as well: given a computation of a large data set, we attempt to perform it efficiently on an incrementally larger data-set, reusing most of the effort.

Our first solution is called `Identical Computation` (IDE), and is fully automatic. IDE is a form of memoization, which caches partial results and reuses them if they reoccur unchanged in the context of future computations. The second solution is called `Mergeable Computation` (MER), and it requires some support from the user: the programmer has to provide a merging function which combines the results computed on an old version of the input with the results computed on the additional input data (delta). Intuitively, IDE is similar to the Unix make tool, which avoids recomputing partial results that have not changed, while MER is similar to the Unix patch tool, which “fixes” the output given incremental changes in the input.

#####System Architecture

`The Rerun Logic`: In the Dryad system job graphs are generated programmatically (i.e., the user uses an API to construct job graphs with arbitrary acyclic shapes). The rerun logic intercepts the job DAG after it has been generated, just prior to its execution.

![22](/assets/2013-10-10-mr-and-processing-language3/dryadinc1.png)

`The Cache Server`: is a generic cluster-level service with a put/get API operating on key-value pairs. 

#####Identical Computation (IDE)

![23](/assets/2013-10-10-mr-and-processing-language3/dryadinc2.png)

#####Mergeable Computation (MER)

![24](/assets/2013-10-10-mr-and-processing-language3/dryadinc3.png)

[4]: http://www.cl.cam.ac.uk/~ey204/teaching/ACS/R202_2012_2013/papers/S4_Programming/papers/bhatotia_SOCC_2011.pdf
[5]: http://homes.cs.washington.edu/~magda/papers/bu-vldb10.pdf
[6]: http://www.iterativemapreduce.org/hpdc-camera-ready-submission.pdf
[7]: http://research.microsoft.com/pubs/131525/nectar-tr.pdf
[8]: http://www.vestasys.org/doc/pubs/pldi-00-04-20.pdf
[9]: http://www.ntu.edu.sg/home/bshe/socc10.pdf
[11]:http://budiu.info/work/hotcloud09.pdf
