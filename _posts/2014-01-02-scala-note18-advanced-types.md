---
layout: post
title: "scala笔记18-高级类型"
description: "scala笔记18-高级类型"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####单例类型
{% highlight scala %}
class Document {
  def setTitle(title : String) = {/* ... */;this}
  def setAuthor(author : String) = {/* ... */;this}
}

object Test extends App {
  val doc = new Document()
  doc.setTitle("Title").setAuthor("Auth")
}
{% endhighlight %}

对于`doc.setTitle("Title").setAuthor("Auth")`不能适用于子类:

{% highlight scala %}
class Book extends Document {
  def addChapter(chap : String) = {/* ... */;this}
}

object Test extends App {
  val book = new Book()
  book.setTitle("book title").addChapter("ch") // error
}
{% endhighlight %}

错误的原因在于setTitle()返回的是this，scala将返回类型推断为Document，而Document没有addChapter()。解决的办法是声明setTitle的返回类型为`this.type`:

{% highlight scala %}
def setTitle(title : String) : this.type = {/* ... */;this}
{% endhighlight %}

如果想要定义一个接受object实例作为参数的方法，也可以使用`单例类型`。
{% highlight scala %}
object Title

class Document {
  private var useNextArgAs : Any = null
  var title = ""
  def set(obj : Title.type) : this.type = {useNextArgAs = obj;this}
  def to(arg:String) = if (useNextArgAs == Title) title = arg
}

object Test extends App {
  val doc = new Document()
  doc.set(Title).to("title")
}
{% endhighlight %}

####结构类型
所谓`“结构类型”`指的是一组关于抽象方法、字段和类型的规格说明，这些抽象方法、字段和类型是满足该规格的类型必须具备的。结构类型和诸如JavaScript或Ruby这样的动态类型语言中的“鸭子类型”很相似。例如，如下方法带有一个结构类型参数target:

{% highlight scala %}
def appendLines(target:{def append(str:String):Any}, lines:Iterable[String]) {
  for (l <- lines) {target.append(l); target.append("\n")}
}
{% endhighlight %}

####存在类型
存在类型被加入scala是为了与Java的类型通配符兼容。scala的类型通配符只不过是存在类型的“语法糖”。

* `Array[_ <: JComponent]`等同于`Array[T] forSome {type T <: JComponent}`
* `Array[_]`等同于`Array[T] forSome {type T}`
* `Map[_,_]`等同于`Map[T,U] forSome {type T; type U}`

forSome可以表达更复杂的关系:

* `Map[T,U] forSome {type T; type U <: T}`

可以在forSome代码块中使用val 声明:

* `n.Member forSome {val n : Network}`

你完全可以用类型投影[Network#Member](http://zhangjunhd.github.io/2013/12/20/scala-note5-class.html)。不过有更复杂的情况:

* `def process[M <: n.Member forSome {val n : Network}](m1:M, m2:M) = (m1,m2)`

该方法将会接收相同网络的成员，但拒绝来自不同网络的成员:

{% highlight scala %}
val chatter = new Network
val myFace = new Network
val fred = chatter.join("Fred")
val wilma = chatter.join("Wilma")
val barney = myFace.join("Barney")

process(fred, wilma) // OK
process(fred, barney) // Error
{% endhighlight %}

####蛋糕模式
在scala中，可以通过特质和[自身类型](http://zhangjunhd.github.io/2013/12/25/scala-note10-trait.html)达到一个简单的依赖注入的效果。

{% highlight scala %}
trait Logger {def log(msg:String)}

trait Auth {
  this: Logger =>
    def login(id:String, password:String):Boolean
}

trait App {
  this : Logger with Auth =>
      def foo()
}

object MyApp extends App with FileLogger("test.log") with MockAuth("user.txt")
{% endhighlight %}

* 代码定义一个日志功能的trait Logger，并有两个该trait的实现，ConsoleLogger和FileLogger。
* 用户认证的trait Auth有一个对日志功能的依赖，用于记录认证失败
* 应用逻辑App有赖于上述两个trait
* 最后组装应用MyApp

像这样使用trait的组合有些变扭。毕竟一个应用程序并非是认证器和文件日志的合体。它拥有这些组件，更自然的表述方式可能是通过实例变量来表示组件，而不是将组件粘合成一个大类型。`蛋糕模式`给出了更好的设计。在这个模式中，你对每个服务提供一个组件特质，该特质包含：

* 任何所依赖的组件，以自身类型描述
* 描述服务接口的特质
* 一个抽象的val，该val将被初始化成服务的一个实例
* 可以有选择地包含服务接口的实现

{% highlight scala %}
trait LoggerComponent {
  trait Logger { /* ... */ }
  val logger : Logger
  class FileLogger(file:String) extends Logger { /* ... */ }
  // ...
}

trait AuthComponent {
  this: LoggerComponent =>

  trait Auth { /* ... */ }
  val auth : Auth
  class MockAuth(file:String) extends Auth { /* ... */ }
  //...
}

object AppComponent extends App with LoggerComponent with AuthComponent {
  val logger = new FileLogger("text.log")
  val auth = new MockAuth("user.txt")
}
{% endhighlight %}

####抽象类型
类或特质可以定义一个在子类中被具体化的`抽象类型`(abstract type):
{% highlight scala %}
import scala.io.Source
import java.awt.image.BufferedImage
import javax.imageio.ImageIO
import java.io.File

trait Reader {
  type Contents
  def read(fileName:String):Contents
}

class StringReader extends Reader {
  type Contents = String
  def read(fileName:String) = Source.fromFile(fileName, "UTF-8").mkString
}

class ImageReader extends Reader {
  type Contents = BufferedImage
  def read(fileName:String) = ImageIO.read(new File(fileName))
}
{% endhighlight %}

同样的效果也可以通过类型参数来实现:
{% highlight scala %}
import scala.io.Source
import java.awt.image.BufferedImage
import javax.imageio.ImageIO
import java.io.File

trait Reader[C] {
  def read(fileName:String):C
}

class StringReader extends Reader[String] {
  def read(fileName:String) = Source.fromFile(fileName, "UTF-8").mkString
}

class ImageReader extends Reader[BufferedImage] {
  def read(fileName:String) = ImageIO.read(new File(fileName))
}
{% endhighlight %}

哪种方式更好？scala的经验法则:

* 如果类型是在类被实例化时给出，则使用类型参数
* 如果类型是在子类中给出，则使用抽象类型

####家族多态
设计一个管理监听器的通用机制:
{% highlight scala %}
import scala.collection.mutable.ArrayBuffer
import java.awt.event.ActionEvent

//在Java中，每个监听器接口有各自不同的方法名称对应事件的发生:actionPerformed、stateChanged、itemStateChanged等。现在将这些方法统一起来：
trait Listener[E] {
  def occurred(e:E):Unit
}

//事件源需要一个监听器集合和一个触发这些监听器的方法：
trait Source[E, L <: Listener[E]] {
  private val listeners = new ArrayBuffer[L]
  def add(l:L) {listeners += l}
  def remove(l:L) {listeners -= l}
  def fire(e:E) {for (l<-listeners) l.occurred(e)}
}

//考虑按钮触发动作事件，定义如下监听器类型：
trait ActionListener extends Listener[ActionEvent]

//Button类可以混入Source特质：
class Button extends Source[ActionEvent, ActionListener] {
  def click() { fire(new ActionEvent(this, ActionEvent.ACTION_PERFORMED, "click"))}
}
{% endhighlight %}

Button类不需要重复那些监听器管理的代码，并且监听器是类型安全的。你没法给按钮加上ChangeListener。ActionEvent类将事件源设置为this，但是事件源的类型为Object。我们可以用自身类型来让它也是类型安全的：
{% highlight scala %}
import scala.collection.mutable.ArrayBuffer

trait Event[S] {
  var source:S = _
}

trait Listener[S, E <: Event[S]] {
  def occurred(e:E):Unit
}

trait Source[S, E <: Event[S], L <: Listener[S, E]] {
  this: S =>
  private val listeners = new ArrayBuffer[L]
  def add(l:L) {listeners += l}
  def remove(l:L) {listeners -= l}
  def fire(e:E) {
    e.source = this //这里需要自身类型
    for (l<-listeners) l.occurred(e)}
}

class ButtonEvent extends Event[Button]

trait ButtonListener extends Listener[Button, ButtonEvent]

class Button extends Source[Button, ButtonEvent, ButtonListener] {
  def click() { fire(new ButtonEvent)}
}
{% endhighlight %}

类型参数扩展的很厉害，如果使用抽象类型，代码会好看一些:
{% highlight scala %}
trait ListenerSupport {
  type S <: Source
  type E <: Event
  type L <: Listener
  
  trait Event {
    var source: S = _
  }
  
  trait Listener {
    def occurred(e:E):Unit
  }
  
  trait Source {
    this: S =>
      private val listeners = new ArrayBuffer[L]
      def add(l:L) {listeners += l}
      def remove(l:L) {listeners -= l}
      def fire(e:E) {
          e.source = this
          for (l <- listeners) l.occurred(e)
      }
  }
}
{% endhighlight %}

但是有这些也有代价：你不能拥有顶级的类型声明。这就是所有代码都被包在了ListenerSupport特质里的原因。接下来需要定义按钮事件和按钮监听器，你可以将定义包含在一个扩展该特质的模块当中：
{% highlight scala %}
object ButtonModule extends ListenerSupport {
  type S = Button
  type E = ButtonEvent
  type L = ButtonListener
  
  class ButtonEvent extends Event
  trait ButtonListener extends Listener
  class Button extends Source {
    def click() {fire(new ButtonEvent) }
  }
}

object Main {
  import ButtonModule._
  
  def main(args:Array[String]) {
    val b = new Button
    b.add(new ButtonListener {
        override def occurred(e : ButtonEvent) {println(e)}
    })
    b.click
  }
}
{% endhighlight %}

####高等类型
泛型类型List依赖于类型T并产出一个特定的类型。举例来说，给定类型Int，得到List[Int]。因此像List这样的泛型有时被称作`类型构造器`。看如下简化的Iterable特质：
{% highlight scala %}
trait Iterable[E] {
  def iterator():Iterator[E]
  def map[F](f:(E) => F):Iterable[F]
}
{% endhighlight %}

现在考虑一个实现该特质的类：
{% highlight scala %}
class Buffer[E] extends Iterable[E] {
  def iterator():Iterator[E] = ...
  def map[F](f:(E) => F):Buffer[F] = ...
{% endhighlight %}

对于Buffer，预期map方法返回一个Buffer，而不仅仅是Iterable。这就意味着我们不能在Iterable特质中实现这个map方法。一个解决办法是使用类型构造器来参数化Iterable:
{% highlight scala %}
trait Iterable[E, C[_]] {
  def iterator():Iterator[E]
  def build[F]():C[F]
  def map[F](f:(E) => F):C[F]
}
{% endhighlight %}

这样，Iterable就依赖一个类型构造器来生成结果，以C[_]表示。这使得Iterable称为一个`高等类型`。要实现Iterable中的map，我们需要更多的支持：
{% highlight scala %}
//Iterable需要能够产出一个包含了任何类型F的值的容器。定义一个Container类，你可以向它添加值
trait Container[E] {
  def +=(e:E):Unit
}

//build方法被要求产出这样一个对象：
trait Iterable[E, C[X] <: Container[X]] {
  def build[F]():C[F]
  ...
}
{% endhighlight %}

类型构造器C现在被限制为一个Container，因此我们知道可以往build方法返回的对象添加项目。有了这些以后，我们就可以在Iterable特质中实现map方法：
{% highlight scala %}
def map[F](f: (E) => F): C(F) = {
  val res = build[F]()
  val iter = iterator()
  while(iter.hasNext) res += f(iter.next())
  res
{% endhighlight %}

这样一来，可迭代类就不再需要提供它们自己的map实现，如下是Range类的定义：
{% highlight scala %}
class Range(val low:Int, val high:Int) extends Iterable[Int, Buffer] {
  def iterator() = new Iterator[Int] {
    private var i = low
    def hasNext = i <= high
    def next() = {i += 1; i - 1}
  }
  
  def build[F]() = new Buffer[F]
{% endhighlight %}

注意Range是一个Iterable:你可以遍历其内容。但它并不是一个Container:你不能对它添加值。而Buffer不同，它即是Iterable，也是Container:
{% highlight scala %}
class Buffer[E:Manifest] extends Iterable[E, Buffer] with Container[E] {
  private var capacity = 10
  private var length = 0
  private var elems = new Array[E](capacity)//为了构造泛型数组，这里E必须满足Manifest上下文界定
  
  def iterator() = new Iterator[E] {
    private var i = 0
    def hasNext = i < length
    def next() = {i += 1; i - 1}
  }
  
  def build[F:Manifest]() = new Buffer[F]
  
  def += (e:E) {
    if (length == capacity) {
      capacity = 2 * capacity
      val nelems = new Array[E](capacity)
      for (i <- 0 until length) nelems(i) = elems(i)
      elems = nelems
    }
    elems(length) = e
    length += 1
{% endhighlight %}