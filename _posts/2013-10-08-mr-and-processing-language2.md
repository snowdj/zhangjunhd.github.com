---
layout: post
title: "MR and Processing Language2"
description: ""
category: 云计算
tags: [python, jquery, MapReduce, Pig, LINQ]
---
{% include JB/setup %}

MapReduce, jQuery相关文章 review 31-40

####31 [IPython: A System for Interactive Scientiﬁc Computing][1]

一种交互式shell python。文章中提到了python科学计算的很多project，包括可视化工具。

####32 [jQuery][2]

* A JavaScript client-side library
* jQuery Components

![1](/assets/2013-10-08-mr-and-processing-language2/jquery.png)

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
[5]: http://www.vldb.org/pvldb/2/vldb09-1074.pdf
[6]: http://www.codeproject.com/Tips/590978/LINQ-Tutorial-for-Beginners
[7]: http://webcourse.cs.technion.ac.il/234319/Spring2009/ho/WCFiles/09%20LINQ.pdf
[8]: http://www.ibm.com/developerworks/cn/linux/l-cn-closure/
[9]: http://www.codeproject.com/Tips/298963/Understand-Lambda-Expressions-in-3-minutes
[10]: http://www.cse.ohio-state.edu/hpcs/WWW/HTML/publications/papers/TR-11-7.pdf
[11]: http://zhangjunhd.github.io/2013/08/28/ysmart/