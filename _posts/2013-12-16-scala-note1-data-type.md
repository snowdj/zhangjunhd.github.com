---
layout: post
title: "Scala笔记1-基本类型"
description: "Scala笔记1-基本类型，类型检查"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####Scala基本类型

    Data Type     Definition
    Boolean       true or false
    Byte          8-bit signed two's complement integer (-2^7 to 2^7-1, inclusive)
    Short         16-bit signed two's complement integer (-2^15 to 2^15-1, inclusive)
    Int           32-bit two's complement integer (-2^31 to 2^31-1, inclusive)
    Long          64-bit two's complement integer (-2^63 to 2^63-1, inclusive)
    Float         32-bit IEEE 754 single-precision float
    Double        64-bit IEEE 754 double-precision float
    Char          16-bit unsigned Unicode character (0 to 2^16-1, inclusive)
    String        a sequence of Chars

####BigDecimal
{% highlight scala %}
import scala.math.BigDecimal.RoundingMode

object Main extends App {
  val salary:BigDecimal = 100000
  val weekly = salary / 52 //scala.math.BigDecimal = 1923.076923076923076923076923076923
  weekly.setScale(2, RoundingMode.HALF_EVEN) // scala.math.BigDecimal = 1923.08
}
{% endhighlight %}

####pow,prime,Random
{% highlight scala %}
3 - math.pow(math.sqrt(3), 2) // Double = 4.440892098500626E-16

import BigInt.probablePrime
import util.Random
/** Returns a positive BigInt that is probably prime, 
 *  with the specified bitLength.
 */
probablePrime(100, Random)
{% endhighlight %}

####A Scala current date/time example
{% highlight scala %}
import java.util.Calendar
import java.text.SimpleDateFormat

object Main extends App {
  val today = Calendar.getInstance().getTime() // java.util.Date = Sat Jan 04 21:08:02 CST 2014

  // create the date/time formatters
  val minuteFormat = new SimpleDateFormat("mm")
  val hourFormat = new SimpleDateFormat("hh")
  val amPmFormat = new SimpleDateFormat("a")

  val currentHour = hourFormat.format(today)      // String = 09
  val currentMinute = minuteFormat.format(today)  // String = 08
  val amOrPm = amPmFormat.format(today)           // String = PM
}
{% endhighlight %}

####String
一些常用的String 操作:
{% highlight scala %}
object Run extends App {
  var str = "%s %.2f, and %d".format("s", .1, 1) // s 0.10, and 1
  
  // Simple string interpolation
  val name = "Jeff"
  println(s"Hello, $name") // Hello, Jeff
  val age = 18
  println(s"Hello, $name, age $age") // Hello, Jeff, age 18

  val arr = Array("Hello", "world", "it's", "me")
  str = arr.mkString(",") // Hello,world,it's,me
  str = arr.mkString(" ") // Hello world it's me

  str = "foo\n"
  val str2 = "bar"
  str + str2 //foo
             // bar
    
  str.stripLineEnd + str2 // foobar

  // scala的String判等直接用==
  val s1 = "Hello"
  val s2 = "Hello"
  val s3 = "Goodbye"
  val s4: String = null
  val s5 = "H" + "ello"

  if (s1 == s2) println("s1 == s2, good")
  if (s1 == s3) println("s1 == s3, bad")
  if (s1 == s4) println("s1 == s4, bad")
  if (s1 == s5) println("s1 == s5, good")
  
  "hello world".count(_ == 'o') // 2
  "hello world".split(" ") // Array[java.lang.String] = Array(hello, world)
  "hello world".split(" ").foreach(println) // hello
                                            // world
  "hello world".split(" ").map(_.length) //  Array[Int] = Array(5, 5)
  "hello world".split("\\s+") // Array[java.lang.String] = Array(hello, world)
  "hello world".distinct // helo wrd
  val a = "hello"
  val b = "world"
  a.diff(b) // hel
  b.diff(a) // wrd
  a.intersect(b) // lo
  b.intersect(a) // ol
  
  ("hello".take(3), "hello".drop(3), "hello".takeRight(3), "hello".dropRight(3)) // (hel,lo,llo,he)
  // the same as
  ("hello".substring(0, 3), "hello".substring(3), "hello".substring(2), "hello".substring(0, 2))
}
{% endhighlight %}

产生random String:
{% highlight scala %}
import scala.util.Random

object Run extends App {
  val r = new Random(31) // scala.util.Random = scala.util.Random@7d49fa1e
  r.nextString(10) // String = 빶絒釰핶ಧᡴ♜옹坤ꗓ
    
  Random.nextString(5) // String = 粓沗䛄㶒፼
    
  val x = Random.alphanumeric // scala.collection.immutable.Stream[Char] = Stream(Q, ?)
  x.take(10).foreach(print) // UmbfYuJZeE
}
{% endhighlight %}

####类型检查与转换
    
    Scala                  Java
    obj.isInstanceOf[C]    obj instanceOf C
    obj.asInstanceOf[C]    ( C ) obj
    classOf[C]             C.class  

####Reflect
得到类型
{% highlight scala %}
package testscala

import scala.reflect.runtime.{universe => ru}

class Foo(val s : String) {
    def foo {println("foo:" + s)}
}

object TestMain extends App {

  def getTypeTag[T: ru.TypeTag](obj: T) = ru.typeTag[T] // getTypeTag: [T](obj: T)(implicit evidence$1: reflect.runtime.universe.TypeTag[T])reflect.runtime.universe.TypeTag[T]
    
  def getTypeTag[T: ru.TypeTag](obj: T) = ru.typeTag[T] // getTypeTag: [T](obj: T)(implicit evidence$1: reflect.runtime.universe.TypeTag[T])reflect.runtime.universe.TypeTag[T]
  val l = List[Foo]()
  val theType = getTypeTag(l).tpe // theType: reflect.runtime.universe.Type = List[Foo]

  def meth[A: ru.TypeTag](xs: List[A]) = ru.typeOf[A] match {
      case t if t =:= ru.typeOf[String] => "list of strings"
      case t if t <:< ru.typeOf[Foo] => "list of foos"
  }
  meth(List("string")) //list of strings
  meth(List(new Foo("na"))) //list of foos
}
{% endhighlight %}

反射构造一个对象：
{% highlight scala %}
package testscala

import scala.reflect.runtime.{universe => ru}

class Foo(val s : String) {
    def foo {println("foo:" + s)}
}

object TestMain2 extends App {
  val m = ru.runtimeMirror(getClass.getClassLoader)
  val classFoo = ru.typeOf[Foo].typeSymbol.asClass // classFoo: reflect.runtime.universe.ClassSymbol = class Foo
  val cm = m.reflectClass(classFoo) // cm: reflect.runtime.universe.ClassMirror = class mirror for Foo (bound to null)
  val ctor = ru.typeOf[Foo].declaration(ru.nme.CONSTRUCTOR).asMethod // ctor: reflect.runtime.universe.MethodSymbol = constructor Foo
  val ctorm = cm.reflectConstructor(ctor) // ctorm: reflect.runtime.universe.MethodMirror = constructor mirror for Foo.<init>(s: String): Foo (bound to null)
  val p = ctorm("Hello").asInstanceOf[Foo] // p: Foo = Foo@3e937cea
  p.foo // foo:Hello
}
{% endhighlight %}
