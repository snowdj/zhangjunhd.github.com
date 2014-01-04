---
layout: post
title: "Scala笔记9-正则表达式与文法解析"
description: "Scala笔记9-正则表达式"
category: 编程
tags: [scala]
---
{% include JB/setup %}
####正则表达式
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

####正则表达式组
在你想要提取的子表达式两侧加上圆括号:

{% highlight scala %}
object Run extends App {
  val numitemPattern = "([0-9]+) ([a-z]+)".r

  val numitemPattern(num, item) = "99 bottles" // Sets num to "99", item to "bottles"

  for (numitemPattern(num, item) <- numitemPattern.findAllIn("99 bottles, 98 bottles"))
    printf("%d,%s\n", num.toInt, item) // 99,bottles
        								  //98,bottles
}
{% endhighlight %}

####文法
所谓`文法`(grammar)，指的是一组用于产出所有遵循某个特定结构的字符串的规则。文法通常以一种被称为`巴斯克范式`(BNF)的表示法编写。

    digit ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
    number::= digit | digit number
    op    ::= "+" | "-" | "*"
    expr  ::= number | expr op expr | "(" expr ")"

更高效的做法是在解析开始之前就收集好数字，这个单独的步骤叫做`词法分析`(lexical analysis)。`词法分析器`(lexer)会丢弃掉空白和注释并形成`词法单元`(token)——标识符、数字或符号。

在我们的表达式中，词法单元为number和符号+-*()。op和expr不是词法单元。它们是结构化的元素，是文法的作者创造出来的，目的是产出正确的词法单元序列。这样的符号被称为`非终结符号`。其中有个非终结符号位于层级的顶端，在我们的示例当中就是expr。这个非终结符号被称为`起始符号`，要产出正确格式的字符串，你应该从起始符号开始，持续应用文法规则，直到所有的非终结符号都被替换掉，只剩下词法单元:

    expr -> expr op expr -> number op expr -> number "+" expr -> number "+" number

表明3+4是个合法的表达式。

最常用的“扩展巴斯克范式”，或称EBNF，允许给出可选元素和重复。将使用正则操作符?*+来分别表示0个或1个、0个或更多、1个或更多。

####组合解析器操作
为了使用scala解析库，我们需要提供一个扩展自Parsers特质的类并定义那些由基本操作组合起来的解析操作，基本操作包括:

* 匹配一个词法单元
* 在两个操作之间做选择(|)
* 依次执行两个操作(~)
* 重复一个操作(rep)
* 可选择地执行一个操作(opt)

{% highlight scala %}
import scala.util.parsing.combinator.RegexParsers

class ExprParser extends RegexParsers {
  val number = "[0-9]".r
    
  def expr: Parser[Any] = term ~ opt(("+" | "-") ~ expr)
  def term: Parser[Any] = factor ~ rep("*" ~ factor)
  def factor: Parser[Any] = number | "(" ~ expr ~ ")"
}

object Main extends App {
  val parser = new ExprParser
  val result = parser.parseAll(parser.expr, "3-4*5")
  if (result.successful) println(result.get)
}
{% endhighlight %}
 
上述程序的输出`((3~List())~Some((-~((4~List((*~5)))~None))))`，解读这个结果:

* 字符串字面量和正则表达式返回String值
* p ~ q返回~样例类的一个实例
* opt(p)返回一个Option，要么是Some(...)，要么是None
* rep(p)返回一个List

####解析器结果变换
与其让解析器构建出一整套由~、可选项和列表构成的复杂结构，不如将中间输出变换成有用的形式。

{% highlight scala %}
import scala.util.parsing.combinator.RegexParsers

class ExprParser extends RegexParsers {
  val number = "[0-9]".r
    
  def expr: Parser[Int] = term ~ opt(("+" | "-") ~ expr) ^^ {
    case t ~ None => t
    case t ~ Some("+" ~ e) => t + e
    case t ~ Some("-" ~ e) => t - e
  }
  def term: Parser[Int] = factor ~ rep("*" ~ factor) ^^ {
    case f ~ r => f * r.map(_._2).product
  }
  def factor: Parser[Int] = number ^^ {_.toInt}| "(" ~ expr ~ ")" ^^ {
    case _ ~ e ~ _ => e
  }
}

object Main extends App {
  val parser = new ExprParser
  val result = parser.parseAll(parser.expr, "3-4*5")
  if (result.successful) println(result.get) //-17
}
{% endhighlight %}

* ^^符号并没有什么特别的意义，它只是恰巧比~优先级低，但又比|优先级高
* 对于解析来说，词法单元是必须的，但在匹配之后它们通常可以被丢弃。~>和<~操作符可以用来匹配并丢弃词法单元。

{% highlight scala %}
def term: Parser[Int] = factor ~ rep("*" ~> factor) ^^ {
  case f ~ r => f * r.product
}

def factor: Parser[Int] = number ^^ {_.toInt}| "(" ~> expr <~ ")"
{% endhighlight %}

