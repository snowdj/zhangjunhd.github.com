---
layout: post
title: "Scala笔记1-基本类型"
description: "Scala笔记1-基本类型，类型检查"
category: 编程
tags: [scala]
---
{% include JB/setup %}

####Scala基本类型

    Data Type     Definition
    Boolean       true or false
    Byte          8-bit signed two's complement integer (-2^7 to 2^7-1, inclusive)
    Short         16-bit signed two's complement integer (-2^15 to 2^15-1, inclusive)
    Int           32-bit two's complement integer (-2^31 to 2^31-1, inclusive)
    Long          64-bit two's complement integer (-2^63 to 2^63-1, inclusive)
    Float         32-bit IEEE 754 single-precision float
    Double        64-bit IEEE 754 double-precision float
    Char          16-bit unsigned Unicode character (0 to 2^16-1, inclusive)
    String        a sequence of Chars

####BigDecimal
{% highlight scala %}
import scala.math.BigDecimal.RoundingMode

object Main extends App {
  val salary:BigDecimal = 100000
  val weekly = salary / 52 //scala.math.BigDecimal = 1923.076923076923076923076923076923
  weekly.setScale(2, RoundingMode.HALF_EVEN) // scala.math.BigDecimal = 1923.08
}
{% endhighlight %}

####pow,prime,Random
{% highlight scala %}
3 - math.pow(math.sqrt(3), 2) // Double = 4.440892098500626E-16

import BigInt.probablePrime
import util.Random
/** Returns a positive BigInt that is probably prime, 
 *  with the specified bitLength.
 */
probablePrime(100, Random)
{% endhighlight %}

####A Scala current date/time example
{% highlight scala %}
import java.util.Calendar
import java.text.SimpleDateFormat

object Main extends App {
  val today = Calendar.getInstance().getTime() // java.util.Date = Sat Jan 04 21:08:02 CST 2014

  // create the date/time formatters
  val minuteFormat = new SimpleDateFormat("mm")
  val hourFormat = new SimpleDateFormat("hh")
  val amPmFormat = new SimpleDateFormat("a")

  val currentHour = hourFormat.format(today)      // String = 09
  val currentMinute = minuteFormat.format(today)  // String = 08
  val amOrPm = amPmFormat.format(today)           // String = PM
}
{% endhighlight %}
   
####类型检查与转换
    
    Scala                  Java
    obj.isInstanceOf[C]    obj instanceOf C
    obj.asInstanceOf[C]    ( C ) obj
    classOf[C]             C.class  