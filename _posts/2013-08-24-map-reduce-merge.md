---
layout: post
title: "Map Reduce Merge"
description: ""
category: 
tags: [paper, MapReduce]
---
{% include JB/setup %}
paper review:[Map-Reduce-Merge: Simplified Relational Data Processing on Large Clusters](http://www.cs.duke.edu/courses/cps399.28/current/papers/sigmod07-YangDasdanEtAl-map_reduce_merge.pdf)

<!--break-->
##3. MAP-REDUCE-MERGE

![mrm1](/assets/2013-08-24-map-reduce-merge/mrm1.png)

![mrm2](/assets/2013-08-24-map-reduce-merge/mrm2.png)

The Map-Reduce-Merge model enables processing multiple heterogeneous datasets. The signatures of the Map- Reduce-Merge primitives are listed below, where α, β, γ represent dataset lineages, k means keys, and v stands for value entities.

    map: (k1, v1)α → [(k2, v2)]α
    reduce: (k2,[v2])α → (k2,[v3])α
    merge: ((k2,[v3])α,(k3,[v4])β) → [(k4,v5)]γ

In this new model, the map function transforms an input key/value pair (k1,v1) into a list of intermediate key/value pairs [(k2 , v2 )]. The reduce function aggregates the list of values [v2] associated with k2 and produces a list of values [v3], which is also associated with k2. Note that inputs and outputs of both functions belong to the same lineage, say α. Another pair of map and reduce functions produce the intermediate output (k3,[v4]) from another lineage, say β. Based on keys k2 and k3, the merge function combines the two reduced outputs from different lineages into a list of key/value outputs [(k4,v5)]. This final output becomes a new lineage, say γ. If α = β, then this merge function does a *self-merge*, similar to *self-join* in relational algebra.

####3.2 Implementation
The merge function (`merger`) is like map or reduce, in which developers can implement user-defined data processing logic. While a call to a map function (`mapper`) processes a key/value pair, and a call to a reduce function (`reducer`) processes a key-grouped value collection, a merger processes two pairs of key/values, that each comes from a distinguishable source.

At the Merge phase, users might want to apply different data-processing logic on data based on their sources. An example is the build and probe phases of a hash join, where build programming logic is applied on one table then probe the other. To accommodate this pattern, a `processor` is a user-defined function that processes data from one source only. Users can define two processors in Merge.

After map and reduce tasks are about done, a Map-Reduce-Merge coordinator launches mergers on a cluster of nodes (see Fig. 2). When a merger starts up, it is assigned with a merger number. Using this number, a user-definable module called `partition selector` can determine from which reducers this merger retrieves its input data. Mappers and reducers are also assigned with a number. For mappers, this number represents the input file split. For reducers, this number represents an input bucket, in which mappers partition and store their output data to. For Map-Reduce users, these numbers are simply system implementation detail, but in Map-Reduce-Merge, users utilize these numbers to associate input/output between mergers and reducers in partition selectors.

Like mappers and reducers, a merger can be considered as having logical iterators that read data from inputs. Each mapper and reducer have one logical iterator and it moves from the begin to the end of a data stream, which is an input file split for a mapper, or a merge-sorted stream for a reducer. A merger reads data from two sources, so it can be viewed as having two logical iterators. These iterators usually move forward as their mapper/reducer counterparts, but their relative movement against each others can be instrumented to implement a user-defined merge algorithm. Our Map-Reduce-Merge framework provides a user-configurable module (`iterator-manager`) that it is called for the information that controls the movement of these `configurable iterators`.

![mrm3](/assets/2013-08-24-map-reduce-merge/mrm3.png)

* **Partition Selector** In a merger, a user-defined partition selector function determines which data partitions produced by up-stream reducers should be retrieved then merged. This function is given the current merger’s number and two collections of reducer numbers, one for each data source. Users define logic in the selector to remove unrelated reducers from the collections. Only the data from the reducers left in the collections will be read and merged in the merger.
* **Processors** A processor is the place where users can define logic of processing data from an individual source. Processors can be defined if the hash join algorithm is implemented in Merge, where the first processor builds a hash table on the first source, and the second probes it while iterating through the second data source.
* **Merger** In the merge function, users can implement data processing logic on data merged from two sources where this data satisfies a merge condition.
* **Configurable Iterators** As indicated, by manipulating relative iteration of a merger’s two logical iterators, users can implement different merge algorithms.For algorithms like nested-loop joins, iterators are configured to move as looping variables in a nested loop. For algorithms like sort-merge joins, iterators take turns when iterating over two sorted collections of records. For hash-join-like algorithms, these two iterators scan over their data in separate passes. The first scans its data and builds a hash table, then the second scans its data and probes the already built hash table.

##4. APPLICATIONS TO RELATIONAL DATA PROCESSING
####4.1 Map-Reduce-Merge Implementations of Relational Operators
In our implementation, the Map-Reduce-Merge model assumes that a dataset is mapped into a relation R with an attribute set (schema) A. In map, reduce, and merge functions, users choose attributes from A to form two subsets: K and V . K represents the schema of the “key” part of a Map-Reduce-Merge record and V the “value” part. For each tuple t of R, this implies that t is concatenated by two field sets: k and v,where K is the schema of k and V is the schema of v. It so happens that Map-Reduce-Merge calls k as “key” and v as “value”.

* **Projection** For each tuple t = (k,v) of the input relation, users can define a mapper to transform it into a projected output tuple t′ = (k′,v′), where k′ and v′ are typed by schema K′ and V ′, respectively. K′ and V ′ are subsets of A. Namely, using mappers only can implement relational algebra’s projection operator.
* **Aggregation** At the Reduce phase, Map-Reduce (as well as Map-Reduce-Merge) performs the sort-by-key and group-by-key functions to ensure that the input to a reducer is a set of tuples t = (k, [v]) in which [v] is the collection of all the values associated with the key k. A reducer can call aggregate functions on this grouped value list. Namely, reducers can easily implement the “group by” clause and “aggregate” operators in SQL.
* **Generalized Selection** Mappers, reducers, and mergers can all act as filters and implement the selection operator. If a selection condition is on attributes of one data source, then it can be implemented in mappers. If a selection condition is on aggregates or a group of values from one data source, then it can be implemented in reducers. If a selection condition involves attributes or aggregates from more than one sources, then it can be implemented in mergers. Straightforward filtering conditions that involve only one relation in a SQL query’s “where” and “having” clauses can be implemented using mappers and reducers, respectively. Mergers can implement complicated filtering conditions involving more than one relations, however, this filtering can only be accomplished after join (or Cartesian product) operations are properly configured and executed.
* **Joins** § 4.2 describes in detail how joins can be implemented using mergers with the help from mappers and reducers.
* **Set Union** Assume the union operation (as well as other set operations described below) is performed over two relations. In Map-Reduce-Merge, each relation will be processed by Map-Reduce, and the sorted and grouped outputs of the reducers will be given to a merger. In each reducer, duplicated tuples from the same source can be skipped easily. The mappers for the two sources should share the same range partitioner, so that a merger can receive records within the same key range from the two reducers. The merger can then iterate on each input simultaneously and produce only one tuple if two input tuples from different sources are duplicates. Non-duplicated tuples are produced by this merger as well.
* **Set Intersection** First, partitioned and sorted MapReduce outputs are sent to mergers as described in the last item. A merger can then iterate on each input simultaneously and produce tuples that are shared by the two reducer outputs.
* **Cartesian Product** In a Map-Reduce-Merge task, the two reducer sets will produce two sets of reduced partitions. A merger is configured to receive one partition from the first reducer (F) and the complete set of partitions from the second one (S). This merger can then form a nested loop to merge records in the sole F partition with the ones in every S partition.
* **Rename** It is trivial to emulate Rename in Map-Reduce-Merge, since map, reduce, and merge functions can select, rearrange, compare, and process attributes based on their indexes in the “key” and “value” subsets.

####4.2 Map-Reduce-Merge Implementations of Relational Join Algorithms

* **Sort-Merge Join** Instead of using a `hash partitioner`, users can configure the framework to use a `range partitioner` in mappers.
  * Map: Use a range partitioner in mappers, so that records are partitioned into ordered buckets, each is over a mutually exclusive key range and is designated to one reducer.
  * Reduce: For each Map-Reduce lineage, a reducer reads the designated buckets from all the mappers. Data in these buckets are then merged into a sorted set. This sorting procedure can be done completely at the reducer side, if necessary, through an external sort. Or, mappers can sort data in each buckets before sending them to reducers. Reducers can then just do the merge part of the `merge sort` using a priority queue.
  * Merge: A merger reads from two sets of reducer outputs that cover the same key range. Since these reducer outputs are sorted already, this merger simply does the merge part of the `sort-merge join`.
* **Hash Join** One important issue in distributed computing and parallel databases is to keep workload and storage balanced among nodes. One strategy is to disseminate records to nodes based on their hash values. Another approach is to run a preprocessing Map-Reduce task to scan the whole dataset and build a data density. Here we show how to implement `hash join` using the Map-Reduce-Merge framework:
  * Map: Use a common hash partitioner in both mappers, so that records are partitioned into hashed buckets, each is designated to one reducer.
  * Reduce: For each Map-Reduce lineage, a reducer reads from every mapper for one designated partition. Using the same hash function from the partitioner, records from these partitions can be grouped and aggregated using a hash table, requires maintaining a hashtable either in memory or disk.
  * Merge: A merger reads from two sets of reducer outputs that share the same hashing buckets. One is used as a `build` set and the other `probe`. After the partitioning and grouping are done by mappers and reducers, the build set can be quite small, so these sets can be hash-joined in memory. Notice that, the number of reduce/merge sets must be set to an optimally large number in order to support an in-memory hash join, otherwise, an external hash join is required.
* **Block Nested-Loop Join** The Map-Reduce-Merge implementation of the `block nested- loop` join algorithm is very similar to the one for the hash join. Instead of doing an in-memory hash, a nested loop is implemented. The partitioning and grouping done by mappers and reducers concentrate the join sets, so this parallel nested-loop join can enjoy a high selectivity in each merger.

##5. OPTIMIZATIONS
####5.1 Optimal Reduce-Merge Connections
For mergers, because data is already partitioned and even sorted after Map and Reduce phases, they do not need to connect to every reducer in order to get their data. The selector function in mergers can choose pertinent reduced partitions for merging.

If one input dataset is much larger than the other, then it would be inefficient to partition both datasets into the same number of reducers. One can choose different numbers for RA and RB, but the selection logic is more complicated.

Selector logic can also be quite complicated in the case of θ-join.

Before feeding data from selected reducer partitions to a user-defined merger function, these tuples can be compared and see if they should be merged or not. In short, this comparison can be done in a user-defined `matcher` that is simply a fine-grained selector.

####5.2 Combining Phases

* **ReduceMap, MergeMap**: Reducer and merger outputs are usually fed into a down-stream mapper for a subsequent join operation. These outputs can simply be sent directly to a co-located mapper in the same process without storing them in secondary storage first.
* **ReduceMerge**: A merger usually takes two sets of reducer partitions. This merger can be combined with one of the reducers and gets its output directly while remotely reads data from the other set of reducers.
* **ReduceMergeMap**: An straightforward combination of ReduceMerge and MergeMap becomes ReduceMergeMap.
* Another way of reducing disk accesses is to replace disk read-writes with network read-writes.