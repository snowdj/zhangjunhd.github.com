---
layout: post
title: "读书笔记-概率论基础教程"
description: "《概率论基础教程》Sheldon Ross "
category: 大数据
tags: [概率]
---
{% include JB/setup %}

读[《概率论基础教程》](http://book.douban.com/subject/4291764/)。

![zen](http://img5.douban.com/lpic/s4205606.jpg)

##第一章 组合分析

1. `计数基本法则`阐述了如下事实：如果一个试验可分成两个阶段，第一个阶段有n种可能结果，每种结果又对应第二个阶段的m种可能的结果，那么试验一共有nm种可能结果。
2. n个元素的`排列`(permutation)一共有`\(n!=n(n-1)\cdot \cdot \cdot 3\cdot 2\cdot 1\)`种可能排列方式，特别地，0！=1.
3. 令`\({n \choose i} =\frac {n!}{(n-i)!i!} \)`,其中`\(0\le i\le n\)`,否则等于0.此式表明了从n个元素中选取i个元素的可能选取方法数，`\({n \choose i} \)`称为从n个对象中选取i个对象的`组合`(combination)数，因其在二项式定理中的突出地位，它也常称为`二项式系数`(binomial coefficient)，我们有`\((x+y)^n = \sum_{i=0}^n {n \choose i} x^iy^{n-i}\)`
4. 对于任意和为n的非负整数`\(n_1,\cdot \cdot \cdot,n_r, {n \choose n_1,\cdot \cdot \cdot,n_r} = \frac {n!}{(n_1)!(n_2)\cdot \cdot \cdot(n_r)!}\)`,它等于n个元素分成互不重叠的r部分，其中各个部分的元素个数分别是`\(n_1,\cdot \cdot \cdot,n_r\)`的分法数。

##第二章 概率论公理化

1. 如果令S为表示某个试验的所有可能结果的集合，那么S称为该试验的`样本空间`。一个`事件`就是S的一个子集。如果`\(A_i，i = 1,\cdot \cdot \cdot,n\)`为一系列事件，那么称`\(\bigcup_{i=1}^{n}{A_i}\)`为这些事件的`并`，它表示至少包含在某一个`\(A_i\)`里的所有结果所构成的事件。类似地，`\(\bigcap_{i=1}^{n}{A_i}\)`称为这些事件的`交`，有时也记为`\(A_1 \cdot \cdot \cdot A_n\)`,表示包含在所有`\(A_i\)`里的所有结果所构成的事件。
2. 对任一事件A，定义`\(A^c\)`为由那些不包含在A里的所有结果所构成的事件，称为A的`对立事件`。事件`\(S^c\)`不包含任何结果，记为`\(\phi\)`,称为`空集`。如果`\(AB = \phi\)`，那么称A和B互不相容。
3. 设对于样本空间的任一事件A，对应于一个数P(A)，若集合函数P(A)满足以下条件，则称P(A)为A的`概率`:
      * `\(0 \le P(A) \le 1\)`
      * P(S) = 1
      * 对于任意互不相容事件`\(A_i, i \ge 1\)`,有`\(P(\bigcap_{i=1}^{n}{A_i}) = \sum_{i=0}^\infty{P(A_i)}\)`
4. P(A)表示试验结果包含在事件A里的概率，容易证明: `\(P(A^c) = 1 - P(A)\)`
5. 一个有用的结果：`\(P(A \cup B) = P(A) + P(B) - P(AB)\)`，可以推广为`\(P(\bigcup_{i=1}^{n}{A_i}) = \sum_{i=1}^n{P(A_i)} - \sum_{i-1}\sum{P(A_iA_j)} + \sum\sum_{i<j<k}\sum{P(A_iA_jA_k)} + \cdot \cdot \cdot + (-1)^{n+1}P(A_1 \cdot \cdot \cdot A_n)\)`
6. 如果S是有限集，其中每个结果发生的可能性是一样的，那么`\(P(A) = \frac{|A|}{|S|}\)`，其中|E|表示事件E所含的结果数。

##第三章 条件概率和独立性

1. 对于任意事件E和F，已知F发生的条件下，E发生的`条件概率`记为P(E|F)，定义如下`\(P(E|F) = \frac{P(EF)}{P(F)}\)`
2. 等式`\(P(E_1E_2 \cdot \cdot \cdot E_n) = P(E_1)P(E_2|E_1) \cdot \cdot \cdot P(E_n|E_1 \cdot \cdot \cdot E_n-1)\)`称为概率的`乘法规则`。
3. 一个有用的等式 `\(P(E) = P(E|F)P(F) + P(E|F^c)P(F^c)\)`可以来通过以F是否发生为条件计算P(E)。此公式为`全概率公式`。
4. `\(P(H)/P(H^c)\)`称为事件H的`优势`。等式`\(\frac{P(H|E)}{P(H^c|E)} = \frac{P(H)P(E|H)}{P(H^c)P(E|H^c)}\)`证明了当得到一个新的证据E后，H的优势等于原来的优势值乘以当H成立时新证据发生的概率与H不成立时新证据发生的概率的比值。
5. 令`\(F_i = 1, \cdot \cdot \cdot, n\)`为互不相容事件列，且它们的并为整个样本空间，等式`\(P(F_j|E) = \frac{P(E|F_j)P(F_j)}{\sum_{i=1}^n{P(E|F_i)P(F_i)}}\)`称为`贝叶斯公式`。如果事件`\(F_i = 1, \cdot \cdot \cdot, n\)`为一组假设，那么贝叶斯公式说明了如何计算当新证据成立时，这些假设成立的条件概率。
6. 如果P(EF) = P(E)P(F)，那么我们称事件E和F是`独立`的。该等式等价于P(E|F) = P(E)或P(F|E) = P(F)。也即，如果知道其中之一的发生并不影响另一个的发生的概率，那么E和F独立。

##第四章





`\(\)`










