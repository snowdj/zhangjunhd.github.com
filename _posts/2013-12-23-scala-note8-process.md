---
layout: post
title: "Scala笔记8-进程控制"
description: "Scala笔记8-进程控制ProcessBuilder"
category: 编程
tags: [scala]
---
{% include JB/setup %}

sys.process包包含了一个从字符串到ProcessBuilder对象的隐式转换。！操作符执行的就是这个ProcessBuilder对象。

{% highlight scala %}
object Run extends App {
  import sys.process._ 
  val result = "ls -al .." ! // result is 0 if command is done succeed
    
  // pipe the output of one program into the input of another, using the #| operator
  "ls -al .." #| "grep z" ! 
    
  // pipe the output of one program into the input of another, using the #| operator
  import java.io.File
  "ls -al .." #> new File("output.txt") !
    
  // To append to a file, use #>> instead:
  "ls -al .." #>> new File("output.txt") !
    
  // To redirect input from a file, use #<:
  "grep sec" #< new File("output.txt") !
    
  // You can also redirect input from a URL:
  import java.net.URL
  "grep Scala" #< new URL("http://horstmann.com/index.html") !
}
{% endhighlight %}

如果需要在不同的目录下运行进程，或者使用不同的环境变量，用Process对象的apply方法来构造ProcessBuilder，给出命令和起始目录，以及一串(key, value)对来设置环境变量:

{% highlight scala %}
import java.io.File

object Run extends App {
  import sys.process._ 
  val cmd = "ls -al"
  val dirName = "/tmp"
  val p = Process(cmd, new File(dirName), ("LANG", "en_US"))
    
  "echo 42" #| p !
}
{% endhighlight %}