---
layout: post
title: "MR and Processing Language2"
description: ""
category: tech
tags: [python, jquery, MapReduce, Pig, LINQ]
---
{% include JB/setup %}

MapReduce, jQuery相关文章 review 31-40

<!--break-->
####31 [IPython: A System for Interactive Scientiﬁc Computing][1]

一种交互式shell python。文章中提到了python科学计算的很多project，包括可视化工具。

####32 [jQuery][2]

* A JavaScript client-side library
* jQuery Components

![1](/assets/2013-10-08-mr-and-processing-language2/jquery.png)

####33 [Vision Paper: Towards an Understanding of the Limits of Map-Reduce Computation][3]
#####33.1 THE MODEL
For our purposes, a problem consists of:

1. Sets of `inputs` and `outputs`.
2. A `mapping` from outputs to sets of inputs. The intent is that each output depends on only the set of inputs it is mapped to.

In our context, there are two nonobvious points about this model:

* Inputs and outputs are hypothetical, in the sense that they are all the possible inputs or outputs that might be present in an instance of the problem. Any instance of the problem will have a subset of the inputs. We assume that an output is never made unless at least one of its inputs is present, and in many problems, we only want to make the output if all of its associated inputs are present.
* We need to limit ourselves to finite sets of inputs and outputs. Thus, a finite domain or domains from which inputs and outputs are constructed is often an integral part of the problem statement, and a “problem” is really a family of problems, one for each choice of finite domain(s).

#####33.2 Mapping Schemas and Replication Rate

For many problems, there is a tradeoff between the number of reducers to which a given input must be sent and the number of inputs that can be sent to one reducer. **The more parallelism we introduce, the greater will be the total cost of computation.**

In our discussion, we shall use the convention that p is the number of reducers used to solve a given problem instance, and q is the maximum number of inputs that can be sent to any one reducer. With a given value of q, to be an assignment of a set of reducers to each input, subject to the constraints that:

1. No more than q inputs are assigned to any one reducer.
2. For every output, its associated inputs are all assigned to one reducer. We say the reducer covers the output. This reducer need not be unique, and it is, of course, permitted that these same inputs are assigned also to other reducers.

Suppose that for a certain algorithm, the ith reducer is assigned qi ≤ q inputs, and let I be the number of different inputs. Then the `replication rate` r for this algorithm is

`\(r = \sum_{i=1}^p {\frac{q_i}{I}} \)`

We want to derive lower bounds on r, as a function of q, for various problems, thus demonstrating the tradeoff between high parallelism (many small reducers) and overhead (total communication cost – the replication rate).

Observe that, no matter what random set of inputs is present for an instance of the problem, the expected communication is r times the number of inputs actually present, so r is a good measure of the communication cost incurred during an instance of the problem.

The pattern that lets us investigate any problem is, we hope, clear from the analysis of Section 3.

1. Find an upper bound, g(q), on the number of outputs a reducer can cover if q is the number of inputs it is given.
2. Count the total numbers of inputs |I| and outputs |O|.
3. Assume there are p reducers, each receiving qi ≤ q inputs and covering g(qi) outputs. Together they cover all the outputs. That is `\(\sum_{i=1}^p {g(q_i)} \geq |O|\)`.
4. Manipulate the inequality from (3) to get a lower bound on the replication rate, which is `\(\sum_{i=1}^p {\frac{q_i}{I}}\)`.
5. Hopefully, demonstrate that there are algorithms whose replication rate matches the formula from (4).

####34 [Upper and Lower Bounds on the Cost of a Map-Reduce Computation][4]

![2](/assets/2013-10-08-mr-and-processing-language2/1.png)

####35 [Building a High-Level Dataﬂow System on top of Map-Reduce: The Pig Experience][5]

Pig Latin->Logical Plan->Physical Plan->Map Reduce Plan

####36 [LINQ Tutorial for Beginners][6]
######36.1 Syntax of LINQ

* Query expression syntax

        from str in strings where str.Length==3 select str; 
* Standard dot notation syntax

        stringList.Where(s => s.Length == 3).Select(s=>s); 
* They are queries returning a set of matching objects, a single object, or a subset of fields from an object or set of objects. In LINQ, this returned set of objects is called a sequence, and most LINQ sequences are of type `IEnumerable<T>`.
* The LINQ query actually take place the first time a result from it is needed. This is typically when the query results variable is enumerated (**deferred query**).

####37 [LINQ as an Example][7]

* LINQ adds static SQL expression correctness to C#.
* To do this, the following features were added to C#:
  * Lambda expressions.
  * Extension methods.
  * Expression types.
  * List comprehension.
  * Anonymous data types. 
  * Type inference.
  
Searching in Collections:


    List<string> londoners = new List<string>();
    foreach (Customer c in customers) { 
        if (c.City == “London”) {
            londoners.add(c.Name);
        }
    }

Searching in Collections: The LINQ Way

    string[] londoners = from c in customers where c.City == “London” select c.Name;

####38 [闭包的概念、形式与应用][8]

闭包是在其词法上下文中引用了自由变量的函数。另一种说法认为闭包是由函数和与其相关的引用环境组合而成的实体。比如：在实现深约束时，需要创建一个能显式表示引用环境的东西，并将它与相关的子程序捆绑在一起，这样捆绑起来的整体被称为闭包。

闭包不是函数，只是行为和函数相似，不是所有被传递的函数都需要转化为闭包，只有引用环境可能发生变化的函数才需要这样做。

####39 [Understand Lambda Expressions in 3 minutes][9]

#####39.1 What is a Lambda Expression?
A lambda expression is an anonymous function. Simply put, it's a method without a declaration, i.e., access modifier, return value declaration, and name. 

#####39.2 Why do we need lambda expressions?
Especially useful in places where a method is being used only once, and the method definition is short. It saves you the effort of declaring and writing a separate method to the containing class.

####40 [YSmart: Yet Another SQL-to-MapReduce Translator][10]

see [YSmart][11]

[1]: http://fperez.org/papers/ipython07_pe-gr_cise.pdf
[2]: http://www.cs.sunysb.edu/~cse336/Slides/L20-jQuery.pdf
[3]: http://arxiv.org/pdf/1204.1754v1.pdf
[4]: http://arxiv.org/pdf/1206.4377v1.pdf
[5]: http://www.vldb.org/pvldb/2/vldb09-1074.pdf
[6]: http://www.codeproject.com/Tips/590978/LINQ-Tutorial-for-Beginners
[7]: http://webcourse.cs.technion.ac.il/234319/Spring2009/ho/WCFiles/09%20LINQ.pdf
[8]: http://www.ibm.com/developerworks/cn/linux/l-cn-closure/
[9]: http://www.codeproject.com/Tips/298963/Understand-Lambda-Expressions-in-3-minutes
[10]: http://www.cse.ohio-state.edu/hpcs/WWW/HTML/publications/papers/TR-11-7.pdf
[11]: http://zhangjunhd.github.io/2013/08/28/ysmart/