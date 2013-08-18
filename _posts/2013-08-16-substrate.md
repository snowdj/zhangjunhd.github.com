---
layout: post
title: "A Common Substrate for Cluster Computing"
description: ""
category: tech
tags: [paper, nexus, dryad, MapReduce]
---
{% include JB/setup %}

paper review:[A Common Substrate for Cluster Computing](https://www.usenix.org/legacy/event/hotcloud09/tech/full_papers/hindman.pdf)

<!--break-->

##1 Introduction
To enable diverse frameworks to coexist, Nexus **decouples job execution management from resource management** by providing a simple resource management layer over which frameworks like Hadoop and Dryad can run.

##3 Nexus Architecture
####3.1 Overview
The goal of Nexus is to provide isolation and efficient resource sharing across cluster computing frameworks running on the same cluster.To accomplish this, Nexus provides abstractions of computing resources and an API to let frameworks access these resources.

Nexus exports two abstractions: tasks and slots.

* A `task` represents a unit of work, such as a map task in MapReduce.
* A `slot` represents a computing resource in which a framework may run a task, such as a core and some associated memory on a multicore machine.

Nexus employs two-level scheduling.

* At the first level, Nexus allocates slots between frameworks using fair sharing.
* At the second level, each framework is responsible for dividing its work into tasks, selecting which tasks to run in each slot, and as we shall explain, deciding which slots to use.

![nuxus](/assets/2013-08-16-substrate/nexus.png)

Nexus has a `master` process that controls a `slave` daemon running on each node in the cluster. Each framework that uses Nexus has a `scheduler` process that registers with the master. Schedulers launch tasks in their allocated slots by providing `task descriptors`. These descriptors are passed to a framework-specific `executor` process that Nexus launches on slave nodes. Finally, Nexus passes status updates about tasks to schedulers, including notification if a task fails or a node is lost.

Nexus purposely does not provide abstractions for storage and communication. We concentrate only on allocating computing resources (slots), and allow tasks to use whichever storage and communication libraries they wish.

####3.2 Slot Assignment
The main challenge with Nexus’s two-level scheduling design is ensuring that frameworks are allocated slots they wish to run in. For example, a MapReduce framework needs to run maps on the nodes that contain its input file to avoid reading data over the network. Nexus addresses this issue through a mechanism called `slot offers`. When a slot becomes free, Nexus offers it to each framework in turn, in order of how far each framework is below its fair share. Each framework may accept the slot and launch a task in it, or refuse the slot if, for example, it has no data on that machine. Refusing a slot keeps the framework below its fair share, ensuring that it is offered future slots before other frameworks. If the framework has still not found a data-local slot after waiting for some time, it can always accept a non-local slot.

A second concern is how to reassign slots when frameworks’ demands change (e.g., a new framework registers). In normal operation, Nexus simply reassigns slots to new frameworks as tasks from overallocated frameworks finish. To ensure that frameworks are not starved even when some tasks are long, Nexus can also `reclaim` a slot by killing the task executing in it after a timeout. Nexus reclaims most-recently launched tasks from each framework first, minimizing wasted work.

![nuxus](/assets/2013-08-16-substrate/nexus2.png)
