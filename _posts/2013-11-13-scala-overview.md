---
layout: post
title: "Scala Overview"
description: ""
category: 编程
tags: [scala]
---
{% include JB/setup %}

paper review 63 [An Overview of the Scala Programming Language][1]
<!--break-->

##63 [An Overview of the Scala Programming Language][1]

##63.1 A Unified Object Model

####63.1.1 Classes

* Scala所有的类都继承自类 `Scala.Any`. 
* Any 的所有子类分成两类: 值类继承自 `scala.AnyVal` ，引用类继承自 `scala.AnyRef`. 
* 每一个Java的primitive类型都对应一个值类, 并且都映射到一个预先定义好的类型别名。在Java中, AnyRef 等同于 java.lang.Object.

####63.1.2 Operations

{% highlight scala %}
abstract class Nat {  def isZero: boolean  def pred: Nat  def succ: Nat = new Succ(this) 
  def + (x: Nat): Nat = if (x.isZero) this else succ + x.pred 
  def - (x: Nat): Nat = if (x.isZero) this else pred - x.pred 
}
{% endhighlight %}

现在我们继承类 Nat 实现一个单例对象 Zero 和一个子类 Succ.

{% highlight scala %}
object Zero extends Nat {  def isZero: boolean = true  def pred: Nat = throw new Error("Zero.pred") 
  override def toString: String = "Zero"}
class Succ(n: Nat) extends Nat {  def isZero: boolean = false  def pred: Nat = n  override def toString: String = "Succ("+n+")"}
{% endhighlight %}

在Scala中, 构造函数的参数紧跟在类名之后;可以看到在类Succ中没有单独的构造函数定义体存在。 此构造函数被称为 `primary constructor`; 类中的所有语句在类被实例化调用rimary constructor的时候即执行了。当需要多于一个构造函数的情况时，可以使用 `secondary constructors` 。

####63.1.3 Variables and Properties

Scala按如下方式定义 setter 和 getter 方法。

{% highlight scala %}
def x: Tdef x_= (newval: T): unit
{% endhighlight %}

##63.2 Operations Are Objects

####63.2.1 Methods are Functional Values

{% highlight scala %}
def exists[T](xs: Array[T], p: T => boolean) = { 
  var i: int = 0  while (i < xs.length && !p(xs(i))) i = i + 1  i < xs.length}
{% endhighlight %}

类型p 是函数类型T => boolean, 它定义定义域为T且值为boolean的所有函数。使用函数为参数或者返回函数的所有函数被称为 `higher-order functions`:

{% highlight scala %}
def forall[T](xs: Array[T], p: T => boolean) = { 
  def not_p(x: T) = !p(x)  !exists(xs, not_p)}
{% endhighlight %}

可以定义没有名字的函数:

{% highlight scala %}
def forall[T](xs: Array[T], p: T => boolean) = !exists(xs, (x: T) => !p(x))
{% endhighlight %}

这里, (x: T) => !p(x) 被定义为 `anonymous function` 。使用 exists 和 forall, 我们可以定义函数 hasZeroRow：

{% highlight scala %}
def hasZeroRow(matrix: Array[Array[int]]) = 
  exists(matrix, (row: Array[int]) => forall(row, 0 ==))
{% endhighlight %}

####63.2.2 Functions are Objects
函数类型S => T等价于一个参数化的类scala.Function1[S, T]，它在标准Scala的库中定义如下：

{% highlight scala %}
package scalaabstract class Function1[-S, +T] {  def apply(x: S): T 
}
{% endhighlight %}

In general, the n-ary function type, (T1, T2, ..., Tn) => T is interpreted as Functionn[T1, T2, ..., Tn, T]. Hence, functions are interpreted as objects with apply methods. For example, the anonymous “incrementer” function x: int => x + 1 would be expanded to an instance of Function1 as follows.

{% highlight scala %}
new Function1[int, int] {  def apply(x: int): int = x + 1}
{% endhighlight %}

####63.2.3 Refining Functions
Class Array[T] inherits from Function1[int, T], and adds methods for array update and array length, among others:

{% highlight scala %}
package scalaclass Array[T] extends Function1[int, T]                    with Seq[T] { 
  def apply(index: int): T = ...  def update(index: int, elem: T): unit= ... 
  def length: int = ...
  def exists(p: T => boolean): boolean = ... 
  def forall(p: T => boolean): boolean = ... 
  ...}
{% endhighlight %}

Special syntax exists for function applications appearing on the left-hand side of an assignment; these are interpreted as applications of an update method. For instance, the assignment a(i) = a(i) + 1 is interpreted as

    a.update(i, a.apply(i) + 1) .

The above definition of the Array class also lists methods exists and forall. Hence, it would not have been necessary to define these operations by hand:

{% highlight scala %}
def hasZeroRow(matrix: Array[Array[int]]) = 
  matrix exists (row => row forall (0 ==))
{% endhighlight %}

####63.2.4 Sequences

{% highlight scala %}
def sqrts(xs: List[double]): List[double] = 
  xs filter (0 <=) map Math.sqrt
{% endhighlight %}

####63.2.5 For Comprehensions
{% highlight scala %}
def sqrts(xs: List[double]): List[double] = 
  for (val x <- xs; 0 <= x) yield Math.sqrt(x)
{% endhighlight %}

Here, val x <- xs is a `generator`, which produces a sequence of values, and 0 <= x is a `filter`, which eliminates some of the produced values from consideration. The comprehension returns another sequence formed from the values produced by the yield part.

##63.3 Abstraction

####63.3.1 Functional Abstraction

{% highlight scala %}
class GenCell[T](init: T) {  private var value: T = init  def get: T = value  def set(x: T): unit = { value = x }}
def swap[T](x: GenCell[T], y: GenCell[T]): unit = { 
  val t = x.get; x.set(y.get); y.set(t)
}

val x: GenCell[int] = new GenCell[int](1) 
val y: GenCell[int] = new GenCell[int](2) 
swap[int](x, y)
{% endhighlight %}

Type arguments of a method or constructor are **inferred from the expected result type and the argument types by local type inference**. Hence, one can equivalently write the example above without any type arguments:

{% highlight scala %}
val x = new GenCell(1) 
val y = new GenCell(2) 
swap(x, y)
{% endhighlight %}

**Parameter bounds.**

{% highlight scala %}
trait Ordered[T] {  def < (x: T): boolean}
def updateMax[T <: Ordered[T]](c: GenCell[T], x: T) = 
  if (c.get < x) c.set(x)
{% endhighlight %}

Here, the type parameter clause [T <: Ordered[T]] introduces a `bounded type parameter` T. It restricts the type arguments for T to those types T that are a subtype of Ordered[T].

**Variance**. The combination of subtyping and generics in a language raises the question how they interact. If C is a type constructor and S is a subtype of T, does one also have that C[S] is a subtype of C[T]? Type constructors with this property are called `covariant`.

Scala allows to declare the variance of the type parameters of a class using plus or minus signs. A "+" in front of a parameter name indicates that the constructor is `covariant` in the parameter, a "−" indicates that it is `contravariant`, and a missing prefix indicates that it is `non-variant`.

{% highlight scala %}
abstract class GenList[+T] { 
  def isEmpty: boolean  def head: T  def tail: GenList[T]}
{% endhighlight %}

**Binary methods and lower bounds**.

{% highlight scala %}
abstract class GenList[+T] { ...
  def prepend(x: T): GenList[T] =  // illegal!
    new Cons(x, this)
}
{% endhighlight %}

However, this is not type-correct, since now the type parameter T appears in contravariant position inside class GenList. Therefore, it may not be marked as covariant. This is a pity since conceptually immutable lists should be covariant in their element type. The problem can be solved by generalizing prepend using a lower bound:

{% highlight scala %}
abstract class GenList[+T] { ...  def prepend[S >: T](x: S): GenList[S] = // OK    new Cons(x, this) 
}
{% endhighlight %}

prepend is now a polymorphic method which takes an argument **of some supertype S** of the list element type, T. It returns a list with elements of that supertype.

####63.3.2 Abstract Members

{% highlight scala %}
abstract class AbsCell { 
  type T  val init: T  private var value: T = init  def get: T = value  def set(x: T): unit = { value = x }}
val cell = new AbsCell { type T = int; val init = 1 } 
cell.set(cell.get * 2)
{% endhighlight %}

**Path-dependent types**. It is also possible to access AbsCell without knowing the binding of its type member.

{% highlight scala %}
def reset(c: AbsCell): unit = c.set(c.init)
{% endhighlight %}

**Type selection and singleton types**. Outer # Inner, where Outer is the name of the outer class in which class Inner is defined. The "#" operator denotes a `type selection`.

In fact, `path dependent types` in Scala can be expanded to type selections. The path dependent type p.t is taken as a shorthand for p.type # t. Here, p.type is a `singleton type`, which represents just the object denoted by p.

{% highlight scala %}
class C {  protected var x = 0  def incr: this.type = { x = x + 1; this }}
class D extends C {  def decr: this.type ={x=x-1;this}
}

val d = new D; 
d.incr.decr{% endhighlight %}

Without the singleton type this.type, this would not have been possible, since d.incr would be of type C, which does not have a decr member. 

**Family polymorphism and self types**.

{% highlight scala %}
abstract class SubjectObserver {  type S <: Subject  type O <: Observer
  abstract class Subject requires S {    private var observers: List[O] = List() 
    def subscribe(obs: O) = observers = obs :: observers 
    def publish = for (val obs <- observers) obs.notify(this)  }  trait Observer {    def notify(sub: S): unit  }}
{% endhighlight %}

    abstract class Subject requires S { ...

Here, S is called a `self-type` of class Subject. When a self-type is given, it is taken as the type of this inside the class (without a self-type annotation the type of this is taken as usual to be the type of the class itself). In class Subject, the self-type is necessary to render the call obs.notify(this) type-correct.

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

Assume you have a parameterized class C with a type parameter t (the encoding generalizes straightforwardly to multiple type parameters). The encoding has four parts, which affect the class definition itself, instance creations of the class, base class constructor calls, and type instances of the class.

1. The class definition of C is re-written as follows.

{% highlight scala %}
class C {
  type t
  /* rest of class */
}
{% endhighlight %}

2. Every instance creation new C[T] with type argument T is rewritten to:

{% highlight scala %}
new C { type t = T }
{% endhighlight %}

3. If C[T] appears as a superclass constructor, the inheriting class is augmented with the definition

{% highlight scala %}
type t = T
{% endhighlight %}

4. Every type C[T] is rewritten to one of the following types which each augment class C with a refinement.

{% highlight scala %}
C  { type t = T } //if t is declared non-variant,
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
  def eval: int}class Num(x: int) extends Term {  def eval: int = x 
}class Plus(left: Term, right: Term) extends Term { 
  def eval: int = left.eval + right.eval}
{% endhighlight %}

####63.5.2 Pattern Matching Over Class Hierarchies

{% highlight scala %}
abstract class Termcase class Num(x: int) extends Termcase class Plus(left: Term, right: Term) extends Term
object Interpreter {  def eval(term: Term): int = term match {    case Num(x) => x    case Plus(left, right) => eval(left) + eval(right) 
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
  def unit: a}
object Monoids {  object stringMonoid extends Monoid[String] {    def add(x: String, y: String): String = x.concat(y) 
    def unit: String = ""  }  object intMonoid extends Monoid[int] {    def add(x: Int, y: Int): Int = x + y    def unit: Int = 0 
  }}
def sum[a](xs: List[a])(m: Monoid[a]): a = 
  if (xs.isEmpty) m.unit  else m.add(xs.head, sum(xs.tail)(m))
{% endhighlight %}

One invokes this sum method by code such as:

{% highlight scala %}
sum(List("a", "bc", "def"))(Monoids.stringMonoid)
sum(List(1, 2, 3))(Monoids.intMonoid)
{% endhighlight %}

**Implicit Parameters: The Basics**. We would sometimes wish that the system could figure out the correct arguments automatically, similar to what is done when type arguments are inferred. This is what implicit parameters provide.

{% highlight scala %}
def sum[a](xs: List[a])(implicit m: Monoid[a]): a = 
  if (xs.isEmpty) m.unit  else m.add(xs.head, sum(xs.tail))
implicit object stringMonoid extends Monoid[String] { 
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
  def contains(x: T): boolean}
implicit def listToSet[T](xs: GenList[T]): Set[T] = new Set[T] {  def include(x: T): Set[T] = 
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