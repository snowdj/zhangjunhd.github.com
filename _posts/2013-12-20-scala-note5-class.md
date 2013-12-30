---
layout: post
title: "Scala笔记5-类Class"
description: "Scala笔记5-类"
category: 编程
tags: [scala]
---
{% include JB/setup %}

简单的scala类：

{% highlight scala %}
class Counter {
  private var value = 0 // You must initialize the field
  def increment() { value += 1 } // Methods are public by default. Use () with mutator 
  def current = value //Don’t use () with accessor
}
{% endhighlight %}

scala对每个字段都提供`getter`和`setter`方法:

{% highlight scala %}
class Person {
  var age = 0
}

object Run extends App {
  val fred = new Person
  println(fred.age) // Calls the method fred.age() 
  fred.age = 21 // Calls fred.age_=(21)
}
{% endhighlight %}

可重新定义getter和setter方法:

{% highlight scala %}
class Person {
  private var privateAge = 0

  def age = privateAge
  def age_=(newAge: Int) = if (newAge > privateAge) privateAge = newAge
}

object Run extends App {
  val fred = new Person
  println(fred.age) // 0 
    
  fred.age = 21
  println(fred.age) // 21 

  fred.age = 0
  println(fred.age) // 21 
}
{% endhighlight %}

只有getter方法:

{% highlight scala %}
class Message {
  val timeStamp = new java.util.Date // a read-only property with a getter but no setter
  //...
}
{% endhighlight %}

关于`对象私有字段`:

{% highlight scala %}
class Counter {
  private var value = 0
  def increment() { value += 1 }
  def isLess(other: Counter) = value < other.value // Can access private field of other object
}
{% endhighlight %}

之所以可以访问other.value，是因为other也是一个Counter对象。如果期望禁止这一点，可以private[this]:

{% highlight scala %}
class Counter {
  private[this] var value = 0
  def increment() { value += 1 }
  //def isLess(other: Counter) = value < other.value // compile error!!!
}
{% endhighlight %}

对于类私有的字段，Scala生成私有的getter和setter方法。但对于对象私有的字段，Scala根本不会生成getter和setter方法。

`BeanProperty`:

{% highlight scala %}
import scala.beans.BeanProperty

class Person(@BeanProperty var name:String)
{% endhighlight %}


这样将会生成四个方法：

1. name:String
2. name_=(newValue:String):Unit
3. getName():String
4. setName(newValue:String):Unit

`辅助构造器`:辅助构造器的名称为this，每一个辅助构造器必须以一个对先前已定义的其他辅助构造器或主构造器的调用开始。

{% highlight scala %}
class Person {
  private var name = ""
  private var age = 0

  def this(name: String) { // An auxiliary constructor 
      this() // Calls primary constructor
      this.name = name
  }
  def this(name: String, age: Int) { // Another auxiliary constructor 
      this(name) // Calls previous auxiliary constructor
      this.age = age
  }
}
{% endhighlight %}

`主构造器`:主构造器的参数直接放置在类名之后。主构造器执行类定义中的所有语句。

{% highlight scala %}
class Person(val name: String, private var age: Int) {
  println("Just constructed another person")
  def description = name + " is " + age + " years old"
}
{% endhighlight %}

上面这个例子中，主构造器会构造name和age，同时执行println。如果`不带val或var，且这些参数至少被一个方法所使用，它将被升格为字段`。

{% highlight scala %}
class Person(name: String, age: Int) {
  def description = name + " is " + age + " years old"
}
{% endhighlight %}

上述代码声明并初始化不可变字段name和age，而这两个字段是对象私有的。效果等同于private[this] val。

`嵌套类`

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

class Network {
  class Member(val name: String) {
    val contacts = new ArrayBuffer[Member
  }

  private val members = new ArrayBuffer[Member]

  def join(name: String) = {
      val m = new Member(name)
      members += m
      m
  }
}

object Run extends App {
  val chatter = new Network
  val myFace = new Network
}
{% endhighlight %}

在Scala中，每个实例都有自己的Member类，就和它们有自己的members字段一样。也就是说chatter.Member和myFace.Member是不同的两个类。如果不期望这种行为，一种办法是将这个类移到外部去，比如Network的`伴生对象`(companion object)：

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer
import Network.Member

class Network {
  private val members = new ArrayBuffer[Network.Member]

  def join(name: String) = {
    val m = new Member(name)
    members += m
    m
  }
}

object Network {
  class Member(val name: String) {
    val contacts = new ArrayBuffer[Member]
  }
}
{% endhighlight %}


第二个办法是使用`类型投影`(type projection)：Network#Member

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

class Network {

  class Member(val name: String) {
    val contacts = new ArrayBuffer[Network#Member]
  }
    
  private val members = new ArrayBuffer[Network#Member]

  def join(name: String) = {
    val m = new Member(name)
    members += m
    m
  }
}
{% endhighlight %}

可以通过外部类.this的方式访问`外部类的this引用`，class Network{outer =>语法使得outer变量指向Network.this:

{% highlight scala %}
class Network(val name: String) { outer =>
  class Member(val name: String) {
    //...
    def description = name + " inside " + outer.name
  }
}
{% endhighlight %}

`单例对象`(Singletons):

{% highlight scala %}
object Accounts {
  private var lastNumber = 0
  def newUniqueNumber() = { lastNumber += 1; lastNumber }
}
{% endhighlight %}

`伴生对象`(Companion Objects):可以将静态方法放到伴生对象中

{% highlight scala %}
class Account {
  val id = Account.newUniqueNumber()
  private var balance = 0.0
  def deposit(amount: Double) { balance += amount }
  //...
}

object Account { // The companion object
  private var lastNumber = 0
  private def newUniqueNumber() = { lastNumber += 1; lastNumber }
}
{% endhighlight %}

一个object可以扩展类以及一个或多个trait，其结果是一个扩展了指定类以及trait的类的对象，一个有用的场景是给出可被共享的缺省对象:

{% highlight scala %}
abstract class UndoableAction(val description: String) {
  def undo(): Unit
  def redo(): Unit
}

object DoNothingAction extends UndoableAction("Do nothing") {
  override def undo() {}
  override def redo() {}
}

object Run extends App {
  val actions = Map("open" -> DoNothingAction, "save" -> DoNothingAction /*, ...*/ )
}
{% endhighlight %}

`apply`方法:通常用于返回一个伴生类的对象。

{% highlight scala %}
class Account private (val id: Int, initialBalance: Double) {
  private var balance = initialBalance
  //...
}

object Account { // The companion object 
  def apply(initialBalance: Double) =
    new Account(0, initialBalance)
  //...
}

object Run extends App {
  val acct = Account(1000.0)
}
{% endhighlight %}


类中`重写字段`

   * def只能重写另一个def
   * val只能重写另一个val或不带参数的def
   * var只能重写另一个抽象的var

匿名子类重写字段

{% highlight scala %}
class Person(val name: String) {
  def greeting = "Hi " + name
}

object Run extends App {
  val alien = new Person("Jeff") {
    def greeting = "I am Jeff!!!"
  }
}
{% endhighlight %}

可以使用`结构类型`作为参数类型的定义

{% highlight scala %}
class Person(val name: String) {
  def greeting = "Hi " + name
}

object Run extends App {
  def meet(p: Person { def greeting: String }) {
    println(p.name + "Says: " + p.greeting)
  }
}
{% endhighlight %}

抽象类与抽象字段。在Scala中，不需要对抽象方法使用abstract关键字，只需省去其方法体。在子类中重写超类的抽象方法时，不需要使用override关键字：

{% highlight scala %}
abstract class Person(val name: String) {
  def id: Int // No method body—this is an abstract method
}

class Employee(name: String) extends Person(name) {
  def id = name.hashCode // override keyword not required
}
{% endhighlight %}

除了抽象方法外，类还可以有抽象字段,子类可以重写超类的抽象字段，也可以用匿名类型来定制抽象字段：

{% highlight scala %}
abstract class Person {
  val id: Int // No initializer—this is an abstract field with an abstract getter method 
  var name: String // Another abstract field, with abstract getter and setter methods
}

class Employee(val id: Int) extends Person { // Subclass has concrete id property
  var name = "" // and concrete name property
}

object Run extends App {
  val jeff = new Person {
    val id = 1     
    var name = "Jeff"
  }
}
{% endhighlight %}

`懒值`

{% highlight scala %}
// fetch words when first defined
val words = scala.io.Source.fromFile("/tmp/words").mkString
    
// fetch words when first used
lazy val lazywords = scala.io.Source.fromFile("/tmp/words").mkString
    
// fetch words when used each times
def defwords = scala.io.Source.fromFile("/tmp/words").mkString
{% endhighlight %}

构造顺序与提前定义

{% highlight scala %}
class Creature {
  val range = 10
  val env: Array[Int] = new Array[Int](range)
}

class Ant extends Creature {
  override val range = 2
}
{% endhighlight %}

具体的执行顺序：

  1. Ant的构造器在做它自己的构造之前，调用Creature的构造器
  2. Creature的构造器将它的range设为10
  3. Creature的构造器初始化env，调用range()
  4. 该方法被重写以输出(还未初始化的)Ant类的range字段值
  5. `range返回0`。这个不符合设计需求。
  6. env被设为长度为0的数组

有如下几种解决方法：

  1. 将val声明为final(安全但不灵活)
  2. 在超类中将val声明为lazy(安全但不高效)
  3. 在子类中使用提前定义(可以在超类的构造器执行之前初始化子类的val字段)

{% highlight scala %}
class Ant extends {
  override val range = 2
} with Creature
{% endhighlight %}

对象相等性

在Scala中，AnyRef的eq方法检查两个引用是否指向一个对象。AnyRef的equals方法调用eq。当你实现类的时候，应该考虑重写equals方法，同时也定义hashCode。你通常并不直接调用eq或equals，只要有==操作符就好。对于引用类型而言，它会在做完必要的null检查后调用equals方法。