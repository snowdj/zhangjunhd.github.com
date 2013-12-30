---
layout: post
title: "Scala Overview"
description: "paper review 63.An Overview of the Scala Programming Language"
category: 编程
tags: [scala]
---
{% include JB/setup %}

##63 [An Overview of the Scala Programming Language][1]

##63.1 A Unified Object Model

####63.1.1 Classes

* Scala所有的类都继承自类 `Scala.Any`. 
* Any 的所有子类分成两类: 值类继承自 `scala.AnyVal` ，引用类继承自 `scala.AnyRef`. 
* 每一个Java的primitive类型都对应一个值类, 并且都映射到一个预先定义好的类型别名。AnyRef 等同于 java.lang.Object.

####63.1.2 Operations

{% highlight scala %}
abstract class Nat {  def isZero: Boolean  def pred: Nat  def succ: Nat = new Succ(this) 
  def + (x: Nat): Nat = if (x.isZero) this else succ + x.pred 
  def - (x: Nat): Nat = if (x.isZero) this else pred - x.pred 
}
{% endhighlight %}

现在我们继承类 Nat 实现一个单例对象 Zero 和一个子类 Succ.

{% highlight scala %}
object Zero extends Nat {  def isZero: Boolean = true  def pred: Nat = throw new Error("Zero.pred") 
  override def toString: String = "Zero"}
class Succ(n: Nat) extends Nat {  def isZero: Boolean = false  def pred: Nat = n  override def toString: String = "Succ("+n+")"}
{% endhighlight %}

在Scala中, 构造函数的参数紧跟在类名之后;可以看到在类Succ中没有单独的构造函数定义体存在。 此构造函数被称为 `primary constructor`; 类中的所有语句在类被实例化调用primary constructor的时候即执行了。当需要多于一个构造函数的情况时，可以使用 `secondary constructors` 。

####63.1.3 Variables and Properties

Scala按如下方式定义 setter 和 getter 方法。

{% highlight scala %}
def x: Tdef x_= (newval: T): Unit
{% endhighlight %}

##63.2 Operations Are Objects

####63.2.1 Methods are Functional Values

{% highlight scala %}
def exists[T](xs: Array[T], p: T => Boolean) = { 
  var i: Int = 0  while (i < xs.length && !p(xs(i))) i = i + 1  i < xs.length}
{% endhighlight %}

类型p 是函数类型T => boolean, 它定义定义域为T且值为boolean的所有函数。使用函数为参数或者返回函数的所有函数被称为 `higher-order functions`:

{% highlight scala %}
def forall[T](xs: Array[T], p: T => Boolean) = { 
  def not_p(x: T) = !p(x)  !exists(xs, not_p)}
{% endhighlight %}

可以定义匿名的函数:

{% highlight scala %}
def forall[T](xs: Array[T], p: T => boolean) = !exists(xs, (x: T) => !p(x))
{% endhighlight %}

这里, (x: T) => !p(x) 被定义为 `anonymous function` 。使用 exists 和 forall, 我们可以定义函数 hasZeroRow：

{% highlight scala %}
def hasZeroRow(matrix: Array[Array[Int]]) = 
  exists(matrix, (row: Array[Int]) => forall(row, 0 ==)) //compile error!
{% endhighlight %}

####63.2.2 Functions are Objects
函数类型S => T等价于一个参数化的类scala.Function1[S, T]，它在标准Scala的库中定义如下：

{% highlight scala %}
package scalaabstract class Function1[-S, +T] {  def apply(x: S): T 
}
{% endhighlight %}

一般情况下，n元函数类型，(T1, T2, ..., Tn) => T，被认为是 Functionn[T1, T2, ..., Tn, T]。即，函数被认为是带有apply方法的对象。例如，匿名函数“incrementer” x: int => x + 1 将被扩展成如下Function1 的一个实例。

{% highlight scala %}
new Function1[int, Int] {  def apply(x: Int): Int = x + 1}
{% endhighlight %}

####63.2.3 Refining Functions
类Array[T]继承自Function1[int, T], 并加入方法用于更新数组和得到数组大小:

{% highlight scala %}
package scalaclass Array[T] extends Function1[Int, T]                    with Seq[T] { 
  def apply(index: Int): T = ...  def update(index: Int, elem: T): Unit = ... 
  def length: Int = ...
  def exists(p: T => Boolean): Boolean = ... 
  def forall(p: T => Boolean): Boolean = ... 
  ...}
{% endhighlight %}

在函数中，update方法用于赋值等号左侧。例如，赋值语句a(i) = a(i) + 1 被解释为

    a.update(i, a.apply(i) + 1) .

####63.2.4 Sequences

{% highlight scala %}
def sqrts(xs: List[Double]): List[Double] =
    xs.filter(0 <=).map(Math.sqrt)
{% endhighlight %}

这里`filter`过滤掉了小于0的数。

####63.2.5 For Comprehensions
{% highlight scala %}
def sqrts(xs: List[double]): List[double] = 
  for (val x <- xs; 0 <= x) yield Math.sqrt(x)
{% endhighlight %}

这里, val `x <- xs` 是一个 `generator`, 它会产生一组序列, `0 <= x` 是一个 `filter`, 它把小于0的值过滤掉。 最终由`yeild`产生一个新的序列。

##63.3 Abstraction

####63.3.1 Functional Abstraction

{% highlight scala %}
class GenCell[T](init: T) {
    private var value: T = init
    def get: T = value
    def set(x: T): Unit = { value = x }
}

def swap[T](x: GenCell[T], y: GenCell[T]): Unit = {
    val t = x.get; x.set(y.get); y.set(t)
}

val x: GenCell[Int] = new GenCell[Int](1)
val y: GenCell[Int] = new GenCell[Int](2)
swap[Int](x, y)
{% endhighlight %}

类的方法和构造函数的类型参数对应的实际类型，可以通过局部类型推理（`local type inference`）根据预期的返回值以及参数类型推理出来。因此，上面的程序可以写成这种省略参数类型的方式：:

{% highlight scala %}
val x = new GenCell(1) 
val y = new GenCell(2) 
swap(x, y)
{% endhighlight %}

受限类型参数

{% highlight scala %}
trait Ordered[T] {  def < (x: T): Boolean}def updateMax[T <: Ordered[T]](c: GenCell[T], x: T) = 
  if (c.get < x) c.set(x)
{% endhighlight %}

这里，类型参数定义子句[T <: Ordered[T]]引入了受限类型参数T(`bounded type parameter`)，它限定参数类型T必须是Ordered[T]的子类型。这样，“<”操作符就可以应用于类型为T的参数了。同时，这个例子还展现出一个受限参数类型本身可以作为其限定类型的一部分，也就是说Scala支持F-受限多态（`F-bounded polymorphism`）。

协变性（`Variance`）泛型和子类型（`subtyping`）组合在一起产生这样一个问题：它们如何相互作用。如果C是一个类型构造子（`type constructor`），S是T的一个子类，那么C[S]是不是也是C[T]的子类呢？我们把有这种特性的类型构造子称为协变的（`covariant`）。

Scala允许通过“+/-”定义类型参数的协变性，用“+”放在类型参数前表示构造子对于该参数是协变的(`covariant`)，“-”则表示逆协变(`contravariant`)，没有任何符号则表示非协变(`non-variant`)。

{% highlight scala %}
abstract class GenList[+T] { 
  def isEmpty: Boolean  def head: T  def tail: GenList[T]}
{% endhighlight %}

二元操作(`Binary methods`)和参数下界(`lower bounds`)。为GenList类增加一个prepend（前追加）方法，最自然的做法是将其定义成为接收一个相应的list元素类型参数：

{% highlight scala %}
abstract class GenList[+T] { ...
  def prepend(x: T): GenList[T] =  // illegal!
    new Cons(x, this)
}
{% endhighlight %}

可惜这样做会导致类型错误，因为这种定义使得T在GenList中处于逆协变的位置，从而不能标记为协变参数（+T）。这一点非常遗憾，因为从概念上说不可变的list对于其元素类型而言应该是协变的，不过这个问题可以通过参数下界对prepend方法进行泛化而解决：

{% highlight scala %}
abstract class GenList[+T] { ...  def prepend[S >: T](x: S): GenList[S] = // OK    new Cons(x, this) 
}
{% endhighlight %}

这里prepend是一个多态方法，接收T的某个父类型S作为参数，返回元素类型为S的list。这个定义是合法的，因为参数下界被归类为协变位置，从而T在GenList中只出现在协变位置上。

####63.3.2 Abstract Members

{% highlight scala %}
abstract class AbsCell { 
  type T  val init: T  private var value: T = init  def get: T = value  def set(x: T): Unit = { value = x }}
val cell = new AbsCell { type T = Int; val init = 1 } 
cell.set(cell.get * 2)
{% endhighlight %}

这里，cell的类型是AbsCell { type T = Int }，也就是AbsCell被{ type T = Int }细化（`refinement`）而形成的类型。访问cell值的代码认为其类型别名cell.T=int，因此上面第二条语句是合法的。

路径依赖类型（`Path-dependent types`） 不知道AbsCell绑定的类型情况下，也可以对其进行访问。下面这段代码将一个cell的值恢复成为其初始值（init），而无需关心cell值的类型是什么。

{% highlight scala %}
def reset(c: AbsCell): Unit = c.set(c.init)
{% endhighlight %}

类型选择与单例类型（`Type selection and singleton types`），类型定义可以嵌套，在Scala中，通过“外部类型#内部类型”（Outer#Inner）的方式来表示，“#”就称作类型选择（Type Selection）。从概念上说，这与路径依赖类型（例如：p.Inner）不同，因为p是一个值，不是一个类型。进一步而言，Outer#t也是一个无效表达式，如果t是一个定义在Outer中的抽象类型的话。

实际上，路径依赖类型（`path dependent types`）可以被扩展成为类型选择，p.t可以看做是p.type#t，这里p.type就称作单例类型（`singleton type`），仅代表p所指向对象的类型。单例类型本身对于支持方法调用串接很有作用，考虑如下代码：C有一个incr方法，对其值+1，其子类D由一个decr方法，对其值-1。

{% highlight scala %}
class C {  protected var x = 0  def incr: this.type = { x = x + 1; this }}
class D extends C {  def decr: this.type ={x=x-1;this}
}

val d = new D; 
d.incr.decr{% endhighlight %}

如果没有this.type这个单例类型，上述调用是非法的，因为d.incr的类型应该是C，但C并没有decr方法。

族多态（`Family polymorphism`)和self类型(`self types`）。Scala的抽象类型概念非常适合于描述相互之间协变的一族（families）类型，这种概念称作族多态。

{% highlight scala %}
abstract class SubjectObserver {  type S <: Subject  type O <: Observer
  abstract class Subject requires S {    private var observers: List[O] = List() 
    def subscribe(obs: O) = observers = obs :: observers 
    def publish = for (val obs <- observers) obs.notify(this)  }  trait Observer {    def notify(sub: S): Unit  }}
{% endhighlight %}

Subject和Observer并没有直接引用对方，因为这种“硬”引用将会影响客户代码对这些类进行协变的扩展。相反，SubjectOberver定义了两个抽象类型S和O，分别以Subject和Observer作为上界。Subject和observer的类型分别通过这两个抽象类型引用对方。

    abstract class Subject requires S { ...

这个标注表示Subject类只能作为S的某个子类被实例化，这里S被称作Subject的`self-type`。在定义一个类的时候，如果指定了`self-type`，则这个类定义中出现的所有this都被认为属于这个`self-type`类型，否则被认为是这个类本身。在Subject类中，必须将`self-type`指定为S，才能保证obs.notify(this)调用类型正确。

{% highlight scala %}
object SensorReader extends SubjectObserver { 
  type S = Sensor  type O = Display  abstract class Sensor extends Subject {
    val label: String    var value: double = 0.0    def changeValue(v: double) = {
      value = v
      publish
    }
  }
  
  class Display extends Observer {    def println(s: String) = ... 
    def notify(sub: Sensor) =    println(sub.label + " has value " + sub.value) 
  }}
object Test {  import SensorReader._  val s1 = new Sensor { val label = "sensor1" } 
  val s2 = new Sensor { val label = "sensor2" } 
  
  def main(args: Array[String]) = {    val d1 = new Display
    val d2 = new Display 
    s1.subscribe(d1)
    s1.subscribe(d2) 
    s2.subscribe(d1)    s1.changeValue(2)
    s2.changeValue(3)} }{% endhighlight %}

####63.3.3 Modeling Generics with Abstract Types

用抽象类型建立泛型模型。假定一个参数化类型C有一个类型参数t（可以直接推广到多个类型参数的情况），那么这种表达方式有四个关键组成部分：分别是类型自身的定义、类型实例的创建、基类构造子的调用以及这个类的类型实例（type instances）。

* 类型定义，C的定义可以重写如下：

{% highlight scala %}
class C {
  type t
  /* rest of class */
}
{% endhighlight %}

* 以T为参数创建实例的调用：new C[T]可以写成：

{% highlight scala %}
new C { type t = T }
{% endhighlight %}

* 如果C[T]出现在调用基类构造符的场合，则其子类的定义将会进行如下扩充：

{% highlight scala %}
type t = T
{% endhighlight %}

* 每一个C[T]形式的类型定义都被扩充为如下的细化形式：

{% highlight scala %}
C { type t = T } //if t is declared non-variant,
C { type t <: T } //if t is declared co-variant,
C { type t >: T } //if t is declared contra-variant.{% endhighlight %}

##63.4 Composition

see [Scalable Component Abstractions][2] 62.2 for

* Class Linearization
* Membership
* Super calls

##63.5 Decomposition
####63.5.1 Object-Oriented Decomposition

{% highlight scala %}
abstract class Term { 
  def eval: int}class Num(x: int) extends Term {  def eval: int = x 
}
class Plus(left: Term, right: Term) extends Term { 
  def eval: int = left.eval + right.eval}
{% endhighlight %}

####63.5.2 Pattern Matching Over Class Hierarchies

{% highlight scala %}
abstract class Termcase class Num(x: int) extends Termcase class Plus(left: Term, right: Term) extends Termobject Interpreter {  def eval(term: Term): int = term match {    case Num(x) => x    case Plus(left, right) => eval(left) + eval(right) 
  }}
{% endhighlight %}

##63.6 XML Processing

* Data Model
* Schema Validation
* Sequence Matching
* XML Queries through For Comprehension

##63.7 Component Adaptation

{% highlight scala %}
abstract class SemiGroup[a] { 
  def add(x: a, y: a): a}
abstract class Monoid[a] extends SemiGroup[a] { 
  def unit: a}object Monoids {  object stringMonoid extends Monoid[String] {    def add(x: String, y: String): String = x.concat(y) 
    def unit: String = ""  }  object intMonoid extends Monoid[int] {    def add(x: Int, y: Int): Int = x + y    def unit: Int = 0 
  }}
def sum[a](xs: List[a])(m: Monoid[a]): a = 
  if (xs.isEmpty) m.unit  else m.add(xs.head, sum(xs.tail)(m))
{% endhighlight %}

按如下形式调用sum方法:

{% highlight scala %}
sum(List("a", "bc", "def"))(Monoids.stringMonoid)
sum(List(1, 2, 3))(Monoids.intMonoid)
{% endhighlight %}

`Implicit Parameters`: 

{% highlight scala %}
def sum[a](xs: List[a])(implicit m: Monoid[a]): a = 
  if (xs.isEmpty) m.unit  else m.add(xs.head, sum(xs.tail))implicit object stringMonoid extends Monoid[String] { 
  def add(x: String, y: String): String = x.concat(y) 
  def unit: String = ""}implicit object intMonoid extends Monoid[int] {  def add(x: Int, y: Int): Int = x + y  def unit: Int = 0 
}

sum(List(1, 2, 3))
{% endhighlight %}

The principal idea behind implicit parameters is that arguments for them can be left out from a method call. If the arguments corresponding to an implicit parameter section are missing, they are inferred by the Scala compiler.

The actual arguments that are eligible to be passed to an implicit parameter of type T are all identifiers that denote an implicit definition and which satisfy either one of the following two criteria:

1. The identifier can be accessed at the point of the method call without a prefix. This includes identifiers defined locally or in some enclosing scope, as well as identifiers inherited from base classes or imported from other objects by an import clause.
2. Or the identifier is defined in an object C which comes with a class with the same name which is a baseclass of the type parameter's type T (such object is called a "companion object" of type T).

Implicit methods can themselves have implicit parameters.

{% highlight scala %}
implicit def list2ordered[a](x: List[a]) (implicit elem2ordered: a => Ordered[a]) 
  : Ordered[List[a]] =  ...implicit def int2ordered(x: int): Ordered[int]
def sort(xs: List[a])(implicit a2ord: a => Ordered[a]) = ...
{% endhighlight %}

We can apply sort to a list of lists of integers yss: List[List[int]] as follows:

{% highlight scala %}
sort(yss)
{% endhighlight %}

The Scala compiler will complete the call above by passing two nested implicit arguments:

{% highlight scala %}
sort(yss)((xs: List[int]) => list2ordered[int](xs)(int2ordered))
{% endhighlight %}

**Views** are implicit conversions between types.

{% highlight scala %}
trait Set[T] {  def include(x: T): Set[T] 
  def contains(x: T): boolean}implicit def listToSet[T](xs: GenList[T]): Set[T] = new Set[T] {  def include(x: T): Set[T] = 
    xs prepend x  def contains(x: T): boolean =    !isEmpty && (xs.head == x || (xs.tail contains x))}
{% endhighlight %}

For instance, assume a value xs of type GenList[T] which is used in the following two lines.

{% highlight scala %}
val s: Set[T] = xs
xs contains x
{% endhighlight %}

The compiler would insert applications of the view defined above into these lines as follows:

{% highlight scala %}
val s: Set[T] = listToSet(xs)
listToSet(xs) contains x
{% endhighlight %}

**View Bounds** 
{% highlight scala %}
def maximum[T](xs: List[T])(implicit t2ordered: T => Ordered[T]): unit = {  var mx = xs.head  for (val x <- xs.tail) if (mx < x) mx = x mx}
{% endhighlight %}

This maximum function can be applied to any argument of type List[T], where T is viewable as Ordered[T].

Note that maximum uses a comparison operation (mx < x) on values mx and x of type T. The type parameter T does not have a comparison operation <, but there is the implicit parameter t2ordered which maps T into a type which does. Therefore, the comparison operation is rewritten to (t2ordered(mx) < x).

The situation of associating a generic parameter with implicit views is so common that Scala has special syntax for it. A `view bounded` type parameter such as [T <% U] expresses that T must come equipped with a view that maps its values into values of type U. Using view bounds, the maximum function above can be more concisely written as follows:

{% highlight scala %}
def maximum[T <% Ordered[T]](xs: List[T]): unit = ...
{% endhighlight %}

[1]: http://scala-lang.org/docu/files/ScalaOverview.pdf
[2]: http://zhangjunhd.github.io/2013/11/12/scalable-component-abstractions/