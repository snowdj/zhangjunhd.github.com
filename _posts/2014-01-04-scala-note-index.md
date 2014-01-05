---
layout: post
title: "scala笔记索引"
description: "scala笔记索引"
category: 编程
tags: [scala]
---
{% include JB/setup %}

* [Scala笔记1-基本类型](http://zhangjunhd.github.io/2013/12/16/scala-note1-data-type.html)
  * Scala基本类型
  * Scala BigDecimal
  * 乘方，素数，随机数
  * Scala date/time
  * 类型检查与转换(`isInstanceOf`, `asInstanceOf`, `classOf`)
* [Scala笔记2-控制结构与函数](http://zhangjunhd.github.io/2013/12/17/scala-note2-condition-and-function.html)
  * `for`
  * `yeild`
  * 加入guard
  * 变长参数
  * 递归
* [Scala笔记3-数组](http://zhangjunhd.github.io/2013/12/18/scala-note3-array.html)
  * `Array`
  * `ArrayBuffer`
  * `数组遍历`
  * 常用算法(`sum`,`min`,`max`,`count`,`sort`,`mkString`)
  * 多维数组
  * 与Java互操作(`JavaConversions.bufferAsJavaList`)
* [Scala笔记4-映射与元组](http://zhangjunhd.github.io/2013/12/19/scala-note4-map-and-tuple.html)
  * map声明，赋值，追加，减少
  * map迭代
  * 加入guard
  * 使用map实现wordcount
  * 使用hashmap统计词频
  * 与Java互操作`JavaConversions.mapAsScalaMap`
  * 元组`zip`,`partition`
* [Scala笔记5-类](http://zhangjunhd.github.io/2013/12/20/scala-note5-class.html)
  * getter/setter
  * 对象私有字段`private[this]`
  * `BeanProperty`
  * 主构造和辅助构造器
  * 伴生对象(companion object)
  * 嵌套类(类型投影(type projection),外部类的this引用)
  * apply
  * 重写字段
  * 结构类型
  * 懒值lazy
  * 构造顺序与提前定义
  * 对象相等性(equals)
* [Scala笔记6-枚举](http://zhangjunhd.github.io/2013/12/21/scala-note6-enumeration.html)
  * `Enumeration`
  * 类型别名
* [Scala笔记7-文件操作](http://zhangjunhd.github.io/2013/12/22/scala-note7-file.html)
  * 读写文件
  * 缓存读
  * 遍历目录
  * 序列化
* [Scala笔记8-进程控制](http://zhangjunhd.github.io/2013/12/23/scala-note8-process.html)
  * `ProcessBuilder`
* [Scala笔记9-正则表达式与文法解析](http://zhangjunhd.github.io/2013/12/24/scala-note9-regex.html)
  * 正则表达式(`Regex`)
  * 正则表达式组
  组合解析器操作(`RegexParsers`)
* [Scala笔记10-特质](http://zhangjunhd.github.io/2013/12/25/scala-note10-trait.html)
  * 自身类型(`this: type`)
  * 结构类型(structural type)
* [Scala笔记11-apply函数](http://zhangjunhd.github.io/2013/12/26/scala-note11-apply.html)
  * `apply`
  * `unapply`
  * `update`
  * `unapplySeq`
* [Scala笔记12-高阶函数](http://zhangjunhd.github.io/2013/12/27/scala-note12-high-order-function.html)
  * 闭包
  * SAM(single abstract method)
  * 柯里化(Currying)
  * 控制抽象
* [scala笔记13-集合](http://zhangjunhd.github.io/2013/12/31/scala-note13-collections.html)
  * 将函数映射到集合(`map`,`flatMap`, `collect`)
  化简折叠和扫描(`reduceLeft`,`reduceRight`, `foldLeft`, `foldRight`, `scanLeft`, `scanRight`)
  * 拉链操作(`zip`, `zipWithIndex`)
  * 迭代器
  * 流
  * 懒视图(`view`)
  * 与Java集合的互操作
  * 线程安全的集合
  * 并行集合
* [scala笔记14-模式匹配与样例类](http://zhangjunhd.github.io/2013/12/31/scala-note14-pattern-match.html)
  * 类型模式(match)
  * 提取器
  * 样例类(`copy`)
  * Option
  * 偏函数
* [scala笔记15-注解](http://zhangjunhd.github.io/2013/12/31/scala-note15-annotations.html)
* [scala笔记16-xml](http://zhangjunhd.github.io/2014/01/01/scala-note16-xml.html)
* [scala笔记17-类型参数与隐式转换](http://zhangjunhd.github.io/2014/01/01/scala-note17-type-parameters.html)
  * 类型变量界定
  * 视图界定
  * 上下文界定
  * 多重界定
  * 约束类型
  * 协变
  * 对象不能泛型
  * 类型通配符
  * 隐式转换
  * 隐式参数
* [scala笔记18-高级类型](http://zhangjunhd.github.io/2014/01/02/scala-note18-advanced-types.html)
  * 单例类型(`this.type`)
  * 结构类型
  * 存在类型
  * 蛋糕模式
  * 抽象类型(abstract type)
  * 家族多态
  * 高等类型
