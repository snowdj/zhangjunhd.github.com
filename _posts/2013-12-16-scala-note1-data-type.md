---
layout: post
title: "Scala笔记1-基本类型data type"
description: "Scala笔记1-基本类型，类型检查"
category: 编程
tags: [scala]
---
{% include JB/setup %}

Scala基本类型

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
    
类型检查与转换(Scala代码对应Java代码)
    
    Scala                  Java
    obj.isInstanceOf[C]    obj instanceOf C
    obj.asInstanceOf[C]    ( C ) obj
    classOf[C]             C.class  