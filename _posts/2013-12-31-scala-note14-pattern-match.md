---
layout: post
title: "scala笔记14-模式匹配与样例类"
description: "scala笔记14-模式匹配,样例类,密封类,Option,偏函数"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####更好的switch
{% highlight scala %}
var sign = ...
val ch: Char = ...

ch match {
  case '+' => sign = 1
  case '-' => sign = -1
  case _ => sign = 0
}
{% endhighlight %}

match是表达式，不是语句，所以是有返回值的，故可将代码简化：

{% highlight scala %}
sign = ch match {
  case '+' => 1
  case '-' => -1
  case _ => 0
}
{% endhighlight %}

带`守卫`的表达式
{% highlight scala %}
ch match {
  case '+' => sign = 1
  case '-' => sign = -1
  case _ if Character.isDigit(ch) => digit = Character.digit(ch, 10)
  case _ => sign = 0
}
{% endhighlight %}

####模式中的变量
如果在case关键字后跟着一个变量名，那么匹配的表达式会被赋值给那个变量。case _是这个特性的一个特殊情况，变量名是_。

{% highlight scala %}
str(i) match {
  case '+' => sign = 1
  case '-' => sign = -1
  case ch => digit = Character.digit(ch, 10)
}
{% endhighlight %}

可以在守卫中使用变量:
{% highlight scala %}
str(i) match {
  //...
  case ch if Character.isDigit(ch) => digit = Character.digit(ch, 10)
}
{% endhighlight %}

####类型模式
{% highlight scala %}
obj match {
  case x: Int => x
  case s: String => Integer.parseInt(s)
  case _: BigInt => Int.MaxValue
  case _ => 0
}
{% endhighlight %}

在匹配类型时，需要使用一个变量名，否则就是使用对象本身来进行匹配了。

{% highlight scala %}
obj match {
  case _: BigInt => Int.MaxValue  // 匹配任何类型为BigInt的对象
  case BigInt => -1  // 匹配类型为Class的BigInt对象
}
{% endhighlight %}

因为匹配是发生在运行期的，而且JVM中泛型的类型信息会被擦掉，因此不能使用类型来匹配特定的Map类型：

{% highlight scala %}
case m: Map[String, Int] => ...  // 不行
case m: Map[_, _] => ...  // 匹配通用的Map，OK
{% endhighlight %}

但对于数组来说，类型信息是完好的，所以可以在Array上匹配:

{% highlight scala %}
arr match {
  case Array(0) => "0"  // 匹配包含0的数组
  case Array(x, y) => x + " "　＋ y  // 匹配任何带有两个元素的数组，并将元素绑定到x和y
  case Array(0, _*) => "0 ..."  // 匹配任何以0开始的数组
  case _ => "something else"
}
{% endhighlight %}

列表匹配:

{% highlight scala %}
lst match {
  case 0 :: Nil => "0"
  case x :: y :: Nil => x + " " + y
  case 0 :: tail => "0 ..."
  case _ => "something else"
}
{% endhighlight %}

元组匹配:

{% highlight scala %}
pair match {
  case (0, _) => "0 ..."
  case (y, _) => y + " 0"
  case _ => "neither is 0"
}
{% endhighlight %}

注意到变量将会被绑定到这三种数据结构的不同部分上，这种操作被称为`“析构”`。

####提取器

在前面的代码 case Array(0, x) => ...中， Array(0, x)部分实际上是使用了伴生对象中的提取器，实际调用形式是： Array.unapplySeq(arr)。根据Doc，提取器方法接受一个Array参数，返回一个Option。正则表达式是另一个适用提取器的场景。正则有分组时，可以用提取器来匹配分组：

{% highlight scala %}
val pattern = "([0-9]+) ([a-z]+)".r
"99 bottles" match {
  case pattern(num, item) => ...
}
{% endhighlight %}

####变量声明中的模式
在变量声明中的模式对于返回对偶的函数来说很有用。
{% highlight scala %}
val (x, y) = (1, 2)
val (q, r) = BigInt(10) /% 3  // 返回商和余数的对偶
val Array(first, second, _*) = arr  // 将第一和第二个分别给first和second
{% endhighlight %}

####for表达式中的模式

{% highlight scala %}
import scala.collection.JavaConversions.propertiesAsScalaMap

for ((k, v) <- System.getProperties())  // 这里使用了模式
  println(k + " -> " + v)

for ((k, "") <- System.getProperties())  // 失败的匹配会被忽略，所以只打印出值为空的键
  println(k)
{% endhighlight %}

####样例类
在声明样例类时，下面的过程自动发生了：

* 构造器的每个参数都成为val，除非显式被声明为var，但是并不推荐这么做；
* 在伴生对象中提供了apply方法，所以可以不使用new关键字就可构建对象；
* 提供unapply方法使模式匹配可以工作；
* 生成toString、equals、hashCode和copy方法，除非显示给出这些方法的定义。

除了上述之外，样例类和其他类型完全一样，方法字段等。

{% highlight scala %}
abstract class Amount
// 继承了普通类的两个样例类
case class Dollar(value: Double) extends Amount
case class Currency(value: Double, unit: String) extends Amount

// 样例对象
case object Nothing extends Amount

// 使用
amt match {
  case Dollar(v) => "$" + v
  case Currency(_, u) => "Oh noes, I got " + u
  case Nothing => ""  // 样例对象没有()
}
{% endhighlight %}

样例类的`copy方法`创建一个与现有对象相同的新对象。可以使用带名参数来修改某些属性：

{% highlight scala %}
val amt = Currency(29.95, "EUR")
val price = amt.copy(values = 19.95)
val price = amt.copy(unit = "CHF")
{% endhighlight %}

匹配嵌套结构:
{% highlight scala %}
abstarct class Item
case class Article(description: String, price: Double) extends Item
case class Bundle(description: String, price: Double, items: Item*) extends Item

Bundle("Father's day special", 20.0, 
  Article("Scala for the Impatient", 39.95),
  Bundle("Anchor Distillery Sampler", 10.0,
    Article("Old Potrero Straight Rye Whisky", 79.95),
    Article("Junipero Gin", 32.95)
  )
)
{% endhighlight %}

模式可以匹配到特定的嵌套：

{% highlight scala %}
case Bundle(_, _, Article(descr, _), _*) => ...
{% endhighlight %}

上面的代码中descr这个变量被绑定到第一个Article的description。另外还可以使用@来将值绑定到变量：

{% highlight scala %}
// art被绑定为第一个Article，rest是剩余的Item序列
case Bundle(_, _, art @ Article(_, _), rest @ _*) => ...
{% endhighlight %}

下面是个使用了模式匹配来递归计算Item价格的函数:

{% highlight scala %}
def price(it: Item): Double = it match {
  case Article(_, p) => p
  case Bundle(_, disc, its @ _*) => its.map(price _).sum - disc
}
{% endhighlight %}

当使用样例类来做模式匹配时，如果要让编译器确保已经列出所有可能的选择，可以将样例类的通用超类声明为sealed。`密封类`的所有子类都必须在与该密封类相同的文件中定义。如果某个类是密封的，那么在编译期所有的子类是可知的，因而可以检查模式语句的完整性。让所有同一组的样例类都扩展某个密封的类或特质是个好的做法。

可以使用样例类来模拟`枚举类型`：

{% highlight scala %}
sealed abstract class TrafficLightColor
case object Red extends TrafficLightColor
case object Yellow extends TrafficLightColor
case object Green extends TrafficLightColor

color match {
  case Red => "stop"
  case Yellow => "hurry up"
  case Green => "go"
}
{% endhighlight %}

####Option类型
Option类型用来表示可能存在也可能不存在的值。样例子类Some包装了某个值，而样例对象None表示没有值。Option支持泛型。

{% highlight scala %}
scores.get("Alice") match {
  case Some(score) => println(score)
  case None => println("No score")
}
{% endhighlight %}

一个String转Int的例子:
{% highlight scala %}
object Run extends App {
  def toInt(s: String):Option[Int] = {
    try {
      Some(s.toInt)
    } catch {
      case e:Exception => None
    }
  }
  
  val x = toInt("10") // Option[Int] = Some(10)
  val x2 = toInt("foo") // Option[Int] = None
  
  x.getOrElse(0) // 10
  x2.getOrElse(0) // 0
}
{% endhighlight %}

####偏函数
被包在花括号内的一组case语句是一个偏函数。偏函数是一个并非对所有输入值都有定义的函数，是PartialFunction[A, B]类的一个实例，其中A是参数类型，B是返回类型。该类有两个方法：apply方法从匹配的模式计算函数值；isDefinedAt方法在输入至少匹配其中一个模式时返回true。
{% highlight scala %}
val f: PartialFunction[Char, Int] = { case '+' => 1; case '-' => -1 }
f('-')  // 返回-1
f.isDefinedAt('0')  // false
f('0')  //抛出MatchError
{% endhighlight %}