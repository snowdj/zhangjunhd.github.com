---
layout: post
title: "Multi-agent Cluster Scheduling for Scalability and Flexibility"
description: ""
category: tech
tags: [paper, mesos, omega]
---
{% include JB/setup %}
paper review:[Multi-agent Cluster Scheduling for Scalability and Flexibility
](http://www.eecs.berkeley.edu/Pubs/TechRpts/2012/EECS-2012-273.pdf)

<!--break-->
##Chapter 2 Related Work and Taxonomy of Cluster Scheduling
####2.1 Target Cluster Environment
* Use of commodity servers
* Tens to hundreds of thousands of servers
* Heterogeneous resources
* Use of commodity networks

####2.2 Cluster Workload Taxonomy
* **Service Jobs vs. Terminating Jobs**. `Service Jobs` consist of a set of service tasks that conceptually are intended to run forever, and these tasks are interacted with by means of request-response interfaces, e.g., a set of web servers or relational database servers. `Terminating Jobs`, on the other hand, are given a set of inputs, perform some work as a function of those inputs, and are intended terminate eventually. We call frameworks that manage service jobs `"service frameworks"` and those that manage terminating jobs `"terminating-job frameworks"`.
* **Task pickiness**. Pickiness is a measurement of how many cluster resources could potentially satisfy a task’s requirements or preferences; more picky implies fewer resources are satisfactory.
* **Job elasticity**. This dimension impacts the design of cluster schedulers at the level of the API that frameworks use to be acquire resources for their tasks. Cluster schedulers that do not provide an easy way for frameworks to dynamically grow, shrink, or swap out the resources they are using are less “flexible” and, in general, achieve lower utilization of resources.
* **Job and task duration**. We also refer to this dimension as granularity; we call short jobs or tasks “fine grained” and long ones “coarse grained”. The more fine-grained the tasks, the more tasks that can complete, and thus the more that must be scheduled per unit time.
* **Task scheduling-time sensitivity**. This dimension impacts the design of any cluster schedulers that aim to support such latency sensitive workloads, either via service jobs or terminating jobs. Such schedulers must be able to provide some statistical guarantees to jobs about the maximum time tasks will have to wait to be scheduled.

####2.3 A General Model for Cluster Scheduling
* **Resource**: A consumable abstraction of a physical device that provides a service that is necessary or useful to accomplish a computational goal. Examples include CPU, disk, and RAM.
* **Server**: A server machine that can hold a number of Resources.
* **Cluster State**: A logical data table, similar to a database table, with one row per server in the cluster. Columns represent different types of resources that a server can contain. Rows can be added, read, updated, or deleted. These operations correspond to the addition, reconfiguration, or removal of whole Servers to/from the cluster or resources to/from individual servers. Figure 2.2 contains a conceptual diagram representing cluster state and a zoomed-in view of a single row.

![scheduling1](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling1.png)

* **Scheduling Domain**: A subset of the rows in Cluster State.
* **Task**: An atomic unit of computation. A Task optionally “has a” set of resourcerequirements, and optionally “has a” set of placement constraints.* **Job**: A unit of workload. A Job “has a” collection of tasks, “has a” list of job-level scheduling constraints, and “has a” User. Jobs can be “service jobs” or “terminating jobs”.
* **Task-Resource Assignment**: The pairing of a task with a non-empty set of available resources on a single machine. Conceptually this consists of the following information sufficient to create a transaction that can be atomically “applied” to cluster state: {machine ID, task ID, ⟨resource name1, resource amount1⟩, ⟨resource name2, resource amount2⟩, . . . }. Specifically, when a task-resource assignment is applied to cluster state, the row of cluster state uniquely identified by machine ID, will have the value corresponding to the column associated with resource namen decreased by the corresponding resourceamountn. For example, a task-resource assignment might look like: {machine ID: 12, task ID: 20, ⟨“CPUs”, 2.0⟩, ⟨“Memory (GB)”, 1.0⟩}.
* **Scheduling Agent Policy**: The rules and algorithms used by a Scheduling Agent to make Task-Resource Assignments. Examples include: fair sharing, random, priority scheduling.
* **Scheduling Agent**: Creates Task-Resource Assignments based on a Scheduling Agent Policy. A Scheduling Agent “has a” Scheduling Agent Policy. Inputs are a Job and access to a Scheduling Domain. Output is a set of Task-Resource Assignments.
* **Job Transaction**: A set of Task-Resource Assignments for a single job submitted simultaneously to Cluster State.
* **Job Scheduling Decision Time**: The amount of time a Scheduling Agent spends building a job transaction, i.e., attempting to schedule all of the Tasks in a Job, matching them with Servers that have suitable resources available.
* **User: submits Jobs to Job Managers**. A Scheduling Agent Policy may use a Job’s User to make decisions about and optionally has an expectation of maximum scheduling time acceptable for each job.
* **Job Queue**: A Queue of Jobs with tasks that have not run to completion.
* **Job Manager**: The entity responsible for managing Jobs and interfacing with Users.A Job Manager “has a” Scheduling Agent and “has a” Job Queue.
####2.4 Taxonomy of Cluster Scheduling Architectures
* **Monolithic State Scheduling**. Single scheduling agent, with exclusive access to cluster state, performs all scheduling decisions serially i.e., in order; no job-level scheduling concurrency.
* **Partitioned State Scheduling**. Multiple scheduling agents each perform independent scheduling decisions in parallel on non-overlapping partitions of cluster state. We focus primarily on a variant of PSS in which the partitions are dynamically resized by a centralized meta-scheduling agent called **Dynamically Partitioned State Scheduling (DPS)**.
* **Replicated State Scheduling**. Multiple scheduling agents each maintain full private copies of an authoritative common cluster state. Agents perform their scheduling decisions in parallel. Optimistic concurrency and conflict resolution policies are used to detect and resolve conflicts resulting from concurrent writes to the same row of cluster state.

![scheduling2](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling2.png)

##Chapter 3 Monolithic State Scheduling
In MSS, a single scheduling agent is present, contained within a single job manager. Thus, we also refer to MSS as “single-agent scheduling”. All task-resource assignments are made serially by this single scheduling agent that implements all policy choices in a single code base. 

We refer to scheduling in which task-resource assignments are made using a single scheduling assignment policy, i.e., a single code path, as *single-path* scheduling, and scheduling logic that chooses resources differently according job type, i.e., via multiple code paths, as *multi-path*.

![scheduling3](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling3.png)

##Chapter 4 Partitioned State Scheduling
One way to achieving multi-agent scheduling is to statically partition the rows of Cluster State into non-overlapping partitions and then, for each partition, allow at most a single scheduling agent to edit rows in that partition. This approach can further be broken into two sub-architectures in our taxonomy: static and dynamic partitioning of Cluster State.

####Statically Partitioned State Scheduling (SPS)
The most straightforward way to partition Cluster State is to have all partitions be fixed sizes. We call this the **Statically Partitioned State Scheduling** (SPS) architecture.

There are disadvantages. Jobs that are too big to fit into a single partition simply cannot run, even if there are enough resources globally. Additionally, it is difficult for small organizational sub-units to get a partition assigned to them. It may take days or weeks for resources to get assigned through manual processes. Finally, this approach leads to fragmentation internal to the static partitions and low resource utilization.

![scheduling4](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling4.png)

####Dynamically Partitioned State Scheduling (DPS)
To overcome many of the disadvantages of statically partitioning cluster state that we discussed above, we can allow scheduling domains to be resized dynamically. For example, if one scheduling domain partition is allowed to grow to be the size of the entire cluster, which would imply all other partitions can shrink down to be the null subset of cluster state, this can allow a cluster to support job whose tasks require the all of the resources in the cluster.

![scheduling5](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling5.png)

However, dynamically resizing scheduling state partitions requires a second, or meta, level of scheduling to make the decision about the size of each partition over time. We call this concept, which is not new to this research, `meta-scheduling`. In our model, we call the entity that contains and enforces the meta-scheduling policies the `meta-scheduling agent`.

While one could envision the Job Managers attempting to take pessimistic locks on partitions of cluster state in a `“pull” fashion`, in this work we focus on an implementation of DPS in which the meta-scheduling agent actively decides how to partition cluster state according to some central sharing policy and then actively `“pushes” updates` about the partitions out to scheduling agents. We call this Mesos-style DPS, as this is the implementation we chose to use in the Mesos scheduling system.

##Chapter 6 Replicated State Scheduling

In RSS, there is one common cluster state maintained by the meta-scheduling agent, that acts as a resilient master copy of the resource allocations in the cluster. In addition, each job manager maintains its own `private cluster state`, which it synchronizes with common cluster state before making each job scheduling decision, i.e., creating a job transaction.
![scheduling6](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling6.png)

####Role of the Job Manager
The following is a detailed description of the steps taken by a job manager that constitute the job transaction lifecycle in an RSS system:

* If job queue is not empty, remove next job from job queue.
* Sync: Begin a transaction by synchronizing private cluster state with common cluster state.
* Schedule: Engage scheduling agent to attempt to create task-resource assignments for all tasks in job, modifying private cluster state in the process.
* Submit: Attempt to commit job transaction (i.e., all task-resource assignments for the job) from private cluster state back to common cluster state. Job transaction can succeed or fail.
* Record which task-resource assignments were successfully committed to common cluster state.
* If any tasks in job remain unscheduled—either because no suitable resources were found for the task during the “schedule” stage or the task-resource assignment experienced a—insert job back into job queue to be handled again in a future transaction.

![scheduling7](/assets/2013-08-16-multi-agent-cluster-scheduling/scheduling7.png)

####Role of the meta-scheduling agent
The resulting system would be very similar to Omega, the RSS system we explore here in collaboration with Google. Responsibilities of the meta-scheduling agent:

* Attempt to execute transactions submitted by job managers according to transaction mode settings
* Detect conflicts according to conflict detection semantics and policies
* Enforce meta-scheduling policies

For each job transaction submitted, an RSS meta-scheduling agent performs the following:

* reject task-resource assignments that would violate policies
* reject task-resource assignments that conflict with previously accepted transactions
* reject job all task-resource assignments in a job transaction if using all-or-nothing transaction semantics and at least one task-resource assignment was rejected