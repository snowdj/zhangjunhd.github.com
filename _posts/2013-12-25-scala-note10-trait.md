---
layout: post
title: "Scala笔记10-特质trait"
description: "Scala笔记10-特质"
category: 编程
tags: [scala]
---
{% include JB/setup %}

当`作接口使用的Trait`，可以用with关键字添加额外的Trait:

{% highlight scala %}
trait Logger {
  def log(msg: String)
}

class ConsoleLogger extends Logger {
  def log(msg: String) { println(msg) }
}

class ConsoleLogger2 extends Logger with Cloneable with Serializable {
  def log(msg: String) { println(msg) }
}
{% endhighlight %}

带`有具体实现的Trait`:

{% highlight scala %}
trait ConsoleLogger {
  def log(msg: String) { println(msg) }
}

class Account() {
  var balance: Double = 0
}

class SavingsAccount extends Account with ConsoleLogger {
  def withdraw(amount: Double) {
    if (amount > balance) log("Insufficient funds")
    else balance -= balance
  }
  //...
}
{% endhighlight %}

在Scala中，我们说ConsoleLogger的功能被`混入`了SavingsAccount类。 

`特质中的具体字段`:特质中的字段可以是具体的，也可以是抽象的。如果给出了初始值，字段就是具体的。混入了该特质的类会自动获得特质的具体字段，但`这些字段不是被继承的，而是被简单加入到了子类中`。`特质的抽象字段必须在具体的子类中进行重写`。
 
`带有特质的对象`:在构造对象时，可以混入该对象所具有的特质的子类型。那么在调用这个对象所具有的特质方法时，将会执行子类型的方法。

{% highlight scala %}
class Account() {
  var balance: Double = 0
}

trait Logged {
  def log(msg: String) {}
}

class SavingsAccount extends Account with Logged {
  def withdraw(amount: Double) {
    if (amount > balance) log("Insufficient funds")
    else log("OK")
  }
  //...
}

trait ConsoleLogger extends Logged {
  override def log(msg: String) { println(msg) }
}

object Run extends App {
  val acct = new SavingsAccount with ConsoleLogger
}
{% endhighlight %}

`叠加在一起的特质`: 可以为类或对象添加多个相互调用的特质，调用将会从`最后一个`特质开始。这个功能对需要分阶段加工处理某个值的场景很有用。

{% highlight scala %}
class Account() {
  var balance: Double = 0
}

trait Logged {
  def log(msg: String) {}
}

class SavingsAccount extends Account with Logged {
  def withdraw(amount: Double) {
    if (amount > balance) log("Insufficient funds")
    else log("OK")
  }
  //...
}

trait ConsoleLogger extends Logged {
  override def log(msg: String) { println(msg) }
}

trait TimestampLogger extends Logged {
  override def log(msg: String) {
    super.log(new java.util.Date() + " " + msg)
  }
}

trait ShortLogger extends Logged {
  val maxLength = 15
  override def log(msg: String) {
    super.log(
        if (msg.length <= maxLength) msg
        else msg.substring(0, maxLength - 3) + "...")
  }
}

object Run extends App {
  val acct1 = new SavingsAccount with ConsoleLogger with TimestampLogger with ShortLogger
  acct1.log("test") // Sun Dec 01 16:01:17 CST 2013 test

  val acct2 = new SavingsAccount with ConsoleLogger with ShortLogger with TimestampLogger
  acct2.log("test") // Sun Dec 01 1...
}
{% endhighlight %}

`特质构造顺序`。特质也可以有构造器，由字段的初始化和其他特质体中的语句构成。构造器的执行顺序：

  1. 调用超类的构造器；
  2. 特质构造器在超类构造器之后、类构造器之前执行；
  3. 特质由左到右被构造；
  4. 每个特质当中，父特质先被构造；
  5. 如果多个特质共有一个父特质，父特质不会被重复构造
  6. 所有特质被构造完毕，子类被构造。

例如
{% highlight scala %}
class SavingsAccount extends Account with ConsoleLogger with ShortLogger with TimestampLogger
{}
{% endhighlight %}

  1. Account（超类）
  2. Logger（第一个Trait的父Trait）
  3. ConsoleLogger（第一个Trait）
  4. ShortLogger（第二个Trait，注意到它的父Trait已经被构造）
  5. TimestampLogger（第三个Trait，注意到它的父Trait已经被构造）
  6. SavingAccount（子类）

`构造器的顺序是类的线性化的反向`。 如果C extends C1 with C2 … with Cn，则lin( C ) = C ⪼ lin(Cn) ⪼ … ⪼ lin(C2) ⪼ lin(C1)，在这里⪼的意思是“串接并去掉重复项，右侧胜出”。例如：

    lin(SavingAccount) 
    = SavingAccount ⪼ lin(TimestampLogger) ⪼ lim(ShortLogger) ⪼ lim(ConsoleLogger) ⪼ lim(Account)
    = SavingAccount ⪼ (TimestampLogger ⪼ Logger) ⪼ (ShortLogger ⪼ Logger) ⪼ (ConsoleLogger ⪼ Logger) ⪼ lim(Account)
    = SavingAccount ⪼ TimestampLogger ⪼ ShortLogger ⪼ ConsoleLogger ⪼ Logger ⪼ Account

`初始化特质中的字段`:特质不能有构造器参数，每个特质有一个无参数的构造器。

对于需要某种定制才有用的特质来说，这个局限是一个问题。用文件日志生成器来说明，我们需要在使用特质时指定日志文件，但是特质不能使用构造参数。可以考虑使用抽象字段来存放文件名：

{% highlight scala %}
trait FileLogger extends Logger {
  val filename: String
  val out = new PrintStream(filename)
  def log(msg: String) { out.println(msg); out.flush() }
}

val acct = new SavingsAccount with FileLogger {
  val filename = "myapp.log"
}
{% endhighlight %}

但是这样却是行不通的。问题来自于构造顺序。FileLogger的构造器会先于子类构造器执行，这里的子类是一个扩展了SavingsAccount且混入了FileLogger的匿名类实例。在构造FileLogger时，就会抛出一个空指针异常，子类的构造器根本就不会执行。这个问题的解决方法之一是使用`提前定义`这个语法:

{% highlight scala %}
val acct = new {
  val filename = "myapp.log"
} with SavingsAccount with FileLogger

class SavingsAccount extends {
  val filename = "myapp.log"
} with Account with FileLogger {
  //...
}
{% endhighlight %}

另外一个方法是使用懒值,因为懒值在初次使用是才被初始化，所以out字段不会再抛出空指针异常。在使用out字段时，filename也已经初始化了。但是使用懒值不高效：

{% highlight scala %}
trait FileLogger extends Logger {
  val filename: String
  lazy val out = new PrintStream(filename)
  def log(msg: String) { out.println(msg) }
}
{% endhighlight %}

`扩展类的特质`:特质可以扩展类，这个类会自动成为所有混入该特质的类的超类。 

{% highlight scala %}
trait LoggedException extends Exception with Logged {
  def log() { log(getMessage()) }
}

class UnhappyException extends LoggedException {
  override def getMessage = "arggh!"
}
{% endhighlight %}

特质的超类Exception自动成为了混入了LoggedException特质的UnhappyException的超类。Scala并不允许多继承。那么这样一来，如果UnhappyException原先已经扩展了一个类了该如何处理？`只要已经扩展的类是特质超类的一个子类就可以`。

{% highlight scala %}
class UnhappyException extends IOException with LoggedException  // OK
class UnhappyFrame extends JFrame with LoggedException  // Error!!!
{% endhighlight %}


`自身类型`:如果特质以 this: type =>开始定义,那么这个特质就只能被混入type指定的类型的子类。 

{% highlight scala %}
trait LoggedException extends Logged {
  this: Exception =>
  def log() { log(getMessage()) }
}
{% endhighlight %}

这里的特质LoggedException并不扩展Exception类，而是自身拥有Exception类型，意味着该特质只能被混入Exception的子类。这样指定了自身类型之后，调用自身类型的方法就合法了（这里调用了Exception类的getMessage方法）。

自身类型还可以处理`结构类型`（structural type）——这种类型只给出了类必须拥有的方法，而不是类的名称。

{% highlight scala %}
trait LoggedException extends Logged {
  this: ( def getMessage(): String) =>
  def log() { log(getMessage()) }
}
{% endhighlight %}
