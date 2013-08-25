---
layout: post
title: "Delay Scheduling"
description: ""
category: tech
tags: [paper, MapReduce, hadoop]
---
{% include JB/setup %}

paper review:[Delay Scheduling: A Simple Technique for Achieving Locality and Fairness in Cluster Scheduling](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.212.1524&rep=rep1&type=pdf)

<!--break-->

##1. Introduction
In this paper, we explore the problem of shar- ing a cluster between users while preserving the efficiency of systems like MapReduce – specifically, preserving data *locality*, the placement of computation near its input data.

Hadoop Fair Scheduler,`HFS` has two main goals

* Fair sharing: divide resources using max-min fair sharing to achieve statistical multiplexing. For example, if two jobs are running, each should get half the resources;













      
    J >> (F/S)T
    
Waiting will therefore not impact job response times significantly if at least one of the following conditions holds:

* Many jobs: When there are many jobs running, each job’s fractional share of the cluster, f = F/S , is small.
* Small jobs: Jobs with a small number of tasks (we call these “small jobs”) will also have a small values of f . 
* Long jobs: Jobs where J > T incur little overhead.

####3.3 Locality Problems with Na ̈ıve Fair Sharing
Running on a node that contains the data (`node locality`) is most efficient, but when this is not possible, running on the same rack (`rack locality`) is faster than running off-rack. 

The first locality problem occurs in small jobs (jobs that have small input files and hence have a small number of data blocks to read). The problem is that whenever a job reaches the head of the sorted list in Algorithm 1 (i.e. has the fewest running tasks), one of its tasks is launched on the next slot that becomes free, no matter which node this slot is on. **If the `head-of-line` job is small, it is unlikely to have data on the node that is given to it.** For example, a job with data on 10% of nodes will only achieve 10% locality.

A second locality problem, `sticky slots`, happens even with large jobs if fair sharing is used. **The problem is that there is a tendency for a job to be assigned the same slot repeatedly.** For example, suppose that there are 10 jobs in a 100-node cluster with one slot per node, and that each job has 10 running tasks. Suppose job j finishes a task on node n. Node n now requests a new task. At this point, j has 9 running tasks while all the other jobs have 10. Therefore, Algorithm 1 assigns the slot on node n to job j again. Consequently, in steady state, **jobs never leave their original slots.** This leads to poor data locality because input files are striped across the cluster, so each job needs to run some tasks on each machine.

####3.4 Delay Scheduling

![algorithm2](/assets/2013-08-15-delay-scheduling/algorithm2.png)

####3.5 Analysis of Delay Scheduling
We explore how the maximum skip count D in Algorithm 2 affects locality and response times, and how to set D to achieve a target level of locality. We find that:

* Non-locality decreases exponentially with D.
* The amount of waiting required to achieve a given level of locality is a fraction of the average task length and decreases linearly with the number of slots per node L.

Two factors can break these assumptions:

* Some jobs may have long tasks. If all the slots on a node are filled with long tasks, the node may not free up quickly enough for other jobs to achieve locality.
* Some nodes may be of interest to many jobs. We call these nodes hotspots. For example, multiple jobs may be trying to read the same small input file.



####3.6 Rack Locality
This can be accomplished by extending Algorithm 2 to give each job two waiting periods. First, if the `head-of-line` job has been skipped at most D1 times, it is only allowed to launch node-local tasks. Once a job has been skipped D1 times, it enters a second “level” of delay scheduling, where it is only allowed to launch rack-local tasks. If the job is skipped D2 times while at this level, it is allowed to launch non-local tasks. A nice consequence of our analysis is that D2 can be much smaller than D1: because there are much fewer racks than nodes, a job will not be skipped many times until it finds a slot in a rack that contains its data.