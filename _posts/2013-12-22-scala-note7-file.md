---
layout: post
title: "Scala笔记7-文件操作File"
description: "Scala笔记7-文件读写，序列化"
category: 编程
tags: [scala]
---
{% include JB/setup %}

读文件

{% highlight scala %}
object Run extends App {
  import scala.io.Source
  val source = Source.fromFile("myfile.txt", "UTF-8")
  // The first argument can be a string or a java.io.File
  // You can omit the encoding if you know that the file uses the default platform encoding

  for (c <- source) println(c) // c is a Char

  val lineIterator = source.getLines
  for (l <- lineIterator) println(l) // l is a String

  val lines = source.getLines.toArray // the whole content as an Array

  val contents = source.mkString // the whole content as a String
}
{% endhighlight %}

缓存读，想查看某个字符，但不想一下子处理掉它

{% highlight scala %}
object Run extends App {
  import scala.io.Source
  val source = Source.fromFile("myfile.txt", "UTF-8")

  val iter = source.buffered
  while (iter.hasNext) {
      if (iter.head == 'B') println(iter.next)
      else iter.next
  }
 
  source.close()
}
{% endhighlight %}

读文件并分成一个个单词，转换成数字

{% highlight scala %}
object Run extends App {
  import scala.io.Source
  val source = Source.fromFile("myfile.txt", "UTF-8")

  val tokens = source.mkString.split("\\s+")
    
  val numbers = for (w <- tokens) yield w.toDouble
  val numbers2 = tokens.map(_.toDouble)
}
{% endhighlight %}

从控制台读取数字

{% highlight scala %}
object Run extends App {
  print("How old are you? ")
  val age = readInt() // Or use readDouble or readLong
}
{% endhighlight %}

从其他源读取

{% highlight scala %}
object Run extends App {
  import scala.io.Source
  val source1 = Source.fromURL("http://horstmann.com", "UTF-8")
  val source2 = Source.fromString("Hello, World!") // Reads from the given string—useful for debugging 
  val source3 = Source.stdin // Reads from standard input
}
{% endhighlight %}

读取二进制文件

{% highlight scala %}
import java.io.File
import java.io.FileInputStream
import scala.io.Source

object Run extends App {
  val file = new File("myfile")
  val in = new FileInputStream(file)
  val bytes = new Array[Byte](file.length.toInt)
  in.read(bytes)
  in.close()
}
{% endhighlight %}

写入文本文件

{% highlight scala %}
import java.io.PrintWriter

object Run extends App {
  val out = new PrintWriter("numbers.txt")
  for (i <- 1 to 100) out.println(i)
  out.close()
    
  // use string format
  val quantity = 100
  val price = .1
  out.print("%6d %10.2f".format(quantity, price))
}
{% endhighlight %}

访问目录

遍历所有子目录

{% highlight scala %}
object Run extends App {
  import java.io.File
  def subdirs(dir: File): Iterator[File] = {
      val children = dir.listFiles.filter(_.isDirectory)
      children.toIterator ++ children.toIterator.flatMap(subdirs _)
  }
}
{% endhighlight %}

java.nio.file.Files类的walkFileTree方法

{% highlight scala %}
object Run extends App {
  import java.nio.file._
  implicit def makeFileVisitor(f: (Path) => Unit) = new SimpleFileVisitor[Path] {
      override def visitFile(p: Path, attrs: attribute.BasicFileAttributes) = {
          f(p)
          FileVisitResult.CONTINUE
      }
  }
    
  // Print all subdirectories with the call
  import java.io.File
  val dir:File = new File("/tmp")
  // public static Path walkFileTree(Path start, FileVisitor<? super Path> visitor)
  // Here implicit conversion adapts a function to the interface(FileVisitor)
  Files.walkFileTree(dir.toPath, (f: Path) => println(f)) 
}
{% endhighlight %}

序列化

{% highlight scala %}
@SerialVersionUID(42L) class Person extends Serializable

object Run extends App {
  val fred = new Person
  import java.io._
  val out = new ObjectOutputStream(new FileOutputStream("/tmp/test.obj"))
  out.writeObject(fred)
  out.close()
  val in = new ObjectInputStream(new FileInputStream("/tmp/test.obj"))
  val savedFred = in.readObject().asInstanceOf[Person]
}
{% endhighlight %}