---
layout: post
title: "Scala笔记3-数组"
description: "Scala笔记3-数组，与Java互操作"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####定长数组

{% highlight scala %}
object Main extends App {
  val nums = new Array[Int](10) //An integer array with 10 elements,all initialized with 0
        
  val a = new Array[String](10) //A string array with 10 elements,all initialized with null

  val s = Array("Hello", "World")// An Array[String] of length 2—the type is inferred
                                  // Note: No new when you supply initial values

  s(0) = "Goodbye" // Array("Goodbye", "World")
        
  val joinedArray = a ++ s
}
{% endhighlight %}

####变长数组：ArrayBuffer

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  val b = ArrayBuffer[Int]()

  b += 1 // ArrayBuffer(1)

  b += (1, 2, 3, 5) // ArrayBuffer(1, 1, 2, 3, 5)

  b ++= Array(8, 13, 21) // ArrayBuffer(1, 1, 2, 3, 5, 8, 13, 21)

  b.trimEnd(5) // ArrayBuffer(1, 1, 2)

  b.insert(2, 6) // ArrayBuffer(1, 1, 6, 2)

  b.insert(2, 7, 8, 9) // ArrayBuffer(1, 1, 7, 8, 9, 6, 2)

  b.remove(2) // ArrayBuffer(1, 1, 8, 9, 6, 2)

  b.remove(2, 3) // ArrayBuffer(1, 1, 2)

  b.toArray // Array(1, 1, 2)
}
{% endhighlight %}

####数组遍历

{% highlight scala %}
object Main extends App {
  val a = new Array[String](10)

  for (i <- 0 until a.length) // Range(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    println(i + ": " + a(i))

  for (i <- 0 until (a.length, 2)) // Range(0, 2, 4, ...)
    println(i + ": " + a(i))

  for (i <- (0 until a.length).reverse) // Range(..., 2, 1, 0)
    println(i + ": " + a(i))

  for (ele <- a)  // No need array index
    println(ele)
}
{% endhighlight %}

####数组转换

for(...)yield循环创建一个类型与原始集合相同的新集合。通常，遍历一个集合时，可以加入guard来过滤特定条件的元素。

{% highlight scala %}
object Main extends App {
  val a = Array(2, 3, 5, 7, 11)
  val result = for (elem <- a) yield 2 * elem // result is Array(4, 6, 10, 14, 22)

  for (elem <- a if elem % 2 == 0) yield 2 * elem
}
{% endhighlight %}

给定一个ArrayBuffer[Int]，移除第一个负数之外的所有负数。

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  val a = ArrayBuffer(2, -3, -5, 7, 11)

  var first = true
  var n = a.length
  var i = 0

  while (i < n) {
      if (a(i) >= 0) i += 1
      else {
          if (first) { first = false; i += 1 }
          else { a.remove(i); n -= 1; }
      }
  }
}
{% endhighlight %}

从ArrayBuffer中移除元素并不高效，把非负元素拷贝到前端要好很多：

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  val a = ArrayBuffer(2, -3, -5, 7, 11)

  var first = true
  val indexes = for (i <- 0 until a.length if first || a(i) >= 0) yield {
    if (a(i) < 0) first = false; i
  }
  
  for (j <- 0 until indexes.length) a(j) = a(indexes(j))
  a.trimEnd(a.length - indexes.length)
}
{% endhighlight %}

####常用算法
sum,min,max,count,sort,mkString:

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  Array(1, 7, 2, 9).sum //19
  Array(1, 7, 2, 9).min //1
  Array(1, 7, 2, 9).max //9
  
  def lteqgt(values: Array[Int], v: Int) =
    (values.count(_ < v), values.count(_ == v), values.count(_ > v))

  ArrayBuffer("Mary", "had", "a", "little", "lamb").max // little

  val b = ArrayBuffer(1, 7, 2, 9)
  val bSorted = b.sorted //b is unchanged;ArrayBuffer(1, 2, 7, 9)
  val bSorted2 = b.sortWith(_ < _) //ArrayBuffer(1, 2, 7, 9)
  val bDescending = b.sortWith(_ > _) //ArrayBuffer(9, 7, 2, 1)
    
  val a = b.toArray
  scala.util.Sorting.quickSort(a)//a is Array(1, 2, 7, 9)
    
  a.mkString(" and ") // 1 and 2 and 7 and 9
  a.mkString("<", ",", ">") // <1,2,7,9>
}
{% endhighlight %}

####多维数组

使用grouped将Array分拆为多维数组:

{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  val matrix = Array.ofDim[Double](3, 4) // Three rows, four columns

  // matrix(row)(column) = 42

  // You can make ragged arrays, with varying row lengths:
  val triangle = new Array[Array[Int]](10)
  for (i <- 0 until triangle.length)
    triangle(i) = new Array[Int](i + 1)

  def arrayDim(a: Array[Int], numOfDim: Int) = a.grouped(numOfDim).toArray.map(_.toArray)
}
{% endhighlight %}

####与Java互操作

{% highlight scala %}
object Main extends App {
  //java.lang.ProcessBuilder class has a constructor with a List<String> parameter. 
  //Here is how you can call it from Scala:
  import scala.collection.JavaConversions.bufferAsJavaList
  import scala.collection.mutable.ArrayBuffer
    
  val command = ArrayBuffer("ls", "-al", "/home/cay")
  val pb = new ProcessBuilder(command) // Scala to Java

  //when a Java method returns a java.util.List, 
  //you can have it automatically converted into a Buffer:
  import scala.collection.JavaConversions.asScalaBuffer
  import scala.collection.mutable.Buffer
  val cmd: Buffer[String] = pb.command() // Java to Scala
  // You can’t use ArrayBuffer—the wrapped object is only guaranteed to be a Buffer
}
{% endhighlight %}