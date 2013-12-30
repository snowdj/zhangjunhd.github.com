---
layout: post
title: "Scala笔记11-apply函数"
description: "Scala笔记11-apply,update,unapply,unapplySeq"
category: 编程
tags: [scala]
---
{% include JB/setup %}

`apply`和`update`方法:如果f不是方法或者是函数：

{% highlight scala %}
f(arg1, arg2, ...)
// 相当于
f.apply(arg1, arg2, ...)

f(arg1, arg2, ...) = value
// 相当于
f.update(arg1, arg2, ..., value)
{% endhighlight %}

apply方法经常被用在伴生对象中用来构造对象，可以省去使用new来创建对象。而update方法经常被使用在于数据和映射之类的集合有关的地方。

`提取器`是一个带有`unapply`方法的对象。unapply方法算是apply方法的反向操作：unapply接受一个对象，然后从对象中提取值，提取的值通常是用来构造该对象的值。 

{% highlight scala %}
// 有一个表示分数的Fraction类以及其伴生对象
class Fraction(n: Int, d: Int) {
  ...
}

object Fraction(n: Int, d: Int) {
  def apply(n: Int, d: Int) = new Fraction(n, d)
  def unapply(input: Fraction) = 
    if (input.den == 0) None else Some((input.num, input.den))
}

// 取出值
var Fraction(a, b) = Fraction(3, 4) * Fraction(2, 5)
// 用于模式匹配
case Fraction(a, b) => ...
{% endhighlight %}

在Scala中，没有只带一个组元的元组。如果unapply方法要提取单值，应该返回一个目标类型的Option。 

{% highlight scala %}
object Number {
  def unapply(input: String): Option[Int] =
  try {
      Some(Integer.parseInt(input.trim))
    } catch {
      case ex: NumberFormatException => None
    }
}
{% endhighlight %}

提取器可以只测试其输入而不将值提取出来，此时，unapply方法应返回Boolean。

{% highlight scala %}
object IsCompound {
  def unapply(input: String) = input.contains(" ")
}

author march {
  case Name(first, last @ IsCompound()) => ...
  case Name(first, last) => ...
}
{% endhighlight %}

要提取任意长度的值的序列，使用`unapplySeq`方法。此方法返回Option[Seq[A]]，A是被提取的值的类型。 

{% highlight scala %}
object Name {
  def unapplySeq(input: String): Option[Seq[String]] =
    if (input == "") None else Some(input.trim.split("\\s+"))
}
{% endhighlight %}
