---
layout: post
title: "Scala Collections"
description: ""
category: 编程
tags: [scala]
---
{% include JB/setup %}

paper review 64 [Fighting Bit Rot with Types(Experience Report: Scala Collections)][1]
<!--break-->

##2 Syntactic Preliminaries

![1](/assets/2013-11-14-scala-collections/scala-col1.png)

##4 Abstracting over the Representation Type

`Variance` defines a subtyping relation over parameterised types based on the subtyping of their element types.For example,class List[+T] introduces the type constructor List, whose type parameter is `covariant`. This means that List[A] is a subtype of List[B] if A is a subtype of B. With a `contravariant` type parameter, this is inverted, so that class OutputChannel[-T] entails that OutputChannel[A] is a subtype of OutputChannel[B] if A is a supertype of B. 

Listing 2 outlines the core implementation trait, TraversableLike, which backs the new root of the collection hierarchy, Traversable. The type parameter Elem stands for the element type of the traversable whereas the type parameter Repr stands for its represent- ation. An actual collection class, such as List, can simply inherit the appropriate imple- mentation trait, and instantiate Repr to List.

The two fundamental operations in Traversable are foreach and newBuilder. Both operations are deferred in class TraverableLike to be implemented in concrete subclasses.

{% highlight scala %}
package scala.collectiontrait TraversableLike[+Elem, +Repr] {  protected[this] def newBuilder: Builder[Elem, Repr] // deferred
  def foreach[U](f: Elem ⇒ U)                         // deferred
  
  def filter(p: Elem ⇒ Boolean): Repr = {
    val b = newBuilder    foreach { elem ⇒ if (p(elem)) b += elem } 
    b.result
  }
}
{% endhighlight %}

Listing2:Anoutlineoftrait TraversableLike

Listing 3 presents a slightly simplified outline of the Builder class.

{% highlight scala %}
package scala.collection.generic class Builder[-Elem, +To] {  def +=(elem: Elem): this.type = ...  def result(): To = ...  def clear() = ...  def mapResult[NewTo](f: To ⇒ NewTo): Builder[Elem, NewTo] = ...}
{% endhighlight %}

Listing 3: An outline of the Builder class.

Often, a builder can refer to some other builder for assembling the elements of a collection, but then would like to transform the result of the other builder, to give a different type, say. This task is simplified by the method mapResult in class Builder. For instance, assuming a builder bldr of ArrayBuffer collections, one can turn it into a builder for Arrays like this:

    bldr mapResult (_.toArray)

Given these abstractions, the trait TraversableLike can define operations like filter in the same way for all collection classes, without compromising efficiency or precision of type signatures. First, it relies on the newBuilder method to create an empty builder that’s appropriate for the collection at hand, then, it uses foreach to traverse the existing collection, appending every elem that meets the predicate p to the builder. Finally, thebuilder’s result is the filtered collection.

##5 Abstracting over the Collection Type Constructor

More concretely, we need to factor out the type constructors List and Array. Thus, instead of abstracting over the representation type, we abstract over the collection type constructor. Abstracting over type constructors requires higher-order parametric polymorphism, which we call `type constructor polymorphism` in Scala. This higher-order generalisation of what is typically called “genericity” in object-oriented languages, allows to declare type parameters, such as Coll, that themselves take (higher-order) type parameters, such as x in the following snippet:

{% highlight scala %}
trait TraversableLike[+Elem, +Coll[+x]] {  def map[NewElem](f: Elem ⇒ NewElem): Coll[NewElem] 
  def filter(p: Elem ⇒ Boolean): Coll[Elem]}
{% endhighlight %}

Now, List[T] may extend TraversableLike[T, List] in order to specify that mapping or filtering a list again yields a list, whereas the type of the elements depends on the operation. 

##6 Ad-hoc Polymorphism with Implicits

We shall collect the variations in `map’s type signature` using a triple of types that relates the original collection, the transformed elements, and the resulting collection. Type constructor polymorphism is restricted to type functions of the `shape(CC[_], T, CC[T])`,for any type constructor‡ CC and any type T. 

    scala> BitSet(1,2,3) map (_ + 1)
    res0: scala.collection.immutable.BitSet = BitSet(2, 3, 4)
    
    scala> BitSet(1,2,3) map (_.toString+"!")
    res1: scala.collection.immutable.Set[java.lang.String] = Set(1!, 2!, 3!)

A type function that includes only the first triple (BitSet, Int, BitSet) can be expressed using type constructor polymorphism, but the other ones are out of reach.

Finally, consider transforming maps:

    scala>Map("a"->1,"b"->2)map{case(x,y)⇒ (y,x)}
    res2: scala.collection.immutable.Map[Int,java.lang.String] = Map(1 -> a, 2 -> b)
    
    scala>Map("a"->1,"b"->2)map{case(x,y)⇒ y}
    res3: scala.collection.immutable.Iterable[Int] = List(1, 2)

The irregular triples (Map[A, B], (A, B)⇒ (B, A), Map[B, A]) and — assuming Tisnot(A, B)—(Map[A, B], (A, B)⇒T, Iterable[T]) summarise these type signatures, for arbitrary types A, B, and T.

**Implicits**

{% highlight scala %}
abstract class Monoid[T] { 
  def add(x: T, y: T): T 
  def unit: T}
object Monoids {  implicit object stringMonoid extends Monoid[String] {    def add(x: String, y: String): String = x.concat(y)    def unit: String = "" }  implicit object intMonoid extends Monoid[Int] { 
    def add(x: Int, y: Int): Int = x + y    def unit: Int = 0  } 
}

def sum[T](xs: List[T])(implicit m: Monoid[T]): T = 
  if(xs.isEmpty) m.unit  else m.add(xs.head, sum(xs.tail))
{% endhighlight %}

This makes the two implicit definitions of stringMonoid and intMonoid eligible to be passed as implicit arguments, so that one can write:

    scala> sum(List("a", "bc", "def"))
    res0: java.lang.String = abcdef
    
    scala> sum(List(1, 2, 3))
    res1: Int = 6

These applications of sum are equivalent to the following two applications：

    sum(List("a", "bc", "def"))(stringMonoid)
    sum(List(1, 2, 3))(intMonoid)

For instance, here is a function defining an implicit lexicographical ordering relation on lists which have element types that are themselves ordered.

{% highlight scala %}
implicit def listOrdering[T](xs: List[T])(implicit elemOrd: Ordering[T]) = 
  new Ordering[List[T]] {    def compare(xs: List[T], ys: List[T]) = (xs, ys) match { 
      case (Nil, Nil) ⇒ 0      case (Nil, _) ⇒ -1      case (_, Nil) ⇒ 1      case (x :: xs1, y :: ys1) ⇒        val ec = elemOrd.compare(x, y)        if (ec != 0) ec else compare(xs1, ys1)    } 
  }
{% endhighlight %}

##7 Implicits for Scala’s collections

{% highlight scala %}
trait CanBuildFrom[-Collection, -NewElem, +Result] { 
  def apply(from: Collection): Builder[NewElem, Result]}
trait TraversableLike[+A, +Repr] {  def repr: Repr = ...  def foreach[U](f: A ⇒ U): Unit = ...  def map[B, To](f: A⇒B)(implicit cbf: CanBuildFrom[Repr, B, To]): To = {    val b = cbf(repr) // get the builder from the CanBuildFrom instance 
    for (x <- this) b += f(x) // transform element and add    b.result  } 
}
trait SetLike[+A, +Repr] extends TraversableLike[A, Repr] { }trait BitSetLike[+This <: BitSetLike[This] with Set[Int]] extends SetLike[Int, This] {}trait Traversable[+A] extends TraversableLike[A, Traversable[A]] 
trait Set[+A] extends Traversable[A] with SetLike[A, Set[A]] 
class BitSet extends Set[Int] with BitSetLike[BitSet]
object Set {  implicit def canBuildFromSet[B] = new CanBuildFrom[Set[_], B, Set[B]] {    def apply(from: Set[_]) = ... 
  }}
object BitSet {  implicit val canBuildFromBitSet = new CanBuildFrom[BitSet, Int, BitSet] {    def apply(from: BitSet) = ... 
  }}
object Test {  val bits = BitSet(1, 31, 15) 
  val shifted = bitsmap(x⇒ x+1)  val strings = bits map (x ⇒ x.toString)}
{% endhighlight %}

Listing 6: Encoding the CanBuildFrom type-relation for BitSet

Since map has a value of type CanBuildFrom[From, Elem, To], the idea is to let the implicit canBuildFrom values produce builder objects of type Builder[Elem, To] that construct collections of the right kind.

Since **implicit resolution is performed at compile time**, it cannot take dynamic types into account. Nonetheless, we expect a List to be created when the dynamic type is List, even if the static type information is limited to Iterable. This is illustrated by the following interaction with the Scala REPL:

    scala> val xs: Iterable[Int] = List(1, 2, 3)
    xs: Iterable[Int] = List(1, 2, 3)
    
    scala>xs map(x⇒ x*x)
    res0: Iterable[Int] = List(1, 4, 9)

If CanBuildFrom solely relied on the triple of types (Iterable[Int], Int, Iterable[ Int]) to provide a builder, it could not do better than to statically select a Builder[Int, Iterable[Int]], which in turn could not build a List. Thus, **we add a run-time indirection that makes this selection more dynamic**.

**The idea is to give the apply method of CanBuildfrom access to the dynamic type of the original collection via its from argument**. An instance cbf of CanBuildFrom[Iterable[Int ], Int, Iterable[Int]], is essentially a function from an Iterable[Int] to a Builder [Int, Iterable[Int]], which constructs a builder that is appropriate for the dynamic type of its argument.

The implementation of map in Listing 6 is quite similar to the implementation of filter shown in Listing 2. The interesting difference lies in how the builder is acquired: whereas filter called the newBuilder method of class TraversableLike, **map uses the instance of CanBuildFrom that is passed in as a witness to the constraint that a collection of type To with elements of type B can be derived from a collection with type Repr**. This nicely brings together the static and the dynamic aspects of implicits: they express rich relations on types, which may be witnessed by a run-time entity. Thus, static implicit resolution resolves the constraints on the types of map, and virtual dispatch picks the best dynamic type that corresponds to these constraints.

Most instances of CanBuildFrom use the same structure for this virtual dispatch, so that we can implement it in GenericTraversableTemplate, the higher-kinded implementation trait for all traversables, as shown in Listing 7.

{% highlight scala %}
trait GenericCompanion[+CC[X] <: Traversable[X]] { 
  def newBuilder[A]: Builder[A, CC[A]]}
trait GenericTraversableTemplate[+A, +CC[X] <: Traversable[X]] {  // The factory companion object that builds instances of class CC. 
  def companion: GenericCompanion[CC]  // The builder that builds instances of CC at arbitrary element types.  def genericBuilder[B]: Builder[B, CC[B]] = companion.newBuilder[B] 
}
trait TraversableFactory[CC[X] <: Traversable[X] with 
                     GenericTraversableTemplate[X, CC]]                      extends GenericCompanion[CC] { // Standard CanBuildFrom instance
                                                   // for a CC that’s a traversable.  class GenericCanBuildFrom[A] extends CanBuildFrom[CC[_], A, CC[A]] { 
    def apply(from: CC[_]) = from.genericBuilder[A]  } 
}
{% endhighlight %}

Listing 7: GenericCanBuildFrom

##9 Dealing with Arrays and Strings

**Avoiding ambiguities**. The two implicit conversions from Array to ArrayLike values are disambiguated according to the rules explained in Section 7. Applied to arrays, this means that we can prioritise the conversion from Array to ArrayOps over the conversion from Array to WrappedArray by placing the former in the standard Predef object (which is visible in all user code) and by placing the latter in a class LowPriorityImplicits, which is inherited by Predef. This way, calling a sequence method will always invoke the conver- sion to ArrayOps. The conversion to WrappedArray will only be invoked when an array needs to be converted to a sequence.

**Integrating Strings**. Strings pose similar problems as arrays in that we are forced to pick an existing representation which is not integrated into the collection library and which cannot be extended with new methods because Java’s String class is final. The solution for strings is very similar as the one for arrays. There are two prioritised implicit conversions that apply to strings. The low-priority conversion maps a string to an immutable indexed sequence of type scala.collection.immutable.IndexedSeq. The high-priority conversion maps a string to a (short-lived) StringOps object which implements all operations of an immutable indexed sequence, but with String as the result type. 

**Generic Array Creation and Manifests**. Unlike Java, Scala allows an instance creation new Array[T] where T is a type parameter. Scala 2.8 has a new mechanism for this, which is called a `Manifest`. An object of type Manifest[T] provides complete information about the type T. Manifest values are typically passed in implicit parameters, and the compiler knows how to construct them for statically known types T. There exists also a weaker form named ClassManifest which can be constructed from knowing just the top-level class of a type, without necessarily knowing all its argument types. It is this type of runtime information that’s required for array creation.

[1]: http://lampwww.epfl.ch/~odersky/papers/fsttcs2009.pdf