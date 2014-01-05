---
layout: post
title: "Scala笔记6-枚举"
description: "Scala笔记6-枚举"
category: 编程
tags: [scala]
---
{% include JB/setup %}

使用枚举

{% highlight scala %}
object TrafficLightColor extends Enumeration {
  val Red, Yellow, Green = Value
}
{% endhighlight %}

可以指定ID和name:

{% highlight scala %}
object TrafficLightColor extends Enumeration {
  val Red = Value(0, "Stop") // Red.toString() to get "Stop"
  val Yellow = Value(10) // Name "Yellow" 
  val Green = Value("Go") // ID 11
}
{% endhighlight %}

枚举的类型是TrafficLightColor.Value 而不是 TrafficLightColor 可以增加一个`类型别名`:

{% highlight scala %}
object TrafficLightColor extends Enumeration {
  type TrafficLightColor = Value
  val Red = Value(0, "Stop")
  val Yellow = Value(10)
  val Green = Value("Go")
}

object Run extends App {
  import TrafficLightColor._
  def doWhat(color: TrafficLightColor) = {
      if (color == Red) "stop"
      else if (color == Yellow) "hurry up" else "go"
  }
   
  // load Red
  TrafficLightColor(0) // Calls Enumeration.apply 
  TrafficLightColor.withName("Red")
}
{% endhighlight %}

