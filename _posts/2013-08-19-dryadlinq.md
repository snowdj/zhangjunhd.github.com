---
layout: post
title: "DryadLINQ"
description: ""
category: tech
tags: [paper, dryad]
---
{% include JB/setup %}
paper review:[DryadLINQ: A System for General-Purpose Distributed Data-Parallel Computing Using a High-Level Language](http://research.microsoft.com/en-us/projects/dryadlinq/dryadlinq.pdf)

<!--break-->

##2 System Architecture
####2.1 DryadLINQ Execution Overview

![DryadLINQ1](/assets/2013-08-19-dryadlinq/DryadLINQ1.png)

* Step 1. A .NET user application runs. It creates a DryadLINQ expression object. Because of LINQ’s deferred evaluation, the actual execution of the expression has not occurred.
* Step 2. The application calls ToDryadTable triggering a data-parallel execution. The expression object is handed to DryadLINQ.
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

##3 Programming with DryadLINQ
The term LINQ refers to a set of .NET constructs for manipulating sets and sequences of data items.

The DryadLINQ data model is a distributed implementation of LINQ collections. Datasets may still contain arbitrary .NET types, but each DryadLINQ dataset is in general distributed across the computers of a cluster, partitioned into disjoint pieces as shown in Figure 4.

![DryadLINQ2](/assets/2013-08-19-dryadlinq/DryadLINQ2.png)

The primary restriction imposed by the DryadLINQ system to allow distributed execution is that all the funcions called in DryadLINQ expressions must be side-effect free. Shared objects can be referenced and read freely and will be automatically serialized and distributed where necessary. However, if any shared object is modified, the result of the computation is undefined.

##4 System Implementation
####4.1 Execution Plan Graph
When it receives control, DryadLINQ starts by converting the raw LINQ expression into an execution plan graph (EPG), where each node is an operator and edges represent its inputs and outputs. The EPG is a directed acyclic graph. DryadLINQ then applies term-rewriting optimizations on the EPG. 

####4.2 DryadLINQ Optimizations
* Static Optimizations
  * Pipelining
  * Removing redundancy
  * Eager Aggregation
  * I/O reduction
* Dynamic Optimizations

####4.3 Code Generation
The EPG is used to derive the Dryad execution plan after the static optimization phase. While the EPG encodes all the required information, it is not a runnable program. DryadLINQ uses dynamic code generation to automatically synthesize LINQ code to be run at the Dryad vertices. The generated code is compiled into a .NET assembly that is shipped to cluster computers at execution time. For each execution-plan stage, the assembly contains two pieces of code:

* The code for the LINQ subexpression executed by each node.
* Serialization code for the channel data.