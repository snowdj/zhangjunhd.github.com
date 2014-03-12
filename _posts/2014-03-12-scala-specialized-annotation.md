---
layout: post
title: "scala specialized annotation"
description: ""
category: 编程
tags: [scala,java]
---
{% include JB/setup %}

##1 [Specializing for primitive types][1]

* Type erasure:if you have an instance of a generic class, for example List[String], then the compiler will throw away the information about the type argument, so that at runtime it will look like List[Object].
* You cannot make a List<int>. If you want to create a list that holds integers, you’ll have to use the wrapper class Integer.
    * Java提供了[AutoBoxing][4]机制，使得这件事情做起来很自然。
    * 需要注意 [AutoBoxing 和 UnBoxing的一些限制][5]。
    *  A drawback: you need to box each of your primitive ints into an Integer object that takes up a lot more memory.
* The `@specialized` annotation
    * The compiler will actually generate two versions of the class: the normal, generic one, in which the type parameter is erased, and a special subclass that uses the primitive type Int, without the need to box or unbox the value. 

{% highlight scala %}
class Container[@specialized(Int) T](value: T) {
  def apply(): T = value
}
{% endhighlight %}

* 由于@specialized会产生一个重载函数，所以[大量使用，会使得代码急剧膨胀][2]。
* [Java: What's the difference between autoboxing and casting?][3]
    * `Boxing` is when you convert a primitive type to a reference type, un-boxing is the reverse. 
    * `Casting` is when you want one type to be treated as another type, between primitive types and reference types this means an implicit or explicit `boxing operation`. Whether it needs to be explicit is a language feature.

[1]:http://www.scala-notes.org/2011/04/specializing-for-primitive-types/
[2]:http://stackoverflow.com/questions/5477675/why-are-so-few-things-specialized-in-scalas-standard-library
[3]:http://stackoverflow.com/questions/501653/java-whats-the-difference-between-autoboxing-and-casting
[4]:http://docs.oracle.com/javase/1.5.0/docs/guide/language/autoboxing.html
[5]:http://www.xyzws.com/Javafaq/what-should-i-know-about-autoboxing-and-unboxing-in-java-50/132
