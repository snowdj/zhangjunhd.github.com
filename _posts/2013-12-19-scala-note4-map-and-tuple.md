---
layout: post
title: "Scala笔记4-映射与元组Map and Tuple"
description: "Scala笔记4-映射与元组"
category: 编程
tags: [scala]
---
{% include JB/setup %}

map的声明，赋值，追加，减少：

{% highlight scala %}
object Main extends App {
    val scores = Map("Alice" -> 10, "Bob" -> 3, "Cindy" -> 8) // an immutable map
    val scores2 = scala.collection.mutable.Map("Alice" -> 10, "Bob" -> 3, "Cindy" -> 8) // a mutable map
    val scores3 = new scala.collection.mutable.HashMap[String, Int] // a blank map

    val bobScore = scores("Bob")
    val bobScroe2 = scores.getOrElse("Bob", 0)

    // scores("Bob") = 10 // compile error!
    scores2("Bob") = 10

    // scores("Fred") = 7 // compile error!
    scores2("Fred") = 7

    // scores += ("Bob" -> 10, "Fred" -> 7) // compile error!
    scores2 += ("Bob" -> 10, "Fred" -> 7)

    // scores -= "Alice" // compile error!
    scores2 -= "Alice"

    val scores4 = scala.collection.immutable.SortedMap(
        "Fred" -> 7, "Alice" -> 10, "Bob" -> 3, "Cindy" -> 8) //sorted by key
}
{% endhighlight %}

map迭代：

{% highlight scala %}
object Main extends App {
  val scores = Map("Alice" -> 10, "Bob" -> 3, "Cindy" -> 8) // an immutable map

  for (k <- scores.keys) println(k) // print all keys
  for (v <- scores.values) println(v) // print all values
  for ((k, v) <- scores) printf("key: %s, value: %s\n", k, v)

  scores.foreach(x => println(x._1 + "-->" + x._2))
  scores.foreach { case (key, value) => println(key + "-->" + value) }

  var sum = 0
  scores.values.foreach((s) => if (s > 5) sum += s)
}
{% endhighlight %}

对每个value迭代处理，可以加入guard：

{% highlight scala %}
object Main extends App {
  val ohmygud = Map("iPad3" -> 700, "iPhone 5" -> 600, "MacBook Pro Retina" -> 2000)
  for ((k, v) <- ohmygud) yield k -> (v * 0.9)
}
{% endhighlight %}

使用map实现word count：

{% highlight scala %}
object Main extends App {
  val wordCount = collection.mutable.Map[String, Int]() withDefault (_ => 0)
  val in = new java.util.Scanner(new java.io.File("/src/zhangjunhd.scala"))
  while (in.hasNext()) wordCount(in.next()) += 1
  println(wordCount)
}
{% endhighlight %}

使用hashmap统计单字(zip)：

{% highlight scala %}
import scala.collection.mutable.HashMap
import scala.collection.mutable.LinkedHashSet

object Main extends App {
  def indexes(s: String) = {
    var res = new HashMap[Char, LinkedHashSet[Int]]()
    for ((c, i) <- s.zipWithIndex) {
        val set = res.getOrElse(c.toChar, new LinkedHashSet[Int])
        set += i
        res(c.toChar) = set
    }
    res
}

val x = indexes("Missisipi") // Map(M -> Set(0), s -> Set(2, 3, 5), p -> Set(7), i -> Set(1, 4, 6, 8))
}
{% endhighlight %}

与Java的互操作：

{% highlight scala %}
object Main extends App {
  import scala.collection.JavaConversions.mapAsScalaMap
  val scores: scala.collection.mutable.Map[String, Int] = new java.util.TreeMap[String, Int]

  import scala.collection.JavaConversions.propertiesAsScalaMap
  val props: scala.collection.Map[String, String] = System.getProperties()

  import scala.collection.JavaConversions.mapAsJavaMap
  import java.awt.font.TextAttribute._ // Import keys for map below 
  val attrs = Map(FAMILY -> "Serif", SIZE -> 12) // A Scala map
  val font = new java.awt.Font(attrs) // Expects a Java map
}
{% endhighlight %}

元组zip，partition

{% highlight scala %}
object Main extends App {
  val t = (1, 3.14, "Fred")
  val pi = t._2 // Sets pi to 3.14
  val (first, second, third) = t // Sets first to 1, second to 3.14, third to "Fred"
  val (a, b, _) = t // no need _3

  "New York".partition(_.isUpper) // Yields the pair ("NY", "ew ork"), call StringOps partition and returns a pair

  val symbols = Array("<", "-", ">")
  val counts = Array(2, 10, 2)
  val pairs = symbols.zip(counts) // Array(("<", 2), ("-", 10), (">", 2))
  for ((s, n) <- pairs) Console.print(s * n)
}
{% endhighlight %}
