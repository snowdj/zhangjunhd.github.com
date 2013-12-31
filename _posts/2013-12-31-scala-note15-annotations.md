---
layout: post
title: "scala笔记15-注解"
description: "scala笔记15-注解"
category: 编程
tags: [scala]
---
{% include JB/setup %}

Scala中可以为类、方法、字段、局部变量和参数添加注解，与Java一样。可以同时添加多个注解，先后顺序没有影响。

{% highlight scala %}
@Entity class Credentials
@Test def testSomeFeature() {}
@BeanProperty var username = _
def doSomething(@NotNull message: String) {}
@BeanProperty @Id var username = _
{% endhighlight %}

给主构造器添加注解时，需要将注解放置在构造器之前，并加上一对圆括号：

{% highlight scala %}
class Credentials @Inject() (var username: String, var password: String)
{% endhighlight %}

为表达式添加注解，在表达式后加上冒号，然后是注解：

{% highlight scala %}
(myMap.get(key): @unchecked) match { ... }
{% endhighlight %}

为类型参数添加注解：

{% highlight scala %}
class MyContainer[@specialized T]
{% endhighlight %}

针对实际类型的注解应放置在类型名称之后：

{% highlight scala %}
String @cps[Unit]
{% endhighlight %}

####针对Java特性的注解
@volatile注解标记为易失的；@transient注解将字段标记为瞬态的；@strictfp注解对应strictfp修饰符；@native注解标记在C或C++代码中实现的方法，对应native修饰符。

Scala使用@cloneable和@remote注解来代替Cloneable和java.rmi.Remote标记接口。

Java编译器会跟踪受检异常。那么如果从Java代码中调用Scala的方法时，需要包含那些可能抛出的受检异常。这时，需要使用@throws注解来生成正确的签名：

{% highlight scala %}
class Book {
  @throws(classOf[IOException]) def read(filename: String) { ... }
  ...
}

// 对应的Java代码
void read(String filename) throws IOException
{% endhighlight %}

使用@varargs注解可以让Java调用Scala中带有变长参数的方法。

####用于优化的注解
`尾递归`计算过程的最后一步是递归调用同一个方法，可以变换成跳回到方法顶部的循环。比如：
{% highlight scala %}
def sum(xs: Seq[Int], partial: BigInt): BigInt = 
  if (xs.isEmpty) partial else sum(xs.tail, xs.head + partial)
{% endhighlight %}

上面的代码中Scala会自动尝试使用尾递归优化。不过有的时候可能会因为某些原因使得编译器无法进行优化。如果需要依赖于编译器去掉递归，给方法加上@tailrec注释。这样的话，如果编译器无法应用递归优化，就会报错。

对于消除递归，一个更加通用的机制叫`“蹦床”`。蹦床会执行一个循环，不停地调用函数，每个函数都返回下一个将被调用的函数。尾递归是一个特例，每个函数都返回它自己。Scala有一个名为TailCalls的工具对象，可以帮助实现蹦床。相互递归的函数返回类型为TailRec[A]，要么返回done(result)，要么返回tailcall(fun)，fun是下一个要被调用的函数。这个函数必须是不带额外参数且同样返回TailRec[A]的函数。示例：

{% highlight scala %}
import scala.util.control.TailCalls._
def evenLength(xs: Seq[Int]): TailRec[Boolean] =
  if (xs.isEmpty) done(true) else tailcall(oddLength(xs.tail))
def oddLength(xs: Seq[Int]): TailRec[Boolean] =
  if (xs.isEmpty) done(false) else tailcall(evenLength(xs.tail))

// 获取结果使用result方法
evenLength(1 to 1000000).result
{% endhighlight %}

在C++或Java中，switch语句通常可以被编译成`跳转表`，这比一系列的if/else表达式更加高效。Scala也会尝试对匹配语句生成跳转表。而@switch注解可以检查match语句是不是真的被编译成了跳转表。

{% highlight scala %}
(n: @switch) match {
  case 0 => "Zero"
  case 1 => "One"
  case _ => "?"
}
{% endhighlight %}

`方法内联`是另一个常见的优化。内联将方法调用语句替换为被调用的方法体。使用@inline来建议编译器做内联，或者使用@noinline来告诉编译器不要内联。

@elidable注解给可以`在生产代码中移除的方法打上标记`。

打包和解包基本类型的值不高效，不过这样的操作在泛型代码里很常见。当使用泛型代码时，可以使用@specialized注解来`使编译器自动生成基本类型的重载版本`。

{% highlight scala %}
def allDifferent[@specialized(Long, Double) T](x: T, y: T, z: T) = ...
{% endhighlight %}

####用于错误和警告的注解
1. 加上了@deprecated注解的特性如果被使用，编译器会生成一个警告信息。
2. @implicitNotFound注解用于在某个隐式参数不存在的时候生成有意义的错误提示。
3. @unchecked注解用于在匹配不完整时取消警告信息。
4. @uncheckedVariance注解会取消与型变相关的错误提示。
