---
layout: post
title: "PowerDrill"
description: ""
category: 云计算
tags: [Powerdrill]
---
{% include JB/setup %}
paper review:[Processing a Trillion Cells per Mouse Click](http://vldb.org/pvldb/vol5/p1436_alexanderhall_vldb2012.pdf)

<!--break-->
##1. INTRODUCTION
The column-store developed as part of PowerDrill is tailored to support a few selected datasets and tuned for speed on typical queries resulting from users interacting with the UI. Compared to Dremel which supports thousands of different datasets (streaming the data from a distributed file system such as GFS [15]), our column-store relies on having as much data in memory as possible. PowerDrill can run interactive single queries over more rows than Dremel, however the total amount of data it can serve is much smaller, since data is kept mostly in memory, whereas Dremel uses a distributed file system.

##2. BASIC APPROACH
####2.1 The Power of Full Scans vs. Skipping Data
As mentioned previously, the main advantage column-stores have over traditional row-wise storage, is that only a fraction of the data needs to be accessed when processing typical queries (accessing often only ten or less out of thousands of columns). Another important benefit is that columns compress better and therefore reduce the I/O and main memory usage.

A common characteristic of these system is that they are in most cases highly optimized for efficient full scans of data.

As a rule of thumb, even in large database systems if more than a certain, often small percentage of the data is touched, a full scan is performed as opposed to using any indices. The obvious benefits being less random access I/O, simpler, easier to optimize inner loops, and very good cache locality. The latter already easily accounts for a factor of 10 for data which is in memory and when comparing scanning vs. random access: an L2 cache access usually costs less than 1/10th of a main memory access, see, e.g.,.

The logical next step is to try to combine the benefits of an index data-structure (making it possible to `skip` data) with the power of full scans. This can be achieved by splitting the data into `chunks` during import and providing data-structures to quickly decide which chunks can be skipped at query processing time. On each `active`, i.e., not skipped, chunk a full scan is performed. For our application, partitioning is much more powerfull than traditional indices, since partitions allow indexing by multiple dimensions and enable covering lookups without duplication the data (such costly duplication is, e.g., used by C-Store / Vertica).

####2.2 Partitioning the Data
In our case we perform a `composite range partitioning` to split the data into chunks during the import.

Put simply, the user chooses an ordered set of fields which are used to split the data iteratively into smaller and smaller `chunks`. At the start the data is seen as one large chunk. Successively, the largest chunk is split into two (ideally evenly balanced) chunks. For such a split the chosen fields are considered in the given order. The first field with at least two remaining distinct values is used to essentially do a range split, i.e., a set of ranges are chosen for the field which determine the first and the second chunk. The iteration is stopped once no chunk with more rows than a given threshold, e.g., 50’000, exists. This “heaviest first” splitting generally leads to very evenly distributed chunk sizes.

####2.3 Basic Data-Structures
It is important to note that the order of the data for all columns is the same and corresponds to the (possibly reordered) rows of the original table. In other words, when “synchronoulsy” iterating over all columns, the original rows can be reconstructed.

Let us now focus on a single column, say search string, and describe the basic data-structures with the help of a concrete example. We assume that the partitioning described in the previous section has been performed and resulted in 3 chunks.3 In chunk 0 we have the fictious queries [“ebay”, “cheap flights”, “amazon”, . . . ]. The values of a column are stored in a doubly indirect way using two dictionaries:

* We introduce a `global-dictionary` which contains all distinct values of the original column, see the leftmost box in Figure 1 for an example. The values are stored in a sorted manner and can be accessed by their integer `rank` also referred to as `global-id `(e.g., 9 → “la redoute”). Conversely, the global-dictionary can also be used to look up the global-id of a given value (e.g., “ebay” → 5).
* Per chunk we store a `chunk-dictionary` containing n entries, one for each value / global-id occurring in that chunk. The chunk-dictionary can be used to map occurring global-ids to and from integer `chunk-ids`. These are in the range {0,...,n−1} and are assigned to the sorted global-ids in an ascending manner, see the three boxes to the right in Figure 1.

![p1](/assets/2013-06-05-powerdrill/p1.png)

The actual values of the column are then represented by a long sequence of chunk-ids per chunk, the so-called `elements`.

There are numerous advantages of this special “double dictionary encoding”. It makes it easy to determine which chunks are not active (can be skipped) when processing a query, see next section. Dictionary encodings are a common approach to compress data. The second indirection introduced by the chunk-dictionaries has the effect that the elements are comprised of values from a small range of consecutive integers. This is advantageous when further optimizing the memory footprint, see Section 3.

##3. KEY OPTIMIZATIONS
Data-structures with small memory footprints are essential for the overall performance of our system.

In contrast, in our case we may only access a fraction of the data represented, e.g., by the global- and chunk- dictionaries. Loading these from disk for each query would lead to a disproportionate overhead. To give a concrete example, loading an entire dictionary for the table name field (from our experiments) from disk, would essentially bring down the performance to the level of streaming all data, i.e., doing full scans. In other words, to really profit from the “basic data-structures” described in Section 2.3, we rely on them being in memory whenever possible.

* Partitioning the Data into Chunks
* Optimize Encoding of Elements in Columns
* Optimize Global-Dictionaries
* Generic Compression Algorithm
* Reordering Rows

![p2](/assets/2013-06-05-powerdrill/p2.png)

##4. DISTRIBUTED EXECUTION
####Distributing Data to many Machines
For simplisity of exposition, we have so far only considered a setup on one machine with a relatively small amount of data. To scale up to be able to process billions of rows, the data can be distributed to many machines and processed in parallel.

We are mostly interested in group-by queries and for these it is important that the individual machines do most of the work rather than sending data to a central server. To achieve that, we organize the machines as a computation tree and do the grouping and aggregation on each level of the tree. For this to work, we need to execute the aggregations on multiple levels. This is possible for SUM, MIN, and MAX, i.e. aggregations that can be expressed by associative, binary operations (e.g. SUM(a, b, c, d) = SUM(SUM(a, b), SUM(c, d))). Or, if aggregations can be expressed by such associative ones, e.g. count(*) = SUM(1) and AVG(x) = SUM(x) / SUM(1). We cannot support count distinct by that. Therefore, we use use an approximative technique described in Section 5.

One approach to distribute data may be to distribute the chunks resulting from the partitioning. This is very bad for load-balancing though, since machines that contain active chunks may be heavily loaded while others—which only contain chunks that can be skipped—are idle. A better and actually very common approach is to start by `sharding` (i.e., distributing) the data quasi randomly across the machines. Each shard is on one machine and is then partitioned into chunks as described in Section 2.2. This achieves very good load balancing across machines. It has the additional advantage that the partitioning algorithm can be tuned to work well for a bounded amount of input data.

####Reliable Distributed Execution of a Query
An important ingredient to getting this right for our setup was to choose a good replication scheme. A query being distributed to many machines is split up into sub-queries, each being responsible for a certain, distinct part of the data. Instead of sending each sub-query out to only one machine, for reliability we send it out to two machines: the primary and a replica. As soon as one of the two repsonses returns, the sub-query is treated as “answered”.

##5. EXTENSIONS

* Complex Expressions
* Count Distinct
* Other Compression Algorithms
* Further Optimizing the Global-Dictionaries
* Improved Cache Heuristics




