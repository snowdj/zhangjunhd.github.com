---
layout: post
title: "scala笔记16-xml"
description: "scala笔记16-xml"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####XML节点类型

![zen](http://www.codecommit.com/blog/wp-content/uploads/2010/05/s6EW-5XuGuUAjHDi-zmvofQ.png)

{% highlight scala %}
import scala.xml.NodeBuffer
import scala.xml.NodeSeq
import scala.xml.Attribute

object Run extends App {
  val doc = <html><head><title>This is title</title></head><body>...</body></html>
  val items = <li>Jeff</li><li>Kean</li>;

  val items2 = new NodeBuffer
  items2 += <li>Jeff</li>
  items2 += <li>Kean</li>
  val nodes: NodeSeq = items

  val elem = <a href="http://zhangjunhd.github.io"> The <em> ZJ </em> blog</a>
  for (n <- elem.child)
    n.text // do something with n
        
  val url = elem.attributes("href") //  Seq[scala.xml.Node]
  val url_str = elem.attributes("href").text // String
  val url_option = elem.attributes.get("href") //  Option[Seq[scala.xml.Node]]
    
  for (attr <- elem.attributes) {
    attr.key // do something with key
    attr.value.text // do something with value
  }
    
  val attrMap = elem.attributes.asAttrMap // Map[String,String]
  
  // modify Elem
  val list = <ul><li>Jeff</li><li>Kean</li></ul>
  val list2 = list.copy(label = "ol") // scala.xml.Elem = <ol><li>Jeff</li><li>Kean</li></ol>
  val list3 = list.copy(child = list.child ++ <li>Less</li>) // scala.xml.Elem = <ul><li>Jeff</li><li>Kean</li><li>Less</li></ul>
  
  // modify attr
  val img = <img src="a.jpg"/>
  val img2 = img % Attribute(null, "alt", "An image", scala.xml.Null) // scala.xml.Elem = <img alt="An image" src="a.jpg"/>
  val img3 = img % Attribute(null, "alt", "An image", Attribute(null, "src", "b.jpg", scala.xml.Null)) // scala.xml.Elem = <img src="b.jpg" alt="An image"/>
}
{% endhighlight %}

* scala对xml有内建支持。可以定义xml字面量，直接用xml代码即可
* doc是 scala.xml.Elem
* items是 scala.xml.NodeBuffer，它是一个Seq[Node]，可以被隐式转换为NodeSeq，见items2
* elem也是scala.xml.Elem，代码中列举了几种获取它的attribute的方法
* list,list2,list3演示了如何修改元素
* img,img2,img3演示了如何修改属性

####内嵌表达式

{% highlight scala %}
import scala.xml.Atom
import scala.xml.PCData

object Run extends App {
  val values = Array("Jeff", "Kean")
    
  val items = <li>{values(0)}</li><li>{values(1)}</li>;

  val items2 = <ul>{for (i <- values) yield <li>{i}</li>}</ul>
    
  def makeURL(n:String) = {
    "http://%s".format(n)
  }
    
  val elem = <img src={makeURL("somename")}/>
  val elem2 = <a id={new Atom(1)}/>
    
  val code = """if (tmp < 0) alert("Cold!")"""
  val js = <script>{PCData(code)}</script>
}
{% endhighlight %}

* 在xml模式中，花括号代表代码模式
* 可以在xml字面量中包含scala代码，而且，被内嵌的scala代码可以继续包含xml字面量，见items，items2
* 可以用scala表达式计算属性值，见elem，elem2
* 如果要在输出中带有CDATA，可以包含一个PCData节点，见js

####XPath表达式

{% highlight scala %}
object Run extends App {
  val list = <dl><dt>Java</dt><dd>Gosling</dd><dt>Scala</dt><dd>Odersky</dd></dl>
  val lang = list \ "dt" //  scala.xml.NodeSeq = <dt>Java</dt><dt>Scala</dt>

  val fruits = List("apple", "banana", "orange")
  val fruits2 = List("apple2", "banana2", "orange2")

  val jeff = <ul1 name="jeff">{fruits.map(i => <li>{i}</li>)}</ul1> // scala.xml.Elem = <Jeff><li>apple</li><li>banana</li><li>orange</li></Jeff>
  val kean = <ul2 name="kean">{fruits2.map(i => <li>{i}</li>)}</ul2>
  val doc = <doc>{jeff}{kean}</doc>
    
  val getAll = doc \ "_" \ "li" // scala.xml.NodeSeq = <li>apple</li><li>banana</li><li>orange</li><li>apple2</li><li>banana2</li><li>orange2</li>
  val getAll2 = doc \\ "li" // the same as getAll
  val getJeff = doc \ "ul1" \ "li" // scala.xml.NodeSeq = <li>apple</li><li>banana</li><li>orange</li>
  val getAllName = doc \\ "@name" // scala.xml.NodeSeq = jeffkean
  val getKeanName = kean \ "@name" // scala.xml.NodeSeq = kean
  
  val v = (doc \\ "li").map(_.text) //  scala.collection.immutable.Seq[String] = List(apple, banana, orange, apple2, banana2, orange2)
}
{% endhighlight %}

* \操作符定位某个节点或节点序列的直接后代
* 通配符可以匹配任何元素
* \\操作符可以定位任何深度的后代
* 以@开头的字符串定位属性

####模式匹配

* 可以在模式匹配表达式中使用xml字面量，如：

{% highlight scala %}
node match {
  case <img/> => ...
  ...
}
{% endhighlight %}

如果node是一个带有任何属性但没有后代的img元素，则第一个匹配会成功。

* 匹配单个后代:`case <li>{_}</li> => ...`
* 匹配多于一个后代，如`<li> An <em>important</em> item</li>:case <li>{_*}</li>=>...`
* 除了通配符，也可使用变量名，匹配上的内容会被绑到该变量上:`case <li>{elem}</li>=> elem.text`
* 匹配一个文本节点:`case <li>{Text(item)}</li> => item`
* 把节点序列绑到变量:`case <li>{children @ _*}</li> => for (c <- children) yield c`
* 在case语句中，只能用一个节点。下列语句非法:`case <p>{_*}</p></br> => ...//Error`
* xml模式不能有属性:`case <img alt="TODO"/> => ... // Error`
* 匹配属性可以使用守卫:`case n @ <img/> if (n.attributes("alt").text == "TODO") => ...`

xml类库提供了一个RuleTransformer类，该类可以将一个或多个RewriteRule实例应用到某个节点极其后代。

{% highlight scala %}
import scala.xml.transform.RewriteRule
import scala.xml.Node
import scala.xml.Elem
import scala.xml.transform.RuleTransformer

object Run extends App {
  val rule1 = new RewriteRule {
      override def transform(n : Node) = n match {
          case e @ <ul>{_*}</ul> => e.asInstanceOf[Elem].copy(label="ol")
          case _ => n
      }
  }
  
  val rule2 = new RewriteRule{}
  val rule3 = new RewriteRule{}
  
  val root = <html>a</html>
  
  val transformed = new RuleTransformer(rule1).transform(root)
  val transformed2 = new RuleTransformer(rule1, rule2, rule3).transform(root)
}
{% endhighlight %}

####加载与保持
{% highlight scala %}
import scala.xml.XML
import java.io.FileInputStream
import java.io.InputStreamReader
import java.net.URL

object Run extends App {
  val root = XML.loadFile("myfile.xml")
  val root2 = XML.load(new FileInputStream("myfile.xml"))
  val root3 = XML.load(new InputStreamReader(new FileInputStream("myfile.xml"), "UTF-8"))
  val root4 = XML.load(new URL("http://zhangjunhd.github.io/index.html"))
  
  XML.save("myfile.xml", root)
}
{% endhighlight %}

####命名空间
{% highlight scala %}
import scala.xml.NamespaceBinding
import scala.xml.TopScope
import scala.xml.Attribute
import scala.xml.Null
import scala.xml.Elem

object Run extends App {
  val scope = new NamespaceBinding("svg", "http://www.w3.org/2000/svg", TopScope)
  val attrs = Attribute(null, "width", "100", Attribute(null, "height", "100", Null))
  val elem = Elem(null, "body", Null, TopScope, Elem("svg", "svg", attrs, scope)) // <body><svg:svg width="100" height="100" xmlns:svg="http://www.w3.org/2000/svg"/></body>
}
{% endhighlight %}
