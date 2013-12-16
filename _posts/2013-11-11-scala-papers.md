---
layout: post
title: "Independently Extensible"
description: ""
category: 编程
tags: [scala]
---
{% include JB/setup %}

paper review 61 [Independently Extensible Solutions to the Expression Problem][1]
<!--break-->

####61 [Independently Extensible Solutions to the Expression Problem][1]

The challenge is now to find an implementation technique which satisfies the following list of requirements:

* **Extensibility in both dimensions**: It should be possible to add new data variants and adapt existing operations accordingly. Furthermore, it should be possible to introduce new processors.
* **Strong static type safety**: It should be impossible to apply a processor to a data variant which it cannot handle.
* **No modification or duplication**: Existing code should neither be modified nor duplicated.
* **Separate compilation**: Compiling datatype extensions or adding new processors should not encompass re-type-checking the original datatype or existing processors.
* **Independent extensibility**: It should be possible to combine independently developed extensions so that they can be used jointly.

Implementation techniques which meet the last criterion allow systems to be extended in a `non-linear fashion`. Such techniques typically allow programmers to consolidate independent extensions in a single compound extension as illustrated by Figure 1.

![1](/assets/2013-11-11-scala-papers/scala1.png)

#####61.1 Object-Oriented Decomposition
We evolve a simple datatype for representing arithmetic expressions together with operations on this type by incrementally adding new datatype variants and new operations.

#####61.1.1 Framework

{% highlight scala %}  
trait Base {
  type exp <: Exp

  trait Exp {
    def eval: Int
  }

  class Num(v: Int) extends Exp {
    val value = v
    def eval = value
  }
}
{% endhighlight %}

* The trait _Exp_ lists the signature of all available operations and thus defines an interface for all data variants.
* The only data variant is implemented by class _Num_.
* We abstract over the expression type and use an abstract type _exp_ whenever we want to refer to expression objects.

Usage:

* `Traits` in Scala are very similar to interfaces in Java; the main difference is that traits may contain concrete implementations for some methods.
* An abstract `type definition` introduces a new named type whose concrete identity is unknown; type bounds may be used to narrow possible concrete incarnations of this type. This mechanism is used in the program above to declare that exp is a subtype of our preliminary expression interface Exp.  

{% highlight scala %}
object BaseTest extends Base with Application {
   type exp = Exp
           
   val e: exp = new Num(7)
   Console.println(e.eval)
}
{% endhighlight %}

This program defines a top-level `singleton object` whose class is an extension of trait Base. The type alias definition type exp = Exp overrides the corresponding abstract type definition in the superclass Base, turning the abstract type exp into a concrete one (whose identity is Exp).

#####61.1.2 Data Extensions

**Linear Extensions** In the following program we present two extensions of trait Base. BasePlus extends our system by adding a new Plus variant, BaseNeg defines a new Neg variant.

{% highlight scala %}
trait BasePlus extends Base {
    class Plus(l: exp, r: exp) extends Exp {
        val left = l
        val right = r
        def eval = left.eval + right.eval
    }
}

trait BaseNeg extends Base {
    class Neg(t: exp) extends Exp {
        val term = t;
        def eval = -term.eval;
    }
}
{% endhighlight %}

**Combining Independent Extensions** Scala also allows us to merge the two independent extensions into a single compound extension. This is done using `a mixin class composition` mechanism which includes the member definitions of one class into another class.

{% highlight scala %}
trait BasePlusNeg extends BasePlus with BaseNeg
{% endhighlight %}

Note that the members defined in trait Base are not inherited twice. If both B and C have a base class T, then the two instances are unified in the composition `A with B with C`. This presents no problem as long as T is a trait, i.e. it is stateless and does not have an explicit constructor. For non-trait base classes T, the above mixin composition is statically illegal.

#####61.1.3 Operation Extensions

{% highlight scala %}
trait Show extends Base {
  type exp <: Exp

  trait Exp extends super.Exp {
      def show: String;
  }

  class Num(v: Int) extends super.Num(v) with Exp {
      def show = value.toString();
  }
}
{% endhighlight %}

* We first have to create an extended trait Exp which specifies the new signature of all operations (the old ones get inherited from the old Exp trait, the new ones are specified explicitly), then we have to subclass all data variants and include implementations of the new operations in the subclasses.
* We have to narrow the bound of our abstract type exp **to our newly defined Exp trait**. Only this step makes the new operations accessible to clients since they type expressions with the abstract type exp.
* The newly defined Exp and Num classes shadow the former definitions of these classes in super-class Base. The former definitions are still accessible in the context of trait Show via the `super` keyword.

**Linear extensions** We can adapt our previously defined systems so that even data variants defined in extensions of Base support the show method. Again, this is done with a mixin class composition.

Since all our data variants have to support the new show method, we have to create subclasses of the inherited data variants which support the new Exp trait.

{% highlight scala %}
trait ShowPlusNeg extends BasePlusNeg with Show {
  class Plus(l: exp, r: exp) extends super.Plus(l, r) with Exp {
      def show = left.show + "+" + right.show
  }

  class Neg(t: exp) extends super.Neg(t) with Exp {
      def show = "-(" + term.show + ")"
  }
}

object ShowPlusNegTest extends ShowPlusNeg with Application {
  type exp = Exp
  val e: exp = new Neg(new Plus(new Num(7), new Num(6)))
  Console.println(e.show + " = " + e.eval)
}
{% endhighlight %}

**Tree transformer extensions** Instead of first introducing the new operation in the base system (which would also be possible), we choose to specify it directly in an extension. 

{% highlight scala %}
trait DblePlusNeg extends BasePlusNeg {
  type exp <: Exp

  trait Exp extends super.Exp {
      def dble: exp
  }

  def Num(v: Int): exp
  def Plus(l: exp, r: exp): exp
  def Neg(t: exp): exp

  class Num(v: Int) extends super.Num(v) with Exp {
      def dble = Num(v * 2)
  }

  class Plus(l: exp, r: exp) extends super.Plus(l, r) with Exp {
      def dble = Plus(left.dble, right.dble)
  }

  class Neg(t: exp) extends super.Neg(t) with Exp {
      def dble = Neg(t.dble)
  }
}
{% endhighlight %}

* Note that we cannot simply invoke the constructors of the various expression classes in the bodies of the dble methods. This is because method dble returns a value of type exp, the type representing extensible expressions, but all data variant types like Plus and Num extend only trait Exp which is a supertype of exp. We can establish the necessary relationship between exp and Exp only at the stage when we turn the abstract type into a concrete one (with the type alias definition type exp = Exp). Only then, Num is also a subtype of exp. 
* Since the implementation of dble requires the creation of new expressions of type exp, we make use of `abstract factory methods`, one for each data variant. The concrete factory methods are implemented at the point where the abstract type exp is resolved.

{% highlight scala %}
object DblePlusNegTest extends DblePlusNeg with Application {
  type exp = Exp

  def Num(v: Int): exp = new Num(v)
  def Plus(l: exp, r: exp): exp = new Plus(l, r)
  def Neg(t: exp): exp = new Neg(t)

  val e: exp = Plus(Neg(Plus(Num(1), Num(2))), Num(3))
  Console.println(e.dble.eval)
}
{% endhighlight %}

**Combining independent extensions** Finally we show how to combine the two traits ShowPlusNeg and DblePlusNeg to obtain a system which provides expressions with both a double and a show method. In order to do this, we have to perform a deep mixin composition of the two traits. We have to combine the two top-level traits ShowPlusNeg and DblePlusNeg as well as the traits and classes defined inside of these two top-level traits.

{% highlight scala %}
trait ShowDblePlusNeg extends ShowPlusNeg with DblePlusNeg {
  type exp <: Exp

  trait Exp extends super[ShowPlusNeg].Exp with super[DblePlusNeg].Exp

  class Num(v: Int) extends super[ShowPlusNeg].Num(v)
      with super[DblePlusNeg].Num
      with Exp

  class Plus(l: exp, r: exp) extends super[ShowPlusNeg].Plus(l, r)
      with super[DblePlusNeg].Plus(l, r)
      with Exp

  class Neg(t: exp) extends super[ShowPlusNeg].Neg(t)
      with super[DblePlusNeg].Neg(t)
      with Exp;
}
{% endhighlight %}

[1]: http://scala-lang.org/docu/files/IC_TECH_REPORT_200433.pdf
