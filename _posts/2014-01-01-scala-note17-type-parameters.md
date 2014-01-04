---
layout: post
title: "scala笔记17-类型参数与隐式转换"
description: "scala笔记17-类型参数，隐式转换"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####类型变量界定
{% highlight scala %}
class Pair[T](val first : T, val second : T) {
  def smaller = if (first.compareTo(second) < 0) first else second // Error
}
{% endhighlight %}

这个方法是错误的，因为无法确定first是否有compareTo方法。要解决这个问题，可以添加一个`上界`:

{% highlight scala %}
class Pair[T <: Comparable[T]](val first : T, val second : T) {
  def smaller = if (first.compareTo(second) < 0) first else second
}
{% endhighlight %}

这意味着T必须是Comparable[T]的子类型。有时候需要为类型定义一个`下界`。假设定义一个方法，用于替换first:

{% highlight scala %}
class Pair[T](val first : T, val second : T) {
  def replaceFirst(newFirst : T) = new Pair[T](newFirst, second)
}
{% endhighlight %}

一个很好的方法是，假定我们有一个Pair[Student]，我们应该允许用一个Person来替换first(此时得到是Pair[Person])，即替换进来的类型必须是原类型的超类型:

{% highlight scala %}
class Pair[T](val first : T, val second : T) {
  def replaceFirst[R >: T](newFirst : R) = new Pair[R](newFirst, second)
}
{% endhighlight %}

####视图界定
在`class Pair[T <: Comparable[T]]`例子中，如果尝试new一个Pair(4,2)，编译器会抱怨Int不是Comparable[Int]的子类型。Scala的Int类型并没有实现Comparable，不过RichInt实现了Comparable[Int]，同时还有一个从Int到RichInt的`隐式转换`。解决的方法是使用`视图界定`:

{% highlight scala %}
class Pair[T <% Comparable[T]](val first : T, val second : T) {
  def smaller = if (first.compareTo(second) < 0) first else second
}
{% endhighlight %}
`<%`关系意味着T可以被隐式转换成Comparable[T]。

####上下文界定
`上下文界定`的形式T:M，其中M是另一个泛型类。它要求必须存在一个类型为M[T]的“隐式值”。

{% highlight scala %}
class Pair[T : Ordering](val first : T, val second : T) {
  def smaller(implicit ord:Ordering[T]) = if (ord.compare(first, second) < 0) first else second
}
{% endhighlight %}

要实例化一个泛型的Array[T]，我们需要一个Manifest[T]对象。可以使用上下文界定:

{% highlight scala %}
def makePair[T : Manifest](first : T, second : T) = {
  val r = new Array[T](2)
  r(0) = first
  r(1) = second
  r
}
{% endhighlight %}

如果调用makePair(4, 9)编译器将定位到隐式的Manifest[Int]并实际上调用makePair(4, 9)(intManifest)。这样该方法调用的就是new Array(2)(intManifest)，返回基本类型数组int[2]。之所以这么做，是因为在虚拟机中，泛型相关的类型信息是被抹掉的。

####多重界定

* 类型变量可以同时有上界和下界:`T >: Lower :< Upper`
* 不能同时有多个上界和下界，但是一个类型可以实现多个特质:`T <: Comparable[T] with Serializable with Clonable`
* 可以定义多个视图界定:`T <% Comparable[T] <% String`
* 可以定义多个上下文界定:`T : Ordering : Manifest`

####约束类型
总共有三种关系可供使用:

* T =:= U
* T <:< U
* T <%< U

这些约束将会测试T是否等于U，是否为U的子类型，能否被视图(隐式)转换为U。对比类型变量界定中的例子：

{% highlight scala %}
class Pair[T](val first : T, val second : T)(implicit ev : T <:< Comparable[T] ) {
  def smaller = if (first.compareTo(second) < 0) first else second
}
{% endhighlight %}

这个例子并没有看出`类型约束`相比于类型变量界定有和优势。这里给出两个用途。用途一类型约束让你可以在泛型类中定义只能在特定条件下使用的方法:

{% highlight scala %}
class Pair[T](val first : T, val second : T) {
  def smaller(implicit ev : T <:< Comparable[T] ) = if (first.compareTo(second) < 0) first else second
}
{% endhighlight %}

你可以构造Pair[File]，尽管File不带先后次序。只有当你调用smaller的时候才会报错。一个更明显的例子是Option类的orNull方法：

{% highlight scala %}
val m = Map("a"->1,"b"->2)
val mOpt = m.get("c") //  Option[Int]
val mOrNull = mOpt.orNull // Compile error!
{% endhighlight %}

在和Java代码打交道时，orNull方法很有用，因为Java中通常用null表示缺少某值。不过这种做法并不适用于值类型，比如Int。因为orNull的实现带有约束Null <:< A，你仍然可以实例化Option[Int]，只有不要调用orNull。

类型约束的另一个用途是改进类型的推断:

{% highlight scala %}
def firstLast[A, C <: Iterable[A]](it: C) = (it.head, it.last)
  
firstLast(List(1,2,3)) // Compile error
{% endhighlight %}

这里过不去，是因为推断出的类型参数[Nothing, List[Int]]不符合[A, C <: Iterable[A]]。为什么是Nothing？类型推断器单凭List(1,2,3)无法判断出A是什么，因为它是在同一个步骤中匹配到A和C的。要解决这个问题，首先匹配C，然后再匹配A:
{% highlight scala %}
def firstLast[A, C](it: C)(implicit ev : C <:< Iterable[A]) = (it.head, it.last)
  
firstLast(List(1,2,3)) // Compile error
{% endhighlight %}

####协变
假定一个函数`def makePair(p : Pair[Person])`，如果Student是Person的子类，是否可以传递Pair[Student]作为形参？理论上是不可以的，因为即使Student是Person的子类，但Pair[Student]和Pair[Person]之间没有任何关系。可以定义:

{% highlight scala %}
class Pair[+T](val first : T, val second : T)
{% endhighlight %}

+号意味着该类型是与T`协变`的，也就是说它与T按同样的方向型变。由于Student是Person的子类，那么Pair[Student]就是Pair[Person]的子类了。也可以有另一方向的协变，考虑Friend[T],表示希望与类型T的人称为朋友的人:

{% highlight scala %}
trait Friend[-T] {
  def befriend(someone : T)
}

object Run extends App {
  class Person extends Friend[Person]
  class Student extends Person
  
  def makeFriendWith(s:Student, f:Friend[Student]) {f.befriend(s)}
  
  val jeff = new Student
  val kean = new Person
  
  makeFriendWith(jeff, kean) // OK
}
{% endhighlight %}

注意类型变化的方向和子类型方向是相反的。Student是Person的子类型，但Friend[Student]是Friend[Person]的超类型。在这种情况下，需要将类型参数声明为`逆协变`。

通常而言，对于某个对象消费的值适用逆变，而对于它产出的值则适用协变。如果一个对象同时消费和产出某值，则类型应该保持不变。在scala中数组是不支持型变的。又如下面这个例子会报错:

{% highlight scala %}
class Pair[+T](var fisrt: T, var second :T) // Error - covariant type T occurs in contravariant position in type T of value fisrt_=
{% endhighlight %}

说`first_=(value:T)`协变的类型T出现在了`逆变点`。考虑另一个例子。

{% highlight scala %}
class Pair[+T](val fisrt: T, val second :T) {
  def replaceFirst(newFirst : T) = new Pair[T](newFirst, second) // covariant type T occurs in contravariant position in type T of value newFirst
}
{% endhighlight %}

编译器拒绝上述代码，因为类型T出现在了逆变点。但是这个方法不可能会破坏原本的对偶——它返回一个新的对偶。解决方法是给方法加上另一个类型参数:

{% highlight scala %}
class Pair[+T](val fisrt: T, val second :T) {
  def replaceFirst[R >: T](newFirst : R) = new Pair[R](newFirst, second)
}
{% endhighlight %}

####对象不能泛型
{% highlight scala %}
abstract class List[+T] {
  def isEmpty: Boolean
  def head : T
  def tail : List[T]
}

class Node[T] (val head : T, val tail : List[T]) extends List[T] {
  def isEmpty = false
}

class Empty[T] extends List[T] {
  def isEmpty = true
  def head = throw new UnsupportedOperationException
  def tail = throw new UnsupportedOperationException
}

//object Empty[T] extends List[T] // Error
object Empty extends List[Nothing] {
  def isEmpty = true
  def head = throw new UnsupportedOperationException
  def tail = throw new UnsupportedOperationException
}
{% endhighlight %}

将Empty定义成类看上去很傻。因为它没有状态。但是你无法简单地将它变成对象。你不能将参数化的类型添加到对象。解决的办法继承List[Nothing]。Nothing类型是所有类型的子类型。

####类型通配符
{% highlight scala %}
class Pair[T](var first : T, var second : T) 
def makeFriends(p : Pair[_ :< Person]) // could call Pair[Student]

import java.util.Comparator
def min[T](p : Pair[T])(comp: Comparator[_ >: T])
{% endhighlight %}

####隐式转换
所谓`隐式转换函数`(implicit conversion function)指的是那种以implicit关键字声明的带有单个参数的函数。
{% highlight scala %}
implicit def int2Frac(n:Int) = Fraction(n,1)
val res = 3 * Fraction(4,5) // call Fraction(3)
{% endhighlight %}

scala会考虑如下的隐式转换函数：

* 位于源或目标类型的伴生对象中的隐式函数(我们可以把int2Frac放到Fraction的伴生对象中)
* 位于当前作用域可以以单个标识符指代的隐式函数(如`import scala.collection.JavaConversions._`)

隐式转换在如下三种情况下被考虑：

* 当表达式的类型与预期的类型不同,`sqrt(Fraction(1,4)) `，将调用frac2Double，因为sqrt预期的是一个Double
* 当对象访问一个不存在的成员时,`new File("j.txt").read`,将调用file2RichFile，因为File没有read方法
* 当对象调用某个方法，而该方法的参数声明与传入的参数不匹配时,`3 * Fraction(4,5)`,将调用int2Frac，因为Int的*方法不接受Fraction作为参数

####隐式参数
函数或方法可以带有一个标记为impilicit的参数列表。在这种情况下，编译器将会查找缺省值，提供给该函数或方法。编译器会在如下两个地方查找:

* 在当前作用域所有可以用单个标识符指代的满足类型要求的val和def
* 与所要求类型相关联的类型的伴生对象。相关联的类型包括所要求类型本身，以及它的类型参数(如果它是一个参数化的类型的话)
{% highlight scala %}
case class Delimiters(left:String, right:String)

object Main {
  implicit val quoteDelim = Delimiters("(", ")")
    
  def quote(what:String)(implicit delims:Delimiters) = delims.left + what + delims.right
    
  quote("Hi")(Delimiters("<", ">")) // 柯里化
  quote("Hi") //尝试查找Delimiters的隐式值
} 
{% endhighlight %}

隐式的函数参数也可以被用做隐式转换。参考上面`上下文界定`中的内容。
{% highlight scala %}
def smaller[T](a:T, b:T) = if (a < b) a else b //Error!!!    
def smaller[T](a:T, b:T)(implicit order: T => Ordered[T]) = if (a < b) a else b
{% endhighlight %}

在上面`约束类型`中也使用了隐式参数，=:=,<:<,<%<是带有隐式值的类，定义在Predef对象中。 <:<从本质上将就是:
{% highlight scala %}
abstract class <:<[-From, +To] extends Function1[From, To]

object <:< {
  implicit def conforms[A] = new (A <:< A) {def apply(x:A) = x}
}
{% endhighlight %}
