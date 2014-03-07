---
layout: post
title: "读书笔记-Effective C++"
description: ""
category: 编程
tags: [C++]
---
{% include JB/setup %}

读[《Effective C++》](http://book.douban.com/subject/5387403/)。

![zen](http://img3.douban.com/lpic/s4647091.jpg)

##1 让自己习惯c++
###条款02：尽量以const, enum, inline替换 #define

2.1 如果要在头文件中定义一个常量指针，例如char*-based字符串，必须是类似于(写const两次)：
{% highlight cpp %}
const char * const authorName = "Scott Meyers";
{% endhighlight %}

2.2 定义class专属常量。通常C++要求你对你所使用的任何东西提供一个定义式，但如果它是一个class专属常量又是static且为整数类型(ints,chars,bools)，则需特殊处理。只要不取它们的地址，你可以声明并使用它们而无须提供定义式：
{% highlight cpp %}
class GamePlayer {
private:
  static const int NumTurns = 5;      // constant declaration
  int scores[NumTurns];               // use of constant
  ...
};
{% endhighlight %}

但如果你取某个class专属常量的地址，或纵使你不取其地址而你的编译器却(不正确地)坚持要看到一个定义式，你就必须另外提供定义式如下：
{% highlight cpp %}
const int GamePlayer::NumTurns;     // definition of NumTurns
{% endhighlight %}

请把这个式子放进一个实现文件而非头文件。

2.3 the enum hack
{% highlight cpp %}
class GamePlayer {
private:
  enum { NumTurns = 5 };        // "the enum hack" — makes NumTurns a symbolic name for 5
  int scores[NumTurns];         // fine
  ...
};
{% endhighlight %}

###条款03：尽可能使用const
3.1 关于const 指针的说明：
{% highlight cpp %}
char greeting[] = "Hello";
char *p = greeting;              // non-const pointer, non-const data
const char *p = greeting;        // non-const pointer, const data
char * const p = greeting;       // const pointer,non-const data
const char * const p = greeting; // const pointer, const data
{% endhighlight %}

声明const迭代器也是一样的：
{% highlight cpp %}
std::vector<int> vec;
...

const std::vector<int>::iterator iter = vec.begin(); // iter acts like a T* const
*iter = 10;                        // OK, changes what iter points to
++iter;                            // error! iter is const

std::vector<int>::const_iterator cIter = vec.begin();//cIter acts like a const T*
*cIter = 10;                      // error! *cIter is const
++cIter;                          // fine, changes cIter
{% endhighlight %}

3.2 const 成员函数

将const实施于成员函数的目的：第一，它们使class接口比较容易被理解。这是因为，得知哪个函数可以被改动对象内容而哪个函数不行；第二，它们使得“操作const对象”成为可能。这对编写高效代码是个关键，因为如条款20所言，改善C++程序效率的一个根本办法是以pass by reference-to-const方式传递对象，而此技术可行的前提是，我们有const成员函数可用来处理取得的const对象。

3.3 在const和non-const成员函数中避免重复

假设TextBlock内的operator[]不单只是返回一个reference指向某字符，也执行边界检验、志记访问信息、甚至可能进行数据完善性检验。把所有这些同时放进const和non-const operator[]：
{% highlight cpp %}
class TextBlock {
public:
  ...

  const char& operator[](std::size_t position) const
  {
    ...                                 // do bounds checking
    ...                                 // log access data
    ...                                 // verify data integrity
    return text[position];
  }

  char& operator[](std::size_t position)
  {
    ...                                 // do bounds checking
    ...                                 // log access data
    ...                                 // verify data integrity
    return text[position];
  }

private:
   std::string text;
};
{% endhighlight %}

造成代码重复。当然，可以将边界检验等代码移到另一个成员函数(往往是个private)并令两个版本的operator[]调用它。但还是重复了一些代码，例如函数调用、两次return语句等。

真正应该做的是实现operator[]的机能一次并使用它两次：
{% highlight cpp %}
class TextBlock {
public:
  ...
  const char& operator[](std::size_t position) const     // same as before
  {
    ...
    ...
    ...
    return text[position];
  }

  char& operator[](std::size_t position)         // now just calls const op[]
  {
    return
      const_cast<char&>(                         // cast away const on op[]'s return type;
        static_cast<const TextBlock&>(*this)[position]     // add const to *this's type;// call const version of op[]
      );
  }
...
};
{% endhighlight %}

这里共有两次转型：第一次用来为*this添加const(这使接下来调用operator[]时得以调用const版本)，第二次则是从const operator[]的返回值中移除const。

更值得了解的是，反向做法——令const版本调用non-const版本以避免重复——并不是你该做的事。记住，const成员函数承诺绝不改变其对象的逻辑状态，non-const成员函数却没有这般承诺。如果在const函数内调用non-const函数，就是冒了这样的风险：你曾经承诺不改动的那个对象被改动了。

###条款04：确定对象被使用前已先被初始化






{% highlight cpp %}

{% endhighlight %}


















