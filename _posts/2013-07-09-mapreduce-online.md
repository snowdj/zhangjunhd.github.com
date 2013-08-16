---
layout: post
title: "MapReduce Online"
description: ""
category: tech
tags: [MapReduce, paper]
---
{% include JB/setup %}

paper review:[MapReduce Online](http://www.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-136.pdf)

<!--break-->

##2 Background
####2.1 Programming Model
To use MapReduce, the programmer expresses their desired computation as a series of `jobs`. The input to a job is a list of `records` (key-value pairs).  Each job consists of two steps:

  * First, a user-defined `map` function is applied to each record to produce a list of intermediate key-value pairs.
  * Second, a user-defined `reduce` function is called once for each distinct key in the map output, and passed the list of intermediate values associated with that key.
  * Optionally, the user can supply a `combiner` function. Combiners are similar to reduce functions, except that they are not passed all the values for a given key: instead, a combiner emits an output value that summarizes the input values it was passed.

####2.2 Hadoop Architecture
A Hadoop installation consists of a single master node and many worker nodes.

* The master, called the `JobTracker`, is responsible for accepting jobs from clients, dividing those jobs into `tasks`, and assigning those tasks to be executed by worker nodes.
* Each worker runs a `TaskTracker` process that manages the execution of the tasks currently assigned to that node.
* A `heartbeat` protocol between each TaskTracker and the JobTracker is used to update the JobTracker’s bookkeeping of the state of running tasks, and **drive the scheduling of new tasks**: if the JobTracker identifies free TaskTracker slots, it will schedule further tasks on the TaskTracker.

####2.3 Map Task Execution
Each map task is assigned a portion of the input file called a `split`. The execution of a map task is divided into two phases.

* The `map` phase reads the task’s split from HDFS, parses it into records (key/value pairs), and applies the map function to each record.
* After the map function has been applied to each input record, the `commit` phase registers the final output with the TaskTracker, which then informs the JobTracker that the task has finished executing.

####2.4 Reduce Task Execution
The execution of a reduce task is divided into three phases.

* The `shuffle` phase fetches the reduce task’s input data. Each reduce task is assigned a partition of the key range produced by the map step, so the reduce task must fetch the content of this partition from every map task’s output.
* The `sort` phase groups records with the same key together.
* The `reduce` phase applies the user-defined reduce function to each key and corresponding list of values.

##3 Pipelined MapReduce
![mr](/assets/2013-07-09-mapreduce-online/mr_1.png)
####3.1 Pipelining Within A Job
Reduce tasks traditionally issue HTTP requests to `pull` their output from each TaskTracker. To support pipelining, we modified the map task to instead `push` data to reducers as it is produced. 

#####3.1.1 Na ̈ıve Pipelining
Each reduce task contacts every map task upon initiation of the job, and opens a socket which will be used to pipeline the output of the map function. As each map output record is produced, the mapper determines which partition (reduce task) the record should be sent to, and **immediately sends it via the appropriate socket**.

A reduce task accepts the pipelined data it receives from each map task and stores it an in-memory buffer, spilling sorted runs of the buffer to disk as needed. Once the reduce task learns that every map task has completed, it performs a final merge of all its sorted runs and applies the user-defined reduce function as normal, writing the output to HDFS.

#####3.1.2 Refinements
Problems:

* First, it is possible that there will not be enough slots available to schedule every task in a new job.
* Opening a socket between every map and reduce task also requires a large number of TCP connections.

Solutions:

* If a reduce task has not yet been scheduled, any map tasks that produce records for that partition simply write them to disk. Once the reduce task is assigned a slot, it can then fetch the records from the map task, as in stock Hadoop.
* To reduce the number of concurrent TCP connections, each reducer can be configured to pipeline data from a bounded number of mappers at once; the reducer will pull data from the remaining map tasks in the traditional Hadoop manner.

#####3.1.3 Granularity of Map Output
Problems:

* Combiners allow “map-side preaggregation”: By eagerly pipelining each record as it is produced, there is no opportunity for the map task to apply a combiner function.
* Eager pipelining moves some of the sorting work from the mapper to the reducer: In the na ̈ıve pipelining design, map tasks send output records in the order in which they are generated, so the reducer must perform a full external sort.

Solutions:

* Instead of sending the buffer contents to reducers directly, we instead wait for the buffer to grow to a threshold size. The mapper then applies the combiner function, sorts the output by partition and reduce key.
* A second thread monitors the spill files, and sends them to the pipelined reducers. This has the effect of `adaptively` moving load from the reducer to the mapper or vice versa, depending on which node is the current bottleneck.

####3.2 Pipelining Between Jobs
In our modified version of Hadoop, the reduce tasks of one job can optionally pipeline their output directly to the map tasks of the next job, sidestepping the need for expensive fault-tolerant storage in HDFS for what amounts to a temporary file.

####3.3 Fault Tolerance
* To simplify fault tolerance, the reducer treats the output of a pipelined map task as “tentative” until the JobTracker informs the reducer that the map task has committed successfully.
* The reducer can merge together spill files generated by the same uncommitted mapper, but won’t combine those spill files with the output of other map tasks until it has been notified that the map task has committed. 
* Envision introducing a “checkpoint” concept: as a map task runs, it will periodically notify the JobTracker that it has reached offset x in its input split. The JobTracker will notify any connected reducers; map task output that was produced before offset x can then be merged by reducers with other map task output as normal.
* To avoid duplicate results, if the map task fails, the new map task attempt resumes reading its input at offset x. This technique also has the benefit of reducing the amount of redundant work done after a map task failure.

##4 Online Aggregation
####4.1 Single-Job Online Aggregation
We can support online aggregation by simply applying the reduce function to the data that a reduce task has received so far. We call the output of such an intermediate reduce operation a `snapshot`. Applications can consume snapshots by polling HDFS in a predictable location.

####4.2 Multi-Job Online Aggregation
Suppose that j1 and j2 are two MapReduce jobs, and j2 consumes the output of j1. When j1’s reducers compute a snapshot to perform online aggregation, that snapshot is written to HDFS, and also sent directly to the map tasks of j2. The map and reduce steps for j2 are then computed as normal, to produce a snapshot of j2’s output. This process can then be continued to support online aggregation for an arbitrarily long sequence of jobs.

##5 Continuous Queries
MapReduce jobs that run `continuously`, accepting new data as it becomes available and analyzing it immediately.

####5.1 Continuous MapReduce Jobs
We added an optional “flush” API that allows map functions to force their current output to reduce tasks. When a reduce task is unable to accept such data, the mapper framework stores it locally and sends it at a later time. 

To support continuous reduce tasks, the user-defined reduce function must be periodically invoked on the map output available at that reducer. Applications will have different requirements for how frequently the reduce function should be invoked: possible choices include periods based on wall-clock time, logical time (e.g. the value of a field in the map task output), and the number of input rows delivered to the reducer.

#####5.2 Prototype Monitoring System
Our monitoring system is composed of `agents` that run on each monitored machine and record statistics of interest (e.g. load average, I/O operations per second, etc.).

Each agent is implemented as a continuous map task: rather than reading from HDFS, the map task instead reads from various continuous system-local data streams (e.g. /proc).

Each agent forwards statistics to an `aggregator` that is implemented as a continuous reduce task.