---
layout: post
title: "Scala笔记2-控制结构与函数condition and function"
description: "Scala笔记2-控制结构与函数"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####条件表达式

{% highlight scala %}
val x = if (a > b) a else b

def abs(x: Int) = if (x >= 0) x else -x
{% endhighlight %}

####循环
{% highlight scala %}
object Main extends App {
  val s = "Hello"
  
  for (i <- 0 to s.length - 1)
    print(s(i))

  for (i <- 0 until s.length)
    print(s(i))
    
  for (c <- s)
    print(c)
}
{% endhighlight %}

在for循环中嵌入if；在for中使用临时变量：

{% highlight scala %}
object Main extends App {
  for (i <- 1 to 3; j <- 1 to 3 if i != j)
    printf("%d-%d\n", i, j)

  for (i <- 1 to 3; from = 4 - i; j <- from to 3)
    printf("%d-%d\n", i, j)
}
{% endhighlight %}

在for循环中嵌入多个if：

{% highlight scala %}
import scala.io.Source
import scala.collection.mutable.ArrayBuffer

object Main extends App {
  /**
   * Get the contents of a text file while skipping over comment lines and
   * blank lines. This is useful when reading a data file that can have lines
   * beginning with '#', or blank lines, such as a file that looks like this:
   *   -------------------
   *   foo
   *   # this is a comment
   *
   *   bar
   *   -------------------
   */
  def getFileContentsWithoutCommentLines(filename: String): List[String] = {
    var lines = new ArrayBuffer[String]()
    for ( line <- Source.fromFile(filename).getLines 
        if !line.trim.matches("") 
        if !line.trim.matches("#.*")) {
      lines += line
    }
    lines.toList
  }

  val lines = getFileContentsWithoutCommentLines("test.dat")
  lines.foreach(println)
}
{% endhighlight %}

如果for循环的循环体以yeild开始，则该循环会构造出一个集合，且生成的集合与它的第一个生成器是类型兼容的：

{% highlight scala %}
object Main extends App {
  val s = for (c <- "Hello"; i <- 0 to 1) yield (c + i).toChar
  println(s) // HIeflmlmop

  val s2 = for (i <- 0 to 1; c <- "Hello") yield (c + i).toChar
  println(s2) // Vector(H, e, l, l, o, I, f, m, m, p)
}
{% endhighlight %}

####函数的变长参数

如果sum函数被调用时传入的是单个参数，那么该参数必须是单个整数，而不是一个整数区间。解决的办法是追加：_*，这样告诉编译器这个参数被当作参数序列处理。

{% highlight scala %}
object Main extends App {
  def sum(args: Int*) = {
    var res = 0
    for (arg <- args) res += arg
      res
  }

  sum(1, 2, 3, 4, 5)
  sum(1 to 5) // error
  sum(1 to 5: _*)
}
{% endhighlight %}

在递归时需要使用这样的技巧，注意递归函数必须标明返回值类型：

{% highlight scala %}
def recursiveSum(args: Int*): Int = {
  if (args.length == 0) 0
  else args.head + recursiveSum(args.tail: _*)
}
{% endhighlight %}

