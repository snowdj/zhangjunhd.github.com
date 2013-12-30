---
layout: post
title: "Scala笔记9-正则表达式"
description: "Scala笔记9-正则表达式"
category: 编程
tags: [scala]
---
{% include JB/setup %}

要构造一个Regex对象，用String类的r方法即可。如果正则表达式包含反斜杠或引号，最好使用"""..."""：

{% highlight scala %}
object Run extends App {
  val numPattern = "[0-9]+".r

  val wsnumwsPattern = """\s+[0-9]+\s+""".r // use the “raw” string syntax

  for (matchString <- numPattern.findAllIn("99 bottles, 98 bottles"))
    println(matchString) // 99 
                        //98

  val matches = numPattern.findAllIn("99 bottles, 98 bottles").toArray // Array(99, 98)

  val m0 = numPattern.findFirstIn("99 bottles, 98 bottles") // Some(99)
  val m1 = wsnumwsPattern.findFirstIn("99 bottles, 98 bottles") // Some(98)

  numPattern.findPrefixOf("99 bottles, 98 bottles") // Some(99)
  wsnumwsPattern.findPrefixOf("99 bottles, 98 bottles") // None

  numPattern.replaceFirstIn("99 bottles, 98 bottles", "XX") // "XX bottles, 98 bottles"
  numPattern.replaceAllIn("99 bottles, 98 bottles", "XX") // "XX bottles, XX bottles"
}
{% endhighlight %}

正则表达式组：在你想要提取的子表达式两侧加上圆括号:

{% highlight scala %}
object Run extends App {
  val numitemPattern = "([0-9]+) ([a-z]+)".r

  val numitemPattern(num, item) = "99 bottles" // Sets num to "99", item to "bottles"

  for (numitemPattern(num, item) <- numitemPattern.findAllIn("99 bottles, 98 bottles"))
    printf("%d,%s\n", num.toInt, item) // 99,bottles
        								  //98,bottles
}
{% endhighlight %}
