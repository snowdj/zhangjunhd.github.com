---
layout: post
title: "FlumeJava"
description: ""
category: tech
tags: [paper, google, FlumeJava, MapReduce]
---
{% include JB/setup %}
paper review:[FlumeJava: Easy, Efficient Data-Parallel Pipelines](http://pages.cs.wisc.edu/~akella/CS838/F12/838-CloudPapers/FlumeJava.pdf)

<!--break-->
##3. The FlumeJava Library
####3.1 Core Abstractions
The central class of the FlumeJava library is `PCollection<T>`, a (possibly huge) immutable bag of elements of type T. A PCollection can either have a well-defined order (called a `sequence`), or the elements can be unordered (called a `collection`).

    PCollection<String> lines =
        readTextFileCollection("/gfs/data/shakes/hamlet.txt");
    PCollection<DocInfo> docInfos =
        readRecordFileCollection("/gfs/webdocinfo/part-*",
                                 recordsOf(DocInfo.class));

A second core class is `PTable<K,V>`, which represents a (possibly huge) immutable multimap with keys of type K and values of type V. PTable<K,V> is a subclass of PCollection<Pair<K,V>>, and indeed is just an unordered bag of pairs.

The main way to manipulate a PCollection is to invoke a data-parallel operation on it. The FlumeJava library defines only a few primitive data-parallel operations; other operations are implemented in terms of these primitives. The core data-parallel primitive is `parallelDo()`, which supports elementwise computation over an input PCollection<T> to produce a new output `PCollection<S>`. This operation takes as its main argument a `DoFn<T, S>`, a function-like object defining how to map each value in the input PCollection<T> into zero or more values to appear in the output `PCollection<S>`. It also takes an indication of the kind of PCollection or PTable to produce as a result.

    PCollection<String> words =
        lines.parallelDo(new DoFn<String,String>() {
            void process(String line, EmitFn<String> emitFn) {
                for (String word : splitIntoWords(line)) {
                    emitFn.emit(word);
                }
            }
        }

`parallelDo()` can be used to express both the map and reduce parts of MapReduce. Since they will potentially be distributed remotely and run in parallel, `DoFn` functions should not access any global mutable state of the enclosing Java program.

A second primitive, `groupByKey()`, converts a multi-map of type PTable<K,V> (which can have many key/value pairs with the same key) into a unimap of type `PTable<K, Collection<V>>` where each key maps to an unordered, plain Java Collection of all the values with that key. For example, the following computes a table mapping URLs to the collection of documents that link to them:

    PTable<URL,DocInfo> backlinks =
        docInfos.parallelDo(new DoFn<DocInfo,Pair<URL,DocInfo>>() {
            void process(DocInfo docInfo,EmitFn<Pair<URL,DocInfo>> emitFn) {
                for (URL targetUrl : docInfo.getLinks()) {
                    emitFn.emit(Pair.of(targetUrl, docInfo));
                }
            }
        }, tableOf(recordsOf(URL.class),recordsOf(DocInfo.class)));
    
    PTable<URL,Collection<DocInfo>> referringDocInfos =
        backlinks.groupByKey();

`groupByKey()` captures the essence of the shuffle step of MapReduce. There is also a variant that allows specifying a sorting order for the collection of values for each key.

A third primitive, `combineValues()`, takes an input `PTable<K, Collection<V>>` and an associative combining function on Vs, and returns a PTable<K, V> where each input collection of values has been combined into a single output value. For example:

    PTable<String,Integer> wordsWithOnes =
        words.parallelDo(new DoFn<String, Pair<String,Integer>>() {
            void process(String word,EmitFn<Pair<String,Integer>> emitFn) {
                emitFn.emit(Pair.of(word, 1));
            }
        }, tableOf(strings(), ints()));
    
    PTable<String,Collection<Integer>> groupedWordsWithOnes =
        wordsWithOnes.groupByKey();
    PTable<String,Integer> wordCounts =
        groupedWordsWithOnes.combineValues(SUM_INTS);

`combineValues()` is semantically just a special case of parallelDo(), but the associativity of the combining function allows it to be implemented via a combination of a MapReduce `combiner` (which runs as part of each mapper) and a MapReduce `reducer` (to finish the combining), which is more efficient than doing all the combining in the reducer.

A fourth primitive, `flatten()`, takes a list of `PCollection<T>`s and returns a single `PCollection<T>` that contains all the elements of the input PCollections. flatten() does not actually copy the inputs, but rather creates a view of them as one logical PCollection.

####3.2 Derived Operations
The FlumeJava library includes a number of other operations on PCollections, but these others are derived operations, implemented in terms of these primitives, and no different than helper functions the user could write. 

* count()
* join()
* top()

####3.3 Deferred Evaluation
In order to enable optimization as described in the next section, FlumeJava’s parallel operations are executed lazily using `deferred evaluation`. Each PCollection object is represented internally either in `deferred` (not yet computed) or `materialized` (computed) state. A deferred PCollection holds a pointer to the deferred operation that computes it. A deferred operation, in turn, holds references to the PCollections that are its arguments (which may themselves be deferred or materialized) and the deferred PCollections that are its results. When a FlumeJava operation like parallelDo() is called, it just creates a ParallelDo deferred operation object and returns a new deferred PCollection that points to it. The result of executing a series of FlumeJava operations is thus a directed acyclic graph of deferred PCollections and operations; we call this graph the `execution plan`.

To actually trigger evaluation of a series of parallel operations, the user follows them with a call to FlumeJava.run(). This first optimizes the execution plan and then visits each of the deferred operations in the optimized plan, in forward topological order, and evaluates them. When a deferred operation is evaluated, it converts its result PCollection into a materialized state, e.g.

####3.4 PObjects
To support inspection of the contents of PCollections during and after the execution of a pipeline, FlumeJava includes a class `PObject<T>`, which is a container for a single Java object of type T. Like PCollections, PObjects can be either deferred or materialized, allowing them to be computed as results of deferred operations in pipelines. After a pipeline has run, the contents of a now-materialized PObject can be extracted using getValue(). PObject thus acts much like a `future`.

##4. Optimizer
####4.1 ParallelDo Fusion
One of the simplest and most intuitive optimizations is ParallelDo `producer-consumer fusion`, which is essentially function composition or loop fusion. If one ParallelDo operation performs function f, and its result is consumed by another ParallelDo operation that performs function g, the two ParallelDo operations are replaced by a single multi-output ParallelDo that computes both f and g ◦ f . 

ParallelDo `sibling fusion` applies when two or more ParallelDo operations read the same input PCollection. They are fused into a single multi-output ParallelDo operation that computes the results of all the fused operations in a single pass over the input.

Both producer-consumer and sibling fusion can apply to arbitrary trees of multi-output ParallelDo operations. Figure 2 shows an example execution plan fragment where ParallelDo operations A, B, C, and D can be fused into a single ParallelDo A+B+C+D. The new ParallelDo creates all the leaf outputs from the original graph, plus output A.1, since it is needed by some other non-ParallelDo operation Op. Intermediate output A.0 is no longer needed and is fused away.

![flumejava1](/assets/2013-05-01-flumejava/flumejava1.png)

####4.2 The MapShuffleCombineReduce (MSCR) Operation
An MSCR operation has M input channels (each performing a map operation) and R output channels (each optionally performing a shuffle, an optional combine, and a reduce). Each input channel m takes a `PCollection<Tm>` as input and performs an R-output ParallelDo “map” operation (which defaults to the identity operation) on that input to produce R outputs of type `PTable<Kr ,Vr >`s; the input channel can choose to emit only to one or a few of its possible output channels. Each output channel r Flattens its M inputs and then either (a) performs a GroupByKey “shuffle”, an optional CombineValues “combine”, and a Or-output ParallelDo “reduce” (which defaults to the identity operation), and then writes the results to Or output PCollections, or (b) writes its input directly as its output. The former kind of output channel is called a “grouping” channel, while the latter kind of output channel is called a “pass-through” channel; a pass-through channel allows the output of a mapper to be a result of an MSCR operation.

MSCR generalizes MapReduce by allowing multiple reducers and combiners, by allowing each reducer to produce multiple outputs, by removing the requirement that the reducer must produce outputs with the same key as the reducer input, and by allowing pass-through outputs, thereby making it a better target for our optimizer.

Figure 3 shows an MSCR operation with 3 input channels performing ParallelDos M1, M2, and M3 respectively, two grouping output channels, each with a GroupByKey, CombineValues, and reducing ParallelDo, and one pass-through output channel.

![flumejava2](/assets/2013-05-01-flumejava/flumejava2.png)

####4.3 MSCR Fusion
Figure 4 shows how an example execution plan is fused into an MSCR operation. In this example, all three GroupByKey operations are related, and hence seed a single MSCR operation. GBK1 is related to GBK2 because they both consume outputs of ParallelDo M2. GBK2 is related to GBK3 because they both consume PCollection M4.0. The ParallelDos M2, M3, and M4 are incorporated as MSCR input channels. Each of the GroupByKey operations becomes a grouping output channel. GBK2’s output channel incorporates the CV2 CombineValues operation. The R2 and R3 ParallelDos are also incorporated into output channels. An additional identity input channel is created for the input to GBK1 from non-ParallelDo Op1. Two additional pass-through output channels (shown as edges from mappers to outputs) are created for the M2.0 and M4.1 PCollections that are used after the MSCR. The resulting MSCR operation has 4 input channels and 5 output channels.

![flumejava3](/assets/2013-05-01-flumejava/flumejava3.png)

####4.4 Overall Optimizer Strategy
The optimizer performs a series of passes over the execution plan, with the overall goal to produce the fewest, most efficient MSCR operations in the final optimized plan:

* Sink Flattens. A Flatten operation can be pushed down through consuming ParallelDo operations by duplicating the ParallelDo before each input to the Flatten. In symbols, h(f (a) + g(b)) is transformed to h(f (a)) + h(g(b)). This transformation creates opportunities for ParallelDo fusion, e.g., (h ◦ f)(a) + (h ◦ g)(b).
* Lift CombineValues operations. If a CombineValues operation immediately follows a GroupByKey operation, the GroupByKey records that fact. The original CombineValues is left in place, and is henceforth treated as a normal ParallelDo operation and subject to ParallelDo fusion.
* Insert fusion blocks. If two GroupByKey operations are connected by a producer-consumer chain of one or more ParallelDo operations, the optimizer must choose which ParallelDos should fuse “up” into the output channel of the earlier GroupByKey, and which should fuse “down” into the input channel of the later GroupByKey. The optimizer estimates the size of the intermediate PCollections along the chain of ParallelDos, identifies one with minimal expected size, and marks it as boundary blocking ParallelDo fusion.
* Fuse ParallelDos.
* Fuse MSCRs. Create MSCR operations. Convert any remaining unfused ParallelDo operations into trivial MSCRs.
