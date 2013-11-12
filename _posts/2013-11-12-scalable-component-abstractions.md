---
layout: post
title: "Scalable Component Abstractions"
description: ""
category: tech
tags: [scala]
---
{% include JB/setup %}

paper review 62 [Scalable Component Abstractions][1]
<!--break-->

####62 [Scalable Component Abstractions][1]

Ideally, it should be possible to lift an arbitrary system of software components with static data and hard references, resulting in a system with the same structure, but with neither static data nor hard references. The result of such a lifting should create components that are first-class values. We have identified three programming language abstractions that enable such liftings.

* **Abstract type members** provide a flexible way to abstract over concrete types of components. Abstract types can hide information about internals of a component, similar to their use in SML signatures. In an object-oriented framework where classes can be extended by inheritance, they may also be used as a flexible means of parameterization (often called family polymorphism).
* **Selftype annotations** allow one to attach a programmer-defined type to this. This turns out to be a convenient way to express required services of a component at the level where it connects with other components.
* **Modular mixin composition** provides a flexible way to compose components and component types. Unlike functor applications, mixin compositions can establish recursive references between cooperating components. No explicit wiring between provided and required services is needed. Services are modelled as component members. Provided and required services are matched by name and therefore do not have to be associated explicitly by hand.

#####62.1 CONSTRUCTS FOR COMPONENT ABSTRACTION AND COMPOSITION
#####62.1.1 Abstract Type Members

{% highlight scala %}
abstract class AbsCell { 
  type T;  val init: T;  private var value: T = init;  def get: T = value;  def set(x: T): unit = { value = x }}
{% endhighlight %}

It has an `abstract type member` T and an abstract value member init. Instances of that class can be created by implementing these abstract members with concrete definitions in subclasses. The following program shows how to do this in Scala using an *anonymous class*.

{% highlight scala %}
val cell = new AbsCell { type T = int; val init = 1 } 
cell.set(cell.get * 2)
{% endhighlight %}

#####62.1.2 Path-dependent types

{% highlight scala %}
def reset(c: AbsCell): unit = c.set(c.init);
{% endhighlight %}

In the example above, the expression c.init has type c.T, and the method c.set has function type c.T => unit. Since the formal parameter type and the concrete argument type coincide, the method call is type-correct.

c.T is an instance of a `path-dependent type`. In general, such a type has the form x0. ... .xn.t, where n ≥ 0, x0 denotes an immutable value, each subsequent xi denotes an immutable field of the path prefix x0 . . . . .xi−1 , and t denotes a type member of the path x0. . . . .xn. 

Path-dependent types rely on the immutability of the prefix path.

{% highlight scala %}
var flip = false; def f(): AbsCell = {  flip = !flip;  if (flip) new AbsCell { 
    type T = int; val init = 1 
  } else new AbsCell { 
    type T = String; val init = "" 
  }}
f().set(f().get) // illegal!{% endhighlight %}

#####62.1.3 Type selection and singleton types
In Scala, this type is also expressible, in the form of Outer#Inner, where Outer is the name of the outer class in which class Inner is defined. The "#" operator denotes a `type selection`.

In fact, path dependent types can be expanded to type selections. The path dependent type p.t is taken as a short-hand for p.type#t. Here, p.type is a `singleton type`, which represents just the object denoted by p.

{% highlight scala %}
class C {  protected var x = 0;  def incr: this.type = { x = x + 1; this }}class D extends C {  def decr: this.type = { x = x - 1; this } 
}
{% endhighlight %}

Then we can chain calls to the incr and decr method, as in

{% highlight scala %}
val d = new D; 
d.incr.decr;
{% endhighlight %}

Without the singleton type *this.type*, this would not have been possible, since d.incr would be of type C, which does not have a decr member. 

#####62.1.4 Parameter bounds

{% highlight scala %}
abstract class Ordered { 
  type O;  def < (that: O): boolean; 
  def <= (that: O): boolean = this < that || this == that 
}
{% endhighlight %}

The new cell class can be defined in a generic way using `bounded type abstraction`:

{% highlight scala %}
abstract class MaxCell extends AbsCell { 
  type T <: Ordered { type O = T }  def setMax(x: T) = if (get < x) set(x)}
{% endhighlight %}

#####62.2 Modular Mixin Composition

{% highlight scala %}
trait AbsIterator { 
  type T;  def hasNext: boolean;  def next: T; 
}
{% endhighlight %}

A `trait` is a special form of an abstract class which does not have any value parameters for its constructor. Traits can be used in all contexts where other abstract classes appear; however **only traits can be used as mixins**.

{% highlight scala %}
trait RichIterator extends AbsIterator { 
  def foreach(f: T => unit): unit =    while (hasNext) f(next);}
{% endhighlight %}

The parameter f has type T => unit, i.e. it is a function that takes arguments of type T and returns results of the trivial type unit.

{% highlight scala %}
class StringIterator(s: String) extends AbsIterator { 
  type T = char;  private var i = 0;  def hasNext = i < s.length(); 
  def next={val x=s.charAt(i); i=i+1; x}}
{% endhighlight %}

Scala provides a `mixin-class composition mechanism` which allows programmers to reuse the delta of a class definition, i.e., all new definitions that are not inherited. This mechanism makes it possible to combine RichIterator with StringIterator.

{% highlight scala %}
object Test {  def main(args: Array[String]): unit = {    class Iter extends StringIterator(args(0)) with RichIterator;    val iter = new Iter;    iter foreach System.out.println 
  }}
{% endhighlight %}

**Definition 2.1 Class Linearization** Let C be a class with parents Cn with ... with C1 . The `class linearization` of C , L(C ) is defined as follows:
    L(C) = {C} +⃗ L(C1) +⃗ ... +⃗ L(Cn)

Here +⃗ denotes concatenation where elements of the right operand replace identical elements of the left operand. For instance, the linearization of class Iter is

    { Iter, RichIterator, StringIterator, AbsIterator, AnyRef, Any }

The Iter class inherits members from both StringIterator and RichIterator. Generally, a class derived from a mixin composition Cn with ... with C1 can define members itself and can inherit members from all parent classes.

**Definition 2.2 Membership** A member definition M **matches** a member definition M′, if M and M′ bind the same name, and one of following holds.

1. Neither M nor M′ is a method definition.
2. M and M′ define both monomorphic methods with equal argument types.
3. M and M′ define both polymorphic methods with equal number of argument types T , T ′ and equal numbers of type parameters t, t′, say, and T′ = [t′/t]T.

**Definition 2.3** A `concrete member` of a class C is any concrete definition M in some class Ci ∈ L(C), except if there is a preceding class Cj ∈ L(C) where j < i which defines a concrete member M′ matching M. An `abstract member` of a class C is any abstract definition M in some class Ci ∈ L(C), except if C contains already a concrete member M′ matching M, or if there is a preceding class Cj ∈ L(C) where j < i which defines an abstract member M′ matching M.

**Definition 2.4 Super calls** Consider an expression super.M in a base class C of D. To be type correct, this expression must refer statically to some member M of a parent class of C. In the context of D, the same expression then refers to a member M ′ which matches M , and which appears in the first possible class that follows C in the linearization of D.

{% highlight scala %}
abstract class SyncIterator extends AbsIterator { 
  abstract override def hasNext: boolean = synchronized(super.hasNext);
  abstract override def next: T = synchronized(super.next);
}

StringIterator(someString) with SyncIterator
                          with RichIterator
{% endhighlight %}

#####62.3 Selftype Annotations

Each of the operands of a mixin composition C0 with ... with Cn, must refer to a class. **The mixin composition mechanism does not allow any Ci to refer to an abstract type**. This restriction makes it possible to statically check for ambiguities and override confiicts at the point where a class is composed. Scala's **selftype annotations provide an alternative way of associating a class with an abstract type**.

{% highlight scala %}
abstract class Graph { 
  type Node <: BaseNode; 
  class BaseNode {    def connectWith(n: Node): Edge = new Edge(this, n); // illegal!  }  class Edge(from: Node, to: Node) {    def source() = from;    def target() = to; 
  }}
{% endhighlight %}

The abstract Node type is upper-bounded by BaseNode to express that we want nodes to support a connectWith method. This method creates a new instance of class Edge which links the receiver node with the argument node. Unfortunately, this code does not compile, because the type of the self reference this is BaseNode and therefore does not conform to type Node which is expected by the constructor of class Edge.

{% highlight scala %}
abstract class Graph {  type Node <: BaseNode; 
  abstract class BaseNode {    def connectWith(n: Node): Edge = new Edge(self, n);    def self: Node; 
  }  class Edge(from: Node, to: Node) { ... } 
}
{% endhighlight %}

This version of class BaseNode uses **an abstract method self** for expressing its identity as type Node. Concrete subclasses of Graph have to define a concrete Node class for which it is possible to implement method self.

{% highlight scala %}
class LabeledGraph extends Graph {  class Node(label: String) extends BaseNode {    def getLabel: String = label;    def self: Node = this; 
  }}
{% endhighlight %}

Scala supports a mechanism for specifying the type of this explicitly. Such an `explicit selftype annotation` is used in the following version of class Graph:

{% highlight scala %}
abstract class Graph {  type Node <: BaseNode;  class BaseNode requires Node {    def connectWith(n: Node): Edge = new Edge(this, n); 
  }  class Edge(from: Node, to: Node) { 
    def source() = from;    def target() = to;  } 
}
{% endhighlight %}

In the declaration


    class BaseNode requires Node { ...

Node is called the `selftype` of class BaseNode.

[1]: http://lampwww.epfl.ch/~odersky/papers/ScalableComponent.pdf
