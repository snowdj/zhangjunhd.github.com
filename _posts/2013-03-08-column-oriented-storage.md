---
layout: post
title: "Column Oriented Storage"
description: ""
category: 云计算
tags: [column, MapReduce]
---
{% include JB/setup %}
paper review:[Column-Oriented Storage Techniques for MapReduce](http://arxiv.org/pdf/1105.4252.pdf)

<!--break-->
##4. COLUMN-ORIENTED STORAGE
####4.1 Replication and Co-location
A straightforward way to implement a column-oriented storage format in Hadoop is to store each column of the dataset in a separate file. This imposes two problems. First, how can we generate roughly equal sized splits so that a job can be effectively parallelized over the cluster? Second, how do we make sure that the corresponding values from different columns in the dataset are co-located on the same node running the map task?

The first problem can be solved by horizontally partitioning the dataset and storing each partition in a separate sub-directory. Each such subdirectory now serves as a split. The second problem is harder to solve. HDFS uses 3-way block-level replication to provide fault tolerance on commodity servers, but the default block placement policy does not provide any co-location guarantees.

Figure 3a illustrates what can happen with Hadoop’s default placement policy. C1-C3 are co-located on Node 1 but not co-located on any other node. Suppose a map task is scheduled for the split consisting of C1-C3 but Node 1 is busy. In that case, Hadoop would schedule the map task on some other node, say Node 2, but performance would suffer, since C3 would have to be remotely accessed.

![1](/assets/2013-03-08-column-oriented-storage/1.png)

Recent work on the RCFile format avoids these problems by resorting to a PAX format instead of a true column-oriented format. RCFile takes the approach of packing each HDFS block with chunks called `row-groups`. Since all the columns are packed into a single row-group, and each row-group can function independently as a split, it avoids the two challenges that arise when storing columns separately.

While RCFile is simple and fits well within Hadoop’s constraints, it has a few drawbacks. Since the columns are all interleaved in a single HDFS block, efficient I/O elimina- tion becomes difficult because of prefetching by HDFS and the local filesystem. Tuning the row-group size and the I/O transfer size correctly also becomes critical. With larger I/O transfer sizes like 1MB, records that contain more than four columns show very poor I/O elimination characteristics with the default RCFile settings. Finally, extra metadata needs to be written for each row group, leading to additional space overhead.

####4.2 The CIF Storage Format
ColumnPlacementPolicy (CPP) is the class name of our column-oriented block placement policy. For simplicity, we will assume that each column file occupies a single HDFS block and describe CPP as though it works at the file level. In effect, CPP guarantees that the files corresponding to the different columns of a split are always co-located across replicas. Figure 3b shows how C1-C3 would be co-located across replicas using CPP. Subdirectories that store splits need to follow a specific naming convention for CPP to work. Files that do not follow this naming convention, are replicated using the default placement policy of HDFS.

We implemented the logic for our column-oriented storage format in two classes: the ColumnInputFormat (`CIF`) and the ColumnOutputFormat (`COF`).

When a dataset is loaded into a subdirectory using COF, it breaks the dataset into smaller horizontal partitions. Each partition, referred to as a `split-directory`, is a subdirectory with a set of files, one per column in the dataset. An additional file describing the schema is also kept in each split-directory. Figure 4 shows the layout of data using COF, with split-directories s0 and s1.

![2](/assets/2013-03-08-column-oriented-storage/2.png)

When reading a dataset, CIF can actually assign one or more split-directories to a single split. The column files of a split-directory are scanned sequentially and the records are reassembled using values from corresponding positions in the files. Projections can be pushed into CIF by supplying it with a list of columns.

####4.3 Discussion
A major advantage of CIF over RCFile is that adding a column to a dataset is not an expensive operation. This can be done by simply placing an additional file for the new column in each of the split-directories. With RCFile, adding a new column is a very expensive operation – the entire dataset has to be read and each block re-written.

On the other hand, a potential disadvantage of CIF is that the available parallelism may be limited for smaller datasets. Maximum parallelism is achieved for a MapReduce job when the number of splits is at least equal to the number of map slots, say m. RCFile allows fine grained splits at the row-group level (4MB) when compared to split-directories in CIF (typically 64 MB).

Load balancing with CIF and CPP happens at a coarser granularity (per split-directory) using the same algorithms as the default placement policy. This is because CPP chooses the location of the first block of a split-directory using the default placement policy. All the remaining blocks in the split directory are then placed on the same set of nodes.

##5. LAZY RECORD CONSTRUCTION
The basic idea behind lazy record construction is to deserialize only those columns of a record that are actually accessed in a map function.

####5.1 Implementation
CIF can be configured to use one of two classes for materializing records, namely, EagerRecord or LazyRecord. Both of these classes implement the same Record interface.

EagerRecord eagerly deserializes all the columns that are being scanned by CIF. LazyRecord is slightly more compli- cated. Internally, LazyRecord maintains a split-level curPos pointer, which keeps track of the current record the map function is working on in a split. It also maintains a lastPos pointer per column file, which keeps track of the last record that was actually read and deserialized for a particular column file. Both pointers are initialized to the first record of the split at the start of processing.

Each time RecordReader is asked to read the next record, it increments curPos. No bytes are actually read or deserialized until one of the get() methods is called on the resulting Record object. Consider the example in Figure 5. Since get(“url”) is called on every record, lastPos is always equal to curPos for the URL column. However, for the meta- data column, lastPos may lag behind curPos if there are records where the URL column does not contain the pattern “ibm.com/jp”. When the URL column contains this pattern and get(“metadata”) is called, lastPos skips ahead to curPos before the metadata column is deserialized.

![3](/assets/2013-03-08-column-oriented-storage/3.png)

####5.2 Skip List Format
Figure 6 shows the format used in CIF. A column file contains two kinds of values, regular serialized values and skip blocks. Skip blocks contain information about byte offsets to enable skipping the next N records, where N is typically configured for 10, 100, and 1000 record skips.

![4](/assets/2013-03-08-column-oriented-storage/4.png)

####5.3 Compression
We propose two schemes to compress columns of complex data types: compressed blocks, and dictionary compressed skip lists.