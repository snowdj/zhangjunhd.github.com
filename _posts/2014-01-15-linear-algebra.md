---
layout: post
title: "读书笔记-线性代数极其应用"
description: "读书笔记-线性代数极其应用"
category: 数学
tags: [线性代数,差分方程,马尔可夫链]
---
{% include JB/setup %}

读[《线性代数极其应用》](http://book.douban.com/subject/1425950/)。

![zen](http://img3.douban.com/lpic/s5680140.jpg)

##第一章 线性代数中的线性方程组
###1.1 线性方程组

**定义(线性方程组)** `线性方程组`是由一个或几个包含相同变量`\(x_1,x_2,\cdot \cdot \cdot,x_n\)`的线性方程组成的。例如`\(\begin{cases} 
x_1-2x_2+x_3=0 \\
2x_2-8x_3=8 \\
-4x_1+5x_2+9x_3=-9\\
\end{cases}\)`我们称一个线性方程组是`相容`的，若它有一个或无穷多个解；称它是`不相容`的，若它无解。矩阵`\(\begin{pmatrix}
1 & -2 & 1 \\
0 & 2 & -8 \\
-4 & 5 & 9 \\
\end{pmatrix}\)`称为方程组的`系数矩阵`，而`\(\begin{pmatrix}
1 & -2 & 1 & 0 \\
0 & 2 & -8 & 8 \\
-4 & 5 & 9 & -9 \\
\end{pmatrix}\)`称为它的`增广矩阵`。

**定义(行初等变换)**`行初等变换`：

1. (倍加变换)把某一行换成它本身与另一行的倍数的和。
2. (对换变换)把两行对换。
3. (倍乘变换)把某一行的所有元素乘以同一个非零数。

我们称两个矩阵为`行等价`的，若其中一个矩阵可以经一系列行初等变换成为另一个矩阵。若两个线性方程组的增广矩阵是行等价的，则它们具有相同的解集。

###1.2 行化简与阶梯形矩阵
**定义(阶梯形)** 一个矩阵称为`阶梯形`(或行阶梯形)，若它有以下三个性质：

1. 每一非零行在每一零行之上；(矩阵中`非零行`或列指矩阵中至少包含一个非零元素的行或列)
2. 某一行的先导元素所在的列位于前一行先导元素的右面；(非零行的`先导元素`是指该行中最左边的非零元素)
3. 某一先导元素所在列下方元素都是零。

若一个阶梯形矩阵还满足以下两个性质，称它为`简化阶梯形`(或简化行阶梯形):

1. 每一非零行的先导元素是1；
2. 每一先导元素1是该元素所在列的唯一非零元素。

阶梯形矩阵：

![1](/assets/2014-01-15-linear-algebra/1.png)

简化阶梯形矩阵：

![2](/assets/2014-01-15-linear-algebra/2.png)
   
**定理1(简化阶梯形矩阵的唯一性)** 每个矩阵行等价于唯一的简化阶梯形矩阵。

**定义(主元位置与主元列)** 矩阵中的`主元位置`是A中对应于它的阶梯形中先导元素的位置。`主元列`是A的含有主元位置的列。(上图中黑正方形就是先导元素，也即主元位置。)

**定义(线性方程组的解)** 设某一个线性方程组的增广矩阵已经化为等价的简化阶梯形：`\(\begin{bmatrix}
1 & 0 & -5 & 1 \\
0 & 1 & 1 & 4 \\
0 & 0 & 0 & 0 \\
\end{bmatrix}\)`,对应的线性方程组是：`\(\begin{cases} 
x_1-5x_3=1 \\
x_2+x_3=4 \\
0=0\\
\end{cases}\)`,对应于主元列的变量x1和x2称为`基本变量`。其他变量如x3称为`自由变量`。当一个线性方程组是`相容`的，只要把方程的简化形式解出来，用自由变量表示基本变量即可：`\(\begin{cases} 
x_1=1+5x_3 \\
x_2=4-x_3 \\
x_3\ is\ free \\
\end{cases}\)`,上式给出的解称为方程组的`通解`。

**定理2(存在与惟一性定理)** 线性方程组相容的充要条件是增广矩阵的最右列不是主元列。就是说，增广矩阵的阶梯形没有形如 [0…0 b] b ≠0的行，若线性方程组相容，它的解集可能有两种情形：(i)当没有自由变量时，有惟一解；(ii)若至少有一个自由变量，有无穷多解。

###1.3 向量方程

**定义(向量加法的平行四边形法则)** 若ℝ²中向量u和v用平面上的点表示，则u+v对应于以u，0和v为三个顶点的平行四边形的第四个顶点。

![3](/assets/2014-01-15-linear-algebra/3.png)

ℝ³中的向量 a=(2,3,4)和2a

![4](/assets/2014-01-15-linear-algebra/4.png)

**定义(线性组合)** 给定ℝⁿ中的向量`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`和标量`\(c_1,c_2,\cdot \cdot \cdot,c_n\)`，向量`\(y=c_1v_1+\cdot \cdot \cdot+c_nv_n\)`,
称为向量`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`以`\(c_1,c_2,\cdot \cdot \cdot,c_n\)`为权的`线性组合`。

**定义(向量方程与增广矩阵的关系)** 向量方程`\(x_1a_1+x_2a_2+\cdot \cdot \cdot+x_na_n=b\)`和增广矩阵为`\([a_1\ a_2\ \cdot \cdot \cdot\ a_n\ b]\)`的线性方程组有相同的解集。特别地，b可表示为`\(a_1,a_2,\cdot \cdot \cdot,a_n\)`的线性组合，当且仅当对应于前面增广矩阵的方程组有解。

**定义(ℝⁿ的子集)** 若`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`是ℝⁿ中的向量，则`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`的所有线性组合所成的集合用记号Span{`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`}表示，称为由`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`所生成的ℝⁿ的`子集`，也就是说，Span{`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`}是所有形如`\(c_1v_1+\cdot \cdot \cdot+c_pv_p\)`
的向量的集合，其中`\(c_1,c_2,\cdot \cdot \cdot,c_p\)`为标量。

要判断向量b是否属于Span{`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`}，就是判断向量方程`\(x_1a_1+x_2a_2+\cdot \cdot \cdot+x_na_n=b\)`
是否有解，或等价地，判断增广矩阵为`\([a_1\ a_2\ \cdot \cdot \cdot\ a_n\ b]\)`的线性方程组是否有解。

注意Span{`\(v_1,v_2,\cdot \cdot \cdot,v_n\)`}包含`\(v_1\)`的所有倍数，因`\(c_1v_1=c_1v_1+0v_2+\cdot \cdot \cdot+0v_p\)`，特别地，它一定包含零向量(下左图)。若u和v是ℝ3中的非零向量，v不是u的倍数，则span{u,v}是ℝ3中通过u，v和0的平面，特别地，Span{u,v}包含ℝ3中通过u与0的直线，也包含通过v与0的直线(下右图)。

Span{v}与Span{u,v}的几何解释：

![5](/assets/2014-01-15-linear-algebra/5.png)

###1.4 矩阵方程Ax=b

**定义(矩阵与向量的积)** 若A是m x n矩阵，它的各列为`\(a_1,a_2,...,a_n\)`。若x是向量ℝⁿ中的向量，则A与x的积，记为Ax，就是A的各列以x中对应元素为权的线性组合，即`\(Ax = [a_1\ a_2\ \cdot \cdot \cdot\ a_n] \begin{bmatrix}
x_1 \\
\vdots \\
x_n
\end{bmatrix} = x_1a_1+x_2a_2+\cdot \cdot \cdot+x_na_n\)`

**定理3(矩阵方程,向量方程与增广矩阵)** 若A是m x n矩阵，它的各列为`\(a_1,a_2,\cdot \cdot \cdot,a_n\)`，而b属于ℝⁿ，则矩阵方程 Ax = b,与向量方程 `\(x_1a_1+x_2a_2+\cdot \cdot \cdot+x_na_n=b\)`有相同的解集，它又与增广矩阵为`\([a_1\ a_2\ \cdot \cdot \cdot\ a_n\ b]\)`的线性方程组有相同的解集。

**定理4(矩阵方程与线性组合)** 设A是m x n矩阵，则下列命题是逻辑上等价的，也就是说，对某个A，它们都成立或者都不成立。

1. 对ℝⁿ中的每个b，方程Ax=b有解。
2. ℝⁿ中的每个b都是A的列的一个线性组合。
3. A的各列生成ℝⁿ。
4. A在每一行都有一个主元位置。

**警告** 定理4讨论的是系数矩阵，而非增广矩阵，若增广矩阵[A b]在每一行都有主元位置，方程Ax=b可能相容，也可能不相容(定理2)(J:若主元位置不在b，则有唯一解；若主元位置在b，则无解)。

**定理5(矩阵-向量积Ax的性质)** 若A是m x n矩阵，u和v是ℝⁿ中的向量，c是标量，则

1. A(u+v)=Au+Av
2. A(cu)=c(Au)

###1.5 线性方程组的解集

**定义(齐次线性方程组)** 线性方程称为`齐次`的，若它可写成Ax=0，其中A是m x n矩阵而0是ℝᵐ中的零向量。这样的方程组至少有一个解，即x=0(ℝⁿ中的零向量)，这个解称为它的`平凡解`。对给定方程Ax=0，重要的是它是否有`非平凡解`，即满足Ax=0的非零向量x。由定理2知，齐次方程Ax=0有非平凡解，当且仅当方程至少有一个自由变量。

**定理6(非齐次线性方程组的解)** 设方程Ax=b对某个b是相容的，p为一个特解，则Ax=b的解集是所有w=p+`\(v_h\)`的向量的集，其中`\(v_h\)`是齐次方程Ax=0的任意一个解。

定理6说明若Ax=b有解，则解集可由Ax=0的解平移向量p得到，p是Ax=b的任意一个特解，下图说明当有两个自由变量时得情形，即使当n>3时，相容方程组Ax=b(b≠0)的解集也可想象为一个非零点或一条不通过原点的线或平面。

![6](/assets/2014-01-15-linear-algebra/6.png)

**警告** 定理6与上图仅适用于Ax=b至少有一个非零解p的前提下。

###1.7 线性无关
**定义(向量组的线性无关)** ℝⁿ中一组向量`\(\{v_1,v_2,\cdot \cdot \cdot,v_p\}\)`称为`线性无关`的，若向量方程`\(x_1v_1+x_2v_2+…+x_pv_p=0\)`仅有平凡解。向量组`\({v_1,v_2,\cdot \cdot \cdot,v_p}\)`称为`线性相关`的，若存在不全为零的权`\(c_1,c_2,\cdot \cdot \cdot,c_p\)`，使`\(c_1v_1+\cdot \cdot \cdot+c_nv_n=0 \)`

**定义(矩阵各列的线性无关)** 矩阵A的各列线性无关，当且仅当Ax=0仅有平凡解。

**定义(两个向量集合的线性无关)** 两个向量的集合{`\(v_1,v_2\)`}线性相关，当且仅当其中一个向量是另一个向量的倍数。这个集合线性无关，当且仅当其中任一个向量都不是另一个向量的倍数(参考下图)。

![7](/assets/2014-01-15-linear-algebra/7.png)

**定理7(线性相关集的特征)** 两个或更多个向量的集合S={`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}线性相关，当且仅当S中至少有一个向量是其他向量的线性组合，事实上，若S线性相关，且`\(v_1\)`≠0，则某个`\(v_j\)`(j>1)是它前面几个向量`\(v_1,v_2,\cdot \cdot \cdot,v_{j-1}\)`的线性组合。

**警告** 定理7没有说在线性相关集中每一个向量都是它前面的向量的线性组合，线性相关中某个向量可能不是其他向量的线性组合。

例4 设u=`\(\begin{bmatrix}
3 \\
1 \\
0
\end{bmatrix}\)`，v=`\(\begin{bmatrix}
1 \\
6 \\
0
\end{bmatrix}\)`，叙述u和v生成的集合，并说明向量w属于span{u,v}当且仅当{u,v,w}线性相关。

解 向量u和v是线性无关的，因为它们之中任何一个不是另一个的倍数，所以它们生成ℝ3中一个平面，事实上，Span{u,v}就是x1x2平面(即x3=0)，若w是u和v的线性组合，由定理7知{u,v,w}线性相关，反之，设{u,v,w}线性相关，由定理7知{u,v,w}中某一向量是它前面的向量的线性组合(因u≠0)，这向量必是w，因为v不是u的倍数。因而w属于Span{u,v}，见下图说明：

![7-1](/assets/2014-01-15-linear-algebra/7-1.png)

**定理8(向量个数与向量组线性相关性)** 若一个向量组的向量个数超过每个向量元素的个数，那么这个向量组线性相关，就是说，ℝⁿ中任意向量组{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}，当p>n时线性相关。(证：设A=[`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`]，则A是n x p矩阵，方程对应于p个未知量的n个方程，若p>n，则未知量比方程多，所以必定有自由变量。因此Ax=0必有非平凡解，所以A的各列线性相关。)

**定理9(零向量与向量组线性相关性)** 若向量组S={`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}包含零向量，则它线性相关。(证：把这些向量重新编号，不妨设`\(v_1 = 0\)`，于是方程`\(1 \cdot v_1,0 \cdot v_2,\cdot \cdot \cdot,0 \cdot v_p = 0\)`证明了S线性相关。)

###1.8 线性变换介绍
**定义(向量集变换)** 由ℝⁿ到ℝᵐ的一个变换(或称函数、映射)T是一个规则，它把ℝⁿ中每个向量x对应以ℝᵐ中的一个向量T(x)。集ℝⁿ称为T的`定义域`，集ℝᵐ称为T的`余定义域`(或`取值空间`)。符号T:ℝⁿ⟶ℝᵐ说明T的定义域是ℝⁿ而余定义域是ℝᵐ，对于ℝⁿ中的向量x，ℝᵐ中向量T(x)称为x(在T作用下)的`像`，所有像T(x)的集合称为T的`值域`。

![8](/assets/2014-01-15-linear-algebra/8.png)

**定义(矩阵变换)** 对ℝⁿ中每个x，T(x)由Ax计算得到，其中A是m x n矩阵，为简单起见，有时将这样的矩阵变换记为x⟶Ax，注意当A有n列时，T的定义域为ℝⁿ，而当A的每个列有m个元素时，T的余定义域为ℝᵐ。T的值域为A的列的所有线性组合的集合，因为每个像T(x)有Ax的形式。

**例2** 若A=`\(\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 0
\end{bmatrix}\)`，则变换x⟼Ax把ℝ³中的点投影到`\(x_1x_2\)`坐标平面上(`投影变换`)，因为`\(\begin{bmatrix}
x_1 \\
x_2 \\
x_3
\end{bmatrix} \longmapsto \begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 0
\end{bmatrix} \begin{bmatrix}
x_1 \\
x_2 \\
x_3
\end{bmatrix} = \begin{bmatrix}
x_1 \\
x_2 \\
0
\end{bmatrix}\)`

![9](/assets/2014-01-15-linear-algebra/9.png)

**例3** 设A=`\(\begin{bmatrix}
1 & 3 \\
0 & 1
\end{bmatrix}\)`，变换T：ℝ²⟶ℝ²定义为T(x)=Ax称为`剪切变换`。可以说明，若T作用于下图的2x2正方形各点，则像的集构成带阴影的平行四边形。关键的想法是证明T将线段映射成为线段，然后验证正方形的4个顶点映射成平行四边形的4个顶点。例如，点u=`\(\begin{bmatrix}
0 \\
2
\end{bmatrix}\)`的像为T(u)=`\(\begin{bmatrix}
1 & 3 \\
0 & 1
\end{bmatrix}\begin{bmatrix}
0 \\
2
\end{bmatrix} = \begin{bmatrix}
6 \\
2
\end{bmatrix}\)`,`\(\begin{bmatrix}
2 \\
2
\end{bmatrix}\)`的像为`\(\begin{bmatrix}
1 & 3 \\
0 & 1
\end{bmatrix}\begin{bmatrix}
2 \\
2
\end{bmatrix} = \begin{bmatrix}
8 \\
2
\end{bmatrix}\)`。T将正方形变形，正方形的底保持不变，而正方形的顶点拉向右边，剪切变换出现在物理学、地质学与晶体学中。

![10](/assets/2014-01-15-linear-algebra/10.png)

**定义(线性变换)** 变换(或映射)T称为线性的，若

1. 对T的定义域中的一切u，v，T(u+v)=T(u)+T(v) (1)
2. 对一切u和标量c，T(cu)=cT(u) (2)

每个矩阵变换都是线性变换。

若T是线性变换，则 T(0)=0 (3)

且对T的定义域中的一切向量u和v以及数c和d有：T(cu+dv)=cT(u)+dT(v) (4)

(3)由(2)得出，T(0)=T(0u)=0T(u)=0。(4)由(1)(2)得出，T(cu+dv)=T(cu)+T(dv)=cT(u)+dT(v),由(5)得出有用的推广：`\(T(c_1v_1+\cdot \cdot \cdot+c_pv_p) = c_1T(v_1)+\cdot \cdot \cdot+c_pT(v_p)\)`(5) 在工程和物理中，(5)式称为`叠加原理`。

**例4** 给定标量r，定义T:ℝ²⟶ℝ²为T(x)=rx.当0≤r≤1时，T称为`压缩变换`，当r>1时，T称为`拉伸变换`。设r=3，证明T是线性变换。

**解** 设u，v属于ℝ²，c，d为数，则T(cu + dv) = 3(cu + dv) = 3cu + 3dv = c(3u) + d(3v) = cT(u) + dT(v) , 因满足(4)，于是T是线性变换。

![11](/assets/2014-01-15-linear-algebra/11.png)

**例5** 定义线性变换T:ℝ²⟶ℝ²为T(x)=`\(\begin{bmatrix}
0 & -1 \\
1 & 0
\end{bmatrix}\begin{bmatrix}
x_1 \\
x_2
\end{bmatrix} = \begin{bmatrix}
-x_2 \\
x_1
\end{bmatrix}\)`,求出u=`\(\begin{bmatrix}
4 \\
1
\end{bmatrix}\)`,v=`\(\begin{bmatrix}
2 \\
3
\end{bmatrix}\)`,u+v=`\(\begin{bmatrix}
6 \\
4
\end{bmatrix}\)`在T下的像。

**解** T(u)=`\(\begin{bmatrix}
0 & -1 \\
1 & 0
\end{bmatrix}\begin{bmatrix}
4 \\
1
\end{bmatrix} = \begin{bmatrix}
-1 \\
4
\end{bmatrix}\)`,T(v)=`\(\begin{bmatrix}
0 & -1 \\
1 & 0
\end{bmatrix}\begin{bmatrix}
2 \\
3
\end{bmatrix} = \begin{bmatrix}
-3 \\
2
\end{bmatrix}\)`,T(u+v)=`\(\begin{bmatrix}
0 & -1 \\
1 & 0
\end{bmatrix}\begin{bmatrix}
6 \\
4
\end{bmatrix} = \begin{bmatrix}
-4 \\
6
\end{bmatrix}\)`,由下图可知，T把u，v和u+v逆时针旋转90∘，事实上，T把由u和v确定的平行四边形变换成由T(u)，T(v)确定的平行四边形：

![12](/assets/2014-01-15-linear-algebra/12.png)

###1.9 线性变换的矩阵
下面的讨论指出，从ℝⁿ到ℝᵐ的每一个线性变换，实际上都是一个矩阵变换x⟼Ax，而且变换T的性质都归结为A的性质。寻找矩阵A的关键，是了解T完全由它对单位矩阵In的各列的作用所决定。

**定理10(线性变换的矩阵)** 设T:ℝⁿ⟶ℝᵐ为线性变换，则存在惟一的矩阵A，使T(x)=Ax，对ℝⁿ中一切x,事实上,A是 m x n矩阵,它的第j列是向量T(`\(e_j\)`)，其中`\(e_j\)`是单位矩阵In的第j列：`\(A=[T(e_1)\cdot \cdot \cdot T(e_n)]\)`。此式中矩阵A称为`线性变换T`的`标准矩阵`。现在我们知道由ℝⁿ到ℝᵐ的每个线性变换都是矩阵变换，反之亦然。术语线性变换强调映射的性质，而矩阵变换描述这样的映射如何实现。

**定义(存在性问题)** 映射T:ℝⁿ⟶ℝᵐ称为到ℝᵐ上的`映射`，若ℝᵐ中任一b都至少有一个ℝⁿ中的x与之对应(也称为满射)。

![13](/assets/2014-01-15-linear-algebra/13.png)

**定义(惟一性问题)** 映射T:ℝⁿ⟶ℝᵐ称为`1对1映射`，若ℝᵐ中每个b是ℝⁿ中至多一个x的像(也称为单射)。

![14](/assets/2014-01-15-linear-algebra/14.png)

**定理11(线性变换与矩阵方程的关系)** 设T:ℝⁿ⟶ℝᵐ为线性变换，则T是一对一当且仅当Ax=0仅有平凡解。(证：因T是线性的，T(0)=0，若T是一对一的，方程T(x)=0至多有一个解，因此仅有零解。若T不是一对一的，则ℝᵐ中某个b是至少ℝⁿ中两个相异向量，不妨设为u和v的像，即T(u)=T(v)=b。于是因为T是线性的。T(u-v)=T(u)-T(v)=b-b=0，向量u-v不是零，因它们是两个相异向量。因此方程T(x)=0有多于一个解。因而定理中两个条件同时成立或同时不成立。)

**定理12(线性变换与标准矩阵的关系)** 设T:ℝⁿ⟶ℝᵐ为线性变换，设A为T的标准矩阵，则

1. T把ℝⁿ映射到ℝᵐ上，当且仅当A的列生成ℝᵐ。(证：由1.4节定理4，A的列生成ℝᵐ当且仅当方程Ax=b对每个b都相容(定理4.1)，换句话说，当且仅当对每个b，方程T(x) = b至少有一个解，这就是说，T将ℝⁿ映射到ℝᵐ上)
2. T是一对一的，当且仅当A的列线性无关。(证：方程T(x) = 0和 Ax = 0仅是记法不同。所以由定理11，T是一对一的当且仅当Ax=0仅有平凡解。在1.7节中已说明这等价于A的各列线性无关)

****

##第2章 矩阵代数
###2.1 矩阵运算

**定理1(和与标量乘法)** 设A,B,C是相同维数的矩阵，r与s为数，则有

1. A+B=B+A
2. (A+B)+C=A+(B+C)
3. A+0=A
4. r(A+B)=rA+rB
5. (r+s)A=rA+sA
6. r(sA)=(rs)A

**定理2(矩阵乘法)** 设A为m x n矩阵，B、C的维数使下列各式的乘积有定义

1. A(BC)=(AB)C
2. A(B+C)=AB+AC
3. (B+C)A=BA+CA
4. r(AB)=(rA)B=A(rB)
5. ImA=A=AIn

警告

1. 一般AB≠BA，若AB=BA，称A和B彼此`可交换`。
2. 消去律对矩阵乘法不成立，即若AB=AC，一般情况下，B=C并不成立。
3. 若乘积AB是零矩阵，一般情况下，不能断定A=0或B=0。

**定理3(矩阵的转置)** 设A与B表示矩阵，其维数使下列和与积有定义，则

1. `\((A^T)^T\)`=A
2. `\((A+B)^T=A^T+B^T\)`
3. 对任意数r，`\((rA)^T=rA^T\)`
4. `\((AB)^T=B^TA^T\)`

转置就是第i行转成第i列：A=`\(\begin{bmatrix}
a & b \\
c & d
\end{bmatrix}\)`,B=`\(\begin{bmatrix}
-5 & 2 \\
1 & -3 \\
0 & 4
\end{bmatrix}\)`,C=`\(\begin{bmatrix}
1 & 1 & 1 & 1 \\
-3 & 5 & -2 & 7
\end{bmatrix}\)`,则`\(A^T\)`=`\(\begin{bmatrix}
a & c \\
b & d
\end{bmatrix}\)`,`\(B^T\)`=`\(\begin{bmatrix}
-5 & 1 & 0 \\
2 & -3 & 4
\end{bmatrix}\)`,`\(C^T\)`=`\(\begin{bmatrix}
1 & -3 \\
1 & 5 \\
1 & -2 \\
1 & 7
\end{bmatrix}\)`

###2.2 矩阵的逆
**定义(可逆矩阵)** 一个n x n矩阵是`可逆的`，若存在一个n x n矩阵C使 AC=I 且 CA = I,这里I=In是n x n单位矩阵，这时称C是A的`逆阵`。实际上，C是由A惟一确定，因为若B是A另外一个逆阵，那么将有B=BI=B(AC)=(BA)C=IC=C。于是，若A可逆，它的逆是惟一的，记为`\(A^{-1}\)`，于是`\(AA^{-1}\)`=I 且`\(A^{-1}A\)`=I。不可逆矩阵有时称为`奇异`矩阵，而可逆矩阵也称为`非奇异`矩阵。

**定理4(2x2矩阵的可逆性)** 设A=`\(\begin{bmatrix}
a & b \\
c & d
\end{bmatrix}\)`，若ad-bc≠0，则A可逆且`\(A^{-1}\)` = `\(\frac{1}{ad-bc}\begin{bmatrix}
d & -b \\
-c & a
\end{bmatrix}\)`。若ad-bc=0，则A不可逆。

**定理5(矩阵方程的解)** 若A是可逆n x n矩阵，则对每一ℝⁿ中的b，方程Ax=b有惟一解x=`\(A^{-1}b\)`。

**定理6(可逆矩阵的性质)** 

1. 若A是可逆矩阵，则`\(A^{-1}\)`也可逆且`\({A^{-1}}^{-1}\)`=A
2. 若A和B都是n x n可逆矩阵，AB也可逆，则`\({AB}^{-1}\)`=`\(B^{-1}A^{-1}\)`
3. 若A可逆，则`\(A^T\)`也可逆，且`\({A^T}^{-1}\)`=`\({A^{-1}}^T\)`

**定义(初等矩阵)** 把单位矩阵进行一次行变换，就得到`初等矩阵`：`\(E_1\)` = `\(\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
-4 & 0 & 1
\end{bmatrix}\)`,`\(E_2\)` = `\(\begin{bmatrix}
0 & 1 & 0 \\
1 & 0 & 0 \\
0 & 0 & 1
\end{bmatrix}\)`,`\(E_3\)` = `\(\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 5
\end{bmatrix}\)`,A = `\(\begin{bmatrix}
a & b & c \\
d & e & f \\
g & h & i
\end{bmatrix}\)`,则`\(E_1A\)` = `\(\begin{bmatrix}
a & b & c \\
d & e & f \\
g-4a & h-4b & i-4c
\end{bmatrix}\)`,`\(E_2A\)` = `\(\begin{bmatrix}
d & e & f \\
a & b & c \\
g & h & i
\end{bmatrix}\)`,`\(E_3A\)` = `\(\begin{bmatrix}
a & b & c \\
d & e & f \\
5g & 5h & 5i
\end{bmatrix}\)`

若对m x n矩阵A进行某种行初等变换，所得矩阵可写成EA，其中E是m x m矩阵，是由`\(I_m\)`进行同一行变换所得。每个初等矩阵E是可逆的，E的逆是一个同类型的初等矩阵，它把E变回I，即EF=I

**定理7(矩阵可逆的判断)** n x n矩阵A是可逆的，当且仅当A行等价于I。这时，把A变为I的一系列初等行变换同时把`\(I_n\)`变成`\(A^{-1}\)`。

**求`\(A^{-1}\)`的算法** 把增广矩阵[A I]进行化简，若A行等价于I，则[A I]行等价于[I `\(A^{-1}\)`]

**逆矩阵的另一个观点**
`\(Ax=e_1,Ax=e_2,\cdot \cdot \cdot,Ax=e_n\)` (2),用`\(e_1,\cdot \cdot \cdot e_n\)`表示`\(I_n\)`的各列。则把[A I]行变换成[I `\(A^{-1}\)`]的过程可看作解n个方程组[`\(A\ e_1\ e_2\ \cdot \cdot \cdot\ e_n\)`]=[A I]。方程A`\(A^{-1}\)`=I及矩阵乘法的定义说明`\(A^{-1}\)`的列正好是方程(2)的解。这一点很有用，在某些应用中，只需要`\(A^{-1}\)`的一列或两列。这时只需要解(2)中的相应方程。

###2.3 可逆矩阵的特征
**定理8(可逆矩阵定理)** 设A为n x n矩阵，则下列命题是等价的，即对某一特定的A，它们同时为真或同时不为真。

1. A是可逆矩阵
2. A等价于n x n单位矩阵
3. A有n个主元位置
4. 方程Ax=0仅有平凡解(J:没有自由变量)
5. A的各列线性无关
6. 线性变换x⟼Ax是一对一的
7. 对ℝⁿ中任意b，方程Ax=b至少有一个解
8. A的各列生成ℝⁿ
9. 线性变换x⟼Ax把ℝⁿ映上到ℝⁿ上
10. 存在n x n矩阵C使CA=I
11. 存在n x n矩阵D使AD=I
12. `\(A^T\)`是可逆矩阵

**定义(可逆线性变换)** 当矩阵A可逆时，方程`\(A^{-1}\)`Ax=x可看作关于线性变换的一个命题。

![15](/assets/2014-01-15-linear-algebra/15.png)

线性变换T:ℝⁿ→ℝⁿ称为可逆的，若存在函数S:ℝⁿ→ℝⁿ使得

1. 对所有ℝⁿ中的x，S(T(x))=x
2. 对所有ℝⁿ中的x，T(S(x))=x

下列定理说明若这样的S存在，它是惟一的而且必是线性变换。我们称S是T的逆，把它写成`\(T^{-1}\)`

**定理9(可逆矩阵与线性变换)** 设T:ℝⁿ→ℝⁿ为线性变换，A为T的标准矩阵。则T可逆当且仅当A是可逆矩阵。这时由S(x)=`\(A^{-1}\)`x定义的线性变换S是满足(1)和(2)的惟一函数。

###2.4 分块矩阵
![16](/assets/2014-01-15-linear-algebra/16.png)

**定理10(AB的列行展开)** 若A是m x n矩阵，B是n x p矩阵，则`\(AB=[col_1(A)\ col_2(A)\ \cdot \cdot \cdot col_n(A)]\begin{bmatrix}
row_1(B) \\
row_2(B) \\
\vdots & \\
row_n(B)
\end{bmatrix} = col_1(A)row_1(B)+\cdot \cdot \cdot+col_n(A)row_n(B)\)`


**例4** 设A=`\(\begin{bmatrix}
-3 & 1 & 2 \\
1 & -4 & 5
\end{bmatrix}\)`，B=`\(\begin{bmatrix}
a & b \\
c & d \\
e & f
\end{bmatrix}\)`。证明AB=`\(col_1(A)row_1(B)+col_2(A)row_2(B)+col_3(A)row_3(B)\)`

解 上面的每一项都是`外积`，由计算矩阵乘积的行列法则，有
`\(col_1(A)row_1(B)=\begin{bmatrix}
-3 \\
1
\end{bmatrix}[a\ b]=\begin{bmatrix}
-3a & -3b \\
a & b
\end{bmatrix}\)`,`\(col_2(A)row_2(B)=\begin{bmatrix}
1 \\
-4
\end{bmatrix}[c\ d]=\begin{bmatrix}
c & d \\
-4c & -4d
\end{bmatrix}\)`,`\(col_3(A)row_3(B)=\begin{bmatrix}
2 \\
5
\end{bmatrix}[e\ f]=\begin{bmatrix}
2e & 2f \\
5e & 5f
\end{bmatrix}\)`,于是`\(\sum_{k=1}^3{col_k(A)row_k(B)}=\begin{bmatrix}
-3a+c+2e & -3b+d+2f \\
a-4c+5e & b-4d+5f
\end{bmatrix}\)`

**例5** 形如A=`\(\begin{bmatrix}
A_{11} & A_{12} \\
0 & A_{22}
\end{bmatrix}\)`的矩阵称为分块`上三角矩阵`，设`\(A_{11}\)`是p x p矩阵，`\(A_{22}\)`是q x q矩阵，且A为可逆矩阵。求`\(A^{-1}\)`的表达式。

解 用B表示`\(A^{-1}\)`且把它分块使
`\(\begin{bmatrix}
A_{11} & A_{12} \\
0 & A_{22}
\end{bmatrix}\begin{bmatrix}
B_{11} & B_{12} \\
B_{21} & B_{22}
\end{bmatrix}=\begin{bmatrix}
I_p & 0 \\
0 & I_q
\end{bmatrix}\)` (2)

这个矩阵方程包含了4个有关未知子矩阵`\(B_{11}\)`,…,`\(B_{22}\)`的方程，计算(2)式左边的乘积得

`\(A_{11}B_{11} + A_{12}B_{21}=I_p\)` (3)

`\(A_{11}B_{12} + A_{12}B_{22}=0\)`   (4)

`\(A_{22}B_{21}=0\)`   (5)

`\(A_{22}B_{22}=I_q\)`   (6)

方程(6)本身并不能说明`\(A_{22}\)`可逆，因为我们还不知道`\(B_{22}A_{22}=I_q\)`，但应用可逆矩阵定理，及`\(A_{22}\)`是方阵的事实，可以断定`\(A_{22}\)`可逆且`\(B_{22}=A_{22}^{-1}\)`，现在利用(5)求得`\(B_{21}=A_{22}^{-1}0=0\)`,因此(3)化简为`\(A_{11}B_{11}+0=I_p\)`,这说明`\(A_{11}\)`是可逆的，且`\(B_{11}=A_{11}^{-1}\)`，最后由(4)`\(A_{11}B_{12}=-A_{12}B_{22}=-A_{12}A_{22}^{-1}\)`和`\(B_{12}=-A_{11}^{-1}A_{12}A_{22}^{-1}\)`,于是`\(A^{-1}=\begin{bmatrix}
A_{11} & A_{12} \\
0 & A_{22}
\end{bmatrix}^{-1}=\begin{bmatrix}
A_{11}^{-1} & -A_{11}^{-1}A_{12}A_{22}^{-1} \\
0 & A_{22}^{-1}
\end{bmatrix}\)`

`分块对角矩阵`是一个分块矩阵，除了主对角线上各分块外，其余全是零分块。这样的一个矩阵是可逆的当且仅当主对角线上各分块是可逆的。

###2.5 矩阵因式分解
**定义(LU分解)** 首先，设A是m x n矩阵可以化简为阶梯形而不必行对换，则A可写成A=LU，L是m x m下三角矩阵，主对角线元素全是1，U是A的一个等价的m x n阶梯形矩阵。如下图，这样一个分解称为`LU分解`，矩阵L是可逆的，称为`单位下三角矩阵`。

![17](/assets/2014-01-15-linear-algebra/17.png)

当A=LU时，方程Ax=b可写成L(Ux)=b，把Ux写成y，可以由解下面一对方程来求解x:

* Ly=b
* Ux=y

首先解Ly=b然后解Ux=y求得x。

![18](/assets/2014-01-15-linear-algebra/18.png)

**LU分解算法** 设A可以化为阶梯形U。化简过程中仅用行倍加变换，即把一行的倍数加于它下面的另一行。这样，存在单位三角初等矩阵`\(E_1,...E_p\)`使

`\(E_1,...E_p A = U\)` （3）

于是`\(A=(E_p...E_1)^{-1} U = LU\)`

其中 `\(L = (E_p...E_1)^{-1}\)`(4)

可以证明，单位下三角矩阵的逆也是单位下三角矩阵。于是L是单位下三角矩阵。注意(3)中的行变换，它把A化为U，所以也把(4)中的L化为I，这一点是构造L的关键。

**例2** 求下列矩阵的LU分解:A=`\(\begin{bmatrix}
2 & 4 & -1 & 5 & -2 \\
-4 & -5 & 3 & -8 & 1 \\
2 & -5 & -4 & 1 & 8 \\
-6 & 0 & 7 & -3 & 1
\end{bmatrix}\)`

解 因A有4行，L应为4 x 4矩阵，L的第一列应该是A的第一列除以它的第一行主元元素：L=`\(\begin{bmatrix}
1 & 0 & 0 & 0 \\
-2 & 1 & 0 & 0 \\
1 & \  & 1 & 0 \\
-3 & \  & \  & 1
\end{bmatrix}\)`,比较A和L的第一列。把A的第一列的后3个元素变成0的行变换同时也将L的后3个元素变成0。同样的道理对L的其他各列也是成立的，让我们看一下A变成阶梯形U的过程:

![18-1](/assets/2014-01-15-linear-algebra/18-1.png)

上式中标出的元素确定了将A化为U的行变换，在每个主元列，把标出的元素除以主元后将结果放入L:

![18-2](/assets/2014-01-15-linear-algebra/18-2.png)

容易证明，所求出的L和U满足LU=A。

###2.6 列昂惕夫投入产出模型
设某国的经济体系分为n个部门，这些部门生产商品和服务。设x为ℝⁿ中`产出向量`。它列出了每一部门一年中的产出。同时，设经济体系的另一部分(称为开放部门)不生产产品或服务，仅仅消费商品或服务，d为`最终需求向量`，它列出经济体系中的各种非生产部门所需求的商品和服务，此向量代表消费者需求、政府消费、超额生产、出口或其他外部需求。

由于各部门生产商品以满足消费者需求，生产者本身创造了`中间需求`，需要这些产品作为生产部门的投入，部门之间的关系是很复杂的，而生产和最后需求之间的联系也还不清楚。列昂惕夫思考是否存在某一生产水平x恰好的满足这一生产水平的总需求(x称为供给)，那么

{总产出x}={中间需求}+{最终需求d} (1)

作为一个简单的例子，设经济体系由三个部门组成——制造业、农业和服务业。单位消费向量c1,c2,c3如下表所示。

![19](/assets/2014-01-15-linear-algebra/19.png)

若制造业决定生产x1单位产出，则在生产的过程中消费掉的中间需求是x1c1，类似地，若x2和x3表示农业和服务业的计划产出，则x2c2和x3c3为它们的对应中间需求，三个部门的中间需求为

{中间需求}=x1c1+x2c2+x3c3=Cx                         (2)

这里C是`消耗矩阵`{c1，c2，c3}，即

C=`\(\begin{bmatrix}
.50 & .40 & .20 \\
.20 & .30 & .10 \\
.10 & .10 & .30
\end{bmatrix}\)` (3)

`列昂惕夫投入产出模型或生产方程` x = Cx + d    (4)(总产出 = 中间需求 + 最终需求) 

Ix - Cx = d,(I - C)x = d (5)

**例2** 考虑消耗矩阵为(3)的经济。假设最终需求是制造业50单位，农业30单位，服务业20单位，求生产水平x。
**解** (5)中系数矩阵为I - C = `\(\begin{bmatrix}
1 & 0 & 0 \\
0 & 1 & 0 \\
0 & 0 & 1
\end{bmatrix} - \begin{bmatrix}
.5 & .4 & .2 \\
.2 & .3 & .1 \\
.1 & .1 & .3
\end{bmatrix} = \begin{bmatrix}
.5 & -.4 & -.2 \\
-.2 & .7 & -.1 \\
-.1 & -.1 & .7
\end{bmatrix}\)`

为解方程(5)，对增广矩阵作行变换`\(\begin{bmatrix}
.5 & -.4 & -.2 & 50 \\
-.2 & .7 & -.1 & 30 \\
-.1 & -.1 & .7 & 20
\end{bmatrix} \sim \begin{bmatrix}
5 & -4 & -2 & 500 \\
-2 & 7 & -1 & 300 \\
-1 & -1 & 7 & 200
\end{bmatrix} \sim\cdot \cdot \cdot\sim\begin{bmatrix}
1 & 0 & 0 & 226 \\
0 & 1 & 0 & 119 \\
0 & 0 & 1 & 78
\end{bmatrix}\)`,最后得到制造业生产约226单位，农业119单位，服务业78单位。

**定理11(列昂惕夫生产方程)** 设C为某一经济的消耗矩阵，d为最终需求。若C和d的元素非负，C的每一列的和小于1.则(1-C)-1存在，而产出向量`\(x = (1-C)^{-1}d\)`,有非负元素，且是下列方程的惟一解`\(x = Cx + d\)`

###2.8 ℝⁿ的子空间
**定义(ℝⁿ的子空间)** ℝⁿ中的一个`子空间`是ℝⁿ中的集合H，具有以下三个性质：

1. 零向量属于H
2. 对H中任意的向量u和v，u+v也属于H
3. 对H中任意向量u和数c，cu属于H

**定义(矩阵的列空间)** 矩阵A的`列空间`是A的各列的线性组合的集合，记作Col A。

**例4** 设A=`\(\begin{bmatrix}
1 & -3 & -4 \\
-4 & 6 & -2 \\
-3 & 7 & 6
\end{bmatrix}\)`,b=`\(\begin{bmatrix}
3 \\
3 \\
-4
\end{bmatrix}\)`,确定b是否属于A的列空间。

解 向量b是A的各列的线性组合，当且仅当b可写成Ax的形式，x属于ℝ3，也就是说，当且仅当方程Ax=b有解。把增广矩阵[A b]进行行变换：`\(\begin{bmatrix}
1 & -3 & -4 & 3\\
-4 & 6 & -2 & 3\\
-3 & 7 & 6 & -4
\end{bmatrix}\)` ~ `\(\begin{bmatrix}
1 & -3 & -4 & 3\\
0 & -6 & -18 & 15\\
0 & -2 & -6 & 5
\end{bmatrix}\)` ~ `\(\begin{bmatrix}
1 & -3 & -4 & 3\\
0 & -6 & -18 & 15\\
0 & 0 & 0 & 0
\end{bmatrix}\)`，可知Ax=b相容，从而b属于Col A。

![19-1](/assets/2014-01-15-linear-algebra/19-1.png)

例4的解答说明，`当线性方程组写成Ax=b的形式，A的列空间是所有使方程有解的向量b的集合。`

**定义(矩阵的零空间)** 矩阵A的`零空间`是齐次方程Ax=0的所有解的集合，记为Nul A。当A有n列时，Ax=0的解属于ℝⁿ，A的零空间是ℝⁿ的子集。事实上，Nul A具有ℝⁿ的子空间的性质。

**定理12(齐次线性方程解集与子空间)** m x n矩阵A的零空间是ℝⁿ的子空间。等价地，n个未知数的m个齐次线性方程的解的全体是ℝⁿ的子空间。

**定义(子空间的基)** ℝⁿ中子空间H的一组`基`是H中一个线性无关集，它生成H。

**例6** 求出下列矩阵的零空间的基。A=`\(\begin{bmatrix}
-3 & 6 & -1 & 1 & -7 \\
1 & -2 & 2 & 3 & -1 \\
2 & -4 & 5 & 8 & -4
\end{bmatrix}\)`

解 首先把方程Ax=0的解写成参数向量形式。A=`\(\begin{bmatrix}
1 & -2 & 0 & -1 & 3 & 0 \\
0 & 0 & 1 & 2 & -2 & 0 \\
0 & 0 & 0 & 0 & 0 & 0
\end{bmatrix}\)`，`\(\begin{cases} 
x_1-2x_2-x_4+3x_5=0 \\
x_3+2x_4-2x_5=0 \\
0=0
\end{cases}\)`,通解为`\(x_1=2x_2+x_4-3x_5,x_3=-2x_4+2x_5,x_2,x_4,x_5\)`为自由变量。

![19-2](/assets/2014-01-15-linear-algebra/19-2.png)

方程(1)说明Nul A与u,v,w的所有线性组合的集合是一致的，即{u,v,w}生成Nul A，事实上，u,v,w的构造保证了它们线性无关，因为(1)说明，若`\(0=x_2u+x_4v+x_5w\)`，则权`\(x_2,x_4,x_5\)`等于零，因此{u,v,w}是Nul A的一组基。

上例说明，`求出方程Ax=0的解的参数向量形式实际上就是确定Nul A的基`。

**例7** 求下列矩阵的列空间的基：B=`\(\begin{bmatrix}
1 & 0 & -3 & 5 & 0 \\
0 & 1 & 2 & -1 & 0 \\
0 & 0 & 0 & 0 & 1 \\
0 & 0 & 0 & 0 & 0
\end{bmatrix}\)`

解 用`\(b_1,...,b_5\)`表示B的列，注意`\(b_3=-3b_1+2b_2,b_4=5b_1-b_2\)`,`\(b_3\)`和`\(b_4\)`是主元列的线性组合。这意味着`\(b_1,...,b_5\)`的任意线性组合实际上仅是`\(b_1\)`,`\(b_2\)`和`\(b_5\)`的线性组合。所以`\(b_1\)`,`\(b_2\)`和`\(b_5\)`生成Col B，又`\(b_1\)`,`\(b_2\)`和`\(b_5\)`为线性无关，因为它们是单位矩阵的列，所以B的主元列构成Col B的基。

对于一般的矩阵A，当A行化简为阶梯形B，它的列虽然改变，但方程Ax=0和Bx=0有相同的解集。即，A的列与B的列有相同的线性相关关系。

**定理13(矩阵列空间的基)** 矩阵A的主元列构成列空间的`基`。

警告 小心，要用A的主元列本身作为Col A的基，阶梯形B的列本身通常并不在A的列空间内。

###2.9 维数与秩
**定义(坐标向量)** 假设B={`\(b_1,b_2,…b_p\)`}是子空间H的一组基，对H中的每一个向量x，相对于基B的坐标是使`\(x=c_1b_1+…+c_pb_p\)`成立的权值`\(c_1,…,c_p\)`，且ℝⁿ中的向量`\([x]_B=\begin{bmatrix}
c_1 \\
\vdots \\
c_p
\end{bmatrix}\)`,称为x(相对于B)的`坐标向量`，或x的B-坐标向量。

**例1** 设`\(v_1=\begin{bmatrix}
3 \\
6 \\
2
\end{bmatrix}\)`,`\(v_2=\begin{bmatrix}
-1 \\
0 \\
1
\end{bmatrix}\)`,`\(x=\begin{bmatrix}
3 \\
12 \\
7
\end{bmatrix}\)`,B={`\(v_1,v_2\)`},则因`\(v_1,v_2\)`线性无关，B是H=Span{`\(v_1,v_2\)`}的基。判断x是否在H中，如果是，求x相对基B的坐标向量。

解 如果x在H中，则下面的向量方程是相容的：`\(c_1 \begin{bmatrix}
3 \\
6 \\
2
\end{bmatrix} + c_2 \begin{bmatrix}
-1 \\
0 \\
1
\end{bmatrix}=\begin{bmatrix}
3 \\
12 \\
7
\end{bmatrix}\)`,如果数`\(c_1,c_2\)`存在，即是x的B-坐标。由行操作得`\(\begin{bmatrix}
3 & -1 & 3 \\
6 & 0 & 12\\
2 & 1 & 7
\end{bmatrix}\)` ~ `\(\begin{bmatrix}
1 & 0 & 2 \\
0 & 1 & 3\\
0 & 0 & 0
\end{bmatrix}\)`，于是`\(c_1\)`=2，`\(c_2\)`=3，`\([x]_B=\begin{bmatrix}
2 \\
3
\end{bmatrix}\)`,基B确定H上的一个“坐标系”，如下图所示。

![19-3](/assets/2014-01-15-linear-algebra/19-3.png)

**定义(维数)** 非零子空间H的`维数`，用dimH表示，是H的任意一个基的向量个数。零子空间{0}的维数定义为零。

**例2** 回忆2.8例6中矩阵A的零空间有一个基包含3个向量，因此这里Nul A的维数为3.观察到每个基向量对应方程Ax=0的一个自由变量。我们的构造方法总是以这种方式产生一个基。因此，`要确定Nul A的维数，只需求出Ax=0中的自由变量的个数`。

**定义(秩)** 矩阵A的`秩`(记为rank A)是A的列空间的维数。因为A的主元列形成Col A的一个基，A的秩正好是A的主元列的个数。

**定理14(秩定理)** 如果一矩阵A有n列，则rankA+dim Nul A = n。(J:rankA即基本变量的个数，dim Nul A即自由变量的个数)

**定理15(基定理)** 设H是ℝⁿ的p维子空间，H中的任何恰好由p个成员组成的线性无关集构成H的一个基。并且，H中任何生成H的p个向量集也构成H的一个基。

**定理(可逆矩阵定理8续)**

13. A的列向量构成ℝⁿ的一个基
14. Col A = ℝⁿ
15. dim Col A =n
16. rankA = n
17. NulA = {0}
18. dim NulA=0

****

##第3章 行列式
###3.1 行列式介绍
**定义(矩阵的行列式)** 考虑可逆矩阵`\(A=[a_{ij}],a_{11} \neq 0\)`,

A ~ `\(\begin{bmatrix}
a_{11} & a_{12} & a_{13} \\
a_{11}a_{21} & a_{11}a_{22} & a_{11}a_{23} \\
a_{11}a_{31} & a_{11}a_{32} & a_{11}a_{33}
\end{bmatrix}\)` ~ `\(\begin{bmatrix}
a_{11} & a_{12} & a_{13} \\
0 & a_{11}a_{22}-a_{12}a_{21} & a_{11}a_{23}-a_{13}a_{21} \\
0 & a_{11}a_{32}-a_{12}a_{31} & a_{11}a_{33}-a_{13}a_{31}
\end{bmatrix}\)` (1)

A ~ `\(\begin{bmatrix}
a_{11} & a_{12} & a_{13} \\
0 & a_{11}a_{22}-a_{12}a_{21} & a_{11}a_{23}-a_{13}a_{21} \\
0 & 0 & a_{11}\vartriangle
\end{bmatrix}\)` 

这里 `\(\vartriangle=a_{11}a_{22}a_{33}+a_{12}a_{23}a_{31}+a_{13}a_{21}a_{32}-a_{11}a_{23}a_{32}-a_{12}a_{21}a_{33}-a_{13}a_{22}a_{31}\)`(2)

由于A可逆，∆一定不等于零。我们称(2)中∆为3x3`矩阵A的行列式`。

`\(\vartriangle=(a_{11}a_{22}a_{33}-a_{11}a_{23}a_{32})-(a_{12}a_{21}a_{33}-a_{12}a_{23}a_{31})+(a_{13}a_{21}a_{32}-a_{13}a_{22}a_{31})\)`

`\(\vartriangle=a_{11}\cdot det\begin{bmatrix}
a_{22} & a_{23} \\
a_{32} & a_{33}
\end{bmatrix}-a_{12}\cdot det\begin{bmatrix}
a_{21} & a_{23} \\
a_{31} & a_{33}
\end{bmatrix}+a_{13}\cdot det\begin{bmatrix}
a_{21} & a_{22} \\
a_{31} & a_{32}
\end{bmatrix}\)`

为了简单可写成`\(\vartriangle=a_{11}\cdot detA_{11}-a_{12}\cdot detA_{12}+a_{13}\cdot detA_{13}\)`,这里`\(A_{11},A_{12},A_{13}\)`由A中划去第一行和三列中之一列而得到。对任意方阵A，令`\(A_{ij}\)`表示通过划掉A中第i行和第j列而得到的子矩阵。

**定义(余因子展开式)** 当n≥2，n x n矩阵A=[`\(a_{ij}\)`]的行列式是形如`\(±a_{ij}detA_{ij}\)`的n个项的和，其中加号和减号交替出现，这里元素`\(a_{11},a_{12},\cdot \cdot \cdot,a_{1n}\)`来自A的第一行，即`\(detA=a_{11}detA_{11}-a_{12}detA_{12}+\cdot \cdot \cdot (-1)^{1+n}a_{1n}detA_{1n}=\sum_{j=1}^n{(-1)^{1+j}a_{1j}detA_{1j}}\)`

令`\(C_{ij}=(-1)^{i+j}detA_{ij}\)`(4)

则`\(detA=a_{11}C_{11}+a_{12}C_{12}+\cdot \cdot \cdot +a_{1n}C_{1n}\)`,
公式(4)称为按A的第一行的`余因子展开式`。

**定理1(余因子展开)** n x n矩阵A的行列式可按任意行或列的余因子展开式来计算。按第i行展开用(4)式给出的余因子写法可以写成：`\(detA=a_{i1}C_{i1}+a_{i2}C_{i2}+\cdot \cdot \cdot +a_{in}C_{in}\)`

按第j列的余因子展开式为：`\(detA=a_{1j}C_{1j}+a_{2j}C_{2j}+\cdot \cdot \cdot +a_{nj}C_{nj}\)`

**定理2(三角阵的行列式)** 若A为三角阵，则detA等于A的主对角线上元素的乘积。

###3.2 行列式的性质
**定理3(行变换)** 令A是一个方阵。

1. 若A的某一行的倍数加到另一行得矩阵B，则detB=detA
2. 若A的两行互换得矩阵B，则detB=-detA
3. 若A的某行乘以k倍得到矩阵B，则detB=k∙detA

若一个方阵A被行倍加和行变换化简为阶梯形U，且此过程经过了r次行交换，则定理3表明`\(
detA=(-1)^r detU\)`。由于U是阶梯形，它是三角阵，因此detU是主对角线上的元素`\(u_{11},…,u_{nn}\)`的乘积。若A可逆，则元素`\(u_{ii}\)`都是主元(因为A~In且`\(u_{ii}\)`没有被倍乘变为I)。否则，至少有`\(u_{ii}\)`等于零，乘积`\(u_{11},…,u_{nn}\)`为零。见下图。

![20](/assets/2014-01-15-linear-algebra/20.png)

从而有以下公式`\(detA =
\begin{cases} 
(-1)^r \cdot (U的主元乘积), & 当A可逆 \\
0, & 当A不可逆
\end{cases}\)`

**定理4(可逆方阵)** 方阵A是可逆的当且仅当detA≠0.

定理4把语句“detA≠0”增加到可逆矩阵定理中。一个有用的推论是若A的列是线性相关的，则detA=0。而且若A的行是线性相关的，则detA=0。(A的行是`\(A^T\)`的列，由`\(A^T\)`的列线性相关可推出是`\(A^T\)`奇异的。当`\(A^T\)`是奇异矩阵时，由可逆矩阵定理可知，A也是奇异的)在实际问题中，当两行或两列是相同的或者一行或一列是零时，则线性相关是显然的。

**定理5(转置方阵)** 若A为一个n x n矩阵，则det`\(A^T\)`=detA

**定理6(方阵乘法的性质)** 若A和B均为n x n矩阵，则detAB=(detA)(detB)

警告 一般而言，det(A+B)≠detA+detB

###3.3 克拉默法则、体积和线性变换
**定理7(克拉默法则)** 对任意n x n矩阵A和任意的ℝⁿ中向量b，令`\(A_i(b)\)`表示A中第i列由向量b替换得到的矩阵

![21](/assets/2014-01-15-linear-algebra/21.png)

方程Ax=b的唯一解可由下式给出`\(x_i=\frac{detA_i(b)}{detA},i=1,2,...,n\)` (1)

**一个求`\(A^{-1}\)`的公式**

克拉默法则可以容易地导出一个求n x n矩阵A的逆的一般公式。`\(A^{-1}\)`的第j列是一个向量x，满足`\(Ax=e_j\)`,此处`\(e_j\)`是单位矩阵的第j列，x的第i个数值是`\(A^{-1}\)`中(i,j)位置的数值，由克拉默法则

`\(\{A^{-1}中(i,j)元素\}=x_i=\frac{detA_i(e_i)}{detA}\)` (2)

回想起Aji表示A的子矩阵，它由A去掉第j行和第i列得到。`\(A_i(e_j)\)`按第i行的余因子展开式为

`\(detA_i(e_j)=(-1)^{i+j}detA_{ji}=C_{ji}\)` (3)

这里`\(C_{ji}\)`是A的余因子式。由(2)，`\(A^{-1}\)`的(i,j)元素等于余因子`\(C_{ji}\)`除以detA。于是

`\(A^{-1}=\frac{1}{detA}\begin{bmatrix}
C_{11} & C_{21} & \cdots & C_{n1} \\
C_{12} & C_{22} & \cdots & C_{n2} \\
\vdots & \vdots & \ & \vdots \\
C_{1n} & C_{2n} & \cdots & C_{nn}
\end{bmatrix}\)` (4)

(4)右边的余因子的矩阵称为A的`伴随矩阵`，记为adjA。

**定理8(逆矩阵公式)** 设A是一个可逆的n x n矩阵，则`\(A^{-1}=\frac{1}{detA}adjA\)`

**定理9(行列式表示面积或体积)** 若A是一个2x2矩阵，则由A的列确定的平行四边形的面积为|detA|,若A是一个3x3矩阵，则由A的列确定的平行六面体的体积为|detA|。

**定理10(线性变换表示面积或体积)** 设T:ℝ2⟶ℝ2是由一个2 x 2矩阵A确定的线性变换，若S是ℝ2中一个平行四边形，则{T(S)的面积}=|det A| ∙ {S的面积}。若T是一个由3 x 3矩阵A确定的线性变换，而S是ℝ3中一个平行六面体，则{T(S)的体积}=|det A| ∙ {S的体积}

****

##第4章 向量空间
###4.1 向量空间与子空间
**定义(向量空间)** 一个`向量空间`是由一些被称为向量的对象构成的非空集合V，在这个集合上定义两个运算，称为加法和标量乘法(标量取实数)，服从以下公理(或法则)，这些公理必须对V中所有向量u，v，w及所有标量c和d均成立。

1. u，v之和表示为u+v，仍在V中
2. u+v=v+u
3. (u+v)+w=u+(v+w)
4. V中存在一个零向量0，使得u+0=u
5. 对V中每个向量u，存在V中向量-u，使得u+(-u)=0
6. u与标量c的标量乘法记为cu，仍在V中
7. c(u+v)=cu+cv
8. (c+d)u=cu+du
9. c(du)=(cd)u
10. 1u=u

公理4中的`零向量`是惟一的。对V中每个向量u，公理5中向量-u称为u的`负向量`。

**定义(子空间)** 向量空间V的一个`子空间`是V的一个满足以下三个性质的子集H：

1. V中的零向量在H中
2. H对向量加法封闭，即对H中任意向量u，v，和u+v仍在H中
3. H对标量乘法封闭，即对H中任意向量u和任意标量c，向量cu仍在H中

向量空间V中仅由零向量组成的集合是V的一个子空间，称为`零子空间`，写成{0}。

**定理1(集合生成的子空间)** 若`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`在向量空间V中，则Span{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}是V的一个子空间。我们称Span{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}是由{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}生成(或张成)的`子空间`，任给V的子空间H，H的生成(或张成)集是集合{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`} ⊂ H,使得H=Span{`\(v_1,v_2,\cdot \cdot \cdot,v_p\)`}。

###4.2 零空间、列空间和线性变换

**定义(矩阵的零空间)** m x n矩阵A的`零空间`写成NulA，是齐次方程租Ax=0的全体解的集合，用集合符号表示，即 NulA={x:x∈ℝⁿ,Ax=0}

Nul的更进一步的描述为ℝⁿ中在线性变换x⟼Ax下映射到ℝᵐ中的零向量的全体向量的集合：

![22](/assets/2014-01-15-linear-algebra/22.png)

**定理2(子空间)** m x n矩阵A的零空间是ℝⁿ的一个`子空间`，等价地，m个方程、n个未知数的齐次线性方程组Ax=0的全体解的集合是ℝⁿ的一个`子空间`。

**定义(NulA的显式刻画)** NulA中的向量与A中的数值之间没有明显的关系。我们称NulA被隐式地定义，这是由于它被一个必须要检验的条件所定义，没有明确地给出NulA中的元素。然而，当我们解出方程组Ax=0，我们就得到NulA的`显式刻画`。

**例3** 求矩阵A的零空间的生成集，其中A=`\(\begin{bmatrix}
-3 & 6 & -1 & 1 & -7 \\
1 & -2 & 2 & 3 & -1 \\
2 & -4 & 5 & 8 & -4
\end{bmatrix}\)`

解 第一步是求Ax=0的关于自由变量的通解，通过行简化增广矩阵[A 0]化为简化阶梯形矩阵为`\(\begin{bmatrix}
1 & -2 & 0 & -1 & 3 & 0 \\
0 & 0 & 1 & 2 & -2 & 0 \\
0 & 0 & 0 & 0 & 0 & 0
\end{bmatrix},\begin{cases} 
x_1-2x_2-x_4+3x_5=0 \\
x_3+2x_4-2x_5=0 \\
0=0
\end{cases}\)`,通解为`\(x_1=2x_2+x_4-3x_5\)`，`\(x_3=-2x_4+2x_5\)`，`\(x_2,x_4,x_5\)`是自由变量。其次，将通解给出的向量分解为向量组合，用自由变量作权，即：

![23](/assets/2014-01-15-linear-algebra/23.png)

u，v和w的每一个线性组合都是NulA中的一个元素，从而{u,v,w}是NulA的一个生成集。
关于例3的解应该得到以下两点事实，它们对所有此类问题均适合，我们将在后面用到。

1. 由例3中的方法产生的生成集必然是线性无关的，这是因为自由变量是生成向量上的权。比如，见(3)式中解向量的第2，4，5个数，注意到只有当x2，x4，x5全为零时`\(x_2u+x_4v+x_5w\)`为零。
2. Nul A的生成集中向量的个数等于方程Ax=0中自由变量的个数。

**定义(列空间)** m x n矩阵的`列空间`(记为ColA)是由A的列的所有线性组合组成的集合，若A=[a1,…,an]，则Col A=Span{a1,…,an}。

**定理3(矩阵的列空间)** m x n矩阵A的`列空间`是ℝᵐ的一个子空间。m x n矩阵A的列空间等于ℝᵐ当且仅当方程Ax=b对ℝᵐ中每个b有一个解。 

**对m x n矩阵A，NulA与Col A的对比**

1. NulA是ℝⁿ的一个子空间；ColA是ℝᵐ的一个子空间
2. NulA是隐式定义的，即仅给出了一个NulA中向量必须满足的条件(Ax=0)；ColA是显式定义，即明确指出如何建立ColA中的向量
3. 求NulA中的向量需要时间，需要对[A 0]做行变换；容易求出ColA中的向量，A中的列就是ColA中的向量，其余的可由A的列表示出来
4. NulA与A的数值之间没有明显的关系；ColA与A的数值之间有明显的关系，因为A的列就在ColA中
5. NulA中的一个典型向量v具有Av=0的性质；ColA中一个典型向量v具有方程Ax=v是相容的性质
6. 给一个特定的向量v，任意判断v是否在NulA中，仅需计算Av；给一个特定的向量v，弄清v是否在ColA中需要时间，需要对[A v]作行变换
7. NulA={0}当且仅当Ax=0仅有一个平凡解；ColA=ℝᵐ当且仅当Ax=b对每一个b∈ℝᵐ有一个解
8. NulA={0}当且仅当线性变换x⟼Ax是一对一的；ColA=ℝᵐ当且仅当线性变换x⟼Ax将ℝⁿ映上到ℝᵐ

**定义(向量空间的线性变换)** 由向量空间V映射到向量空间W内的线性变换T是一个规则，它将V中每个向量x映射成W中惟一向量T(x)，且满足：

1. T(u + v)=T(u) + T(v) ，对V中所有u，v均成立
2. T(cu)=cT(u)，对V中所有u及所有数c均成立

线性变换T的核(或零空间)是V中所有满足T(u)=0的向量u的集合(0为W中的零向量)。T的值域是W中所有具有形式T(x)(任意x∈V)的向量的集合。如果T是由一个矩阵变换得到的，比如对某矩阵A，T(x)=Ax，则T的核与值域恰好是前面定义的A的零空间和列空间。

不难证明T的核是V的一个子空间。T的值域也是W的一个子空间。

![24](/assets/2014-01-15-linear-algebra/24.png)

###4.3 线性无关集和基
**定义(向量集的线性相关)** V中向量的一个指标集{`\(v_1,…,v_p\)`}称为线性无关的，如果向量方程`\(c_1v_1+c_2v_2+…+c_pv_p=0\)` (1)只有平凡解。

集合{`\(v_1,…,v_p\)`}称为线性相关，如果(1)有一个非平凡解，即存在某些权`\(c_1,…,c_p\)`不全为零，使得(1)式成立，此时(1)式称为`\(v_1,…,v_p\)`之间的一个线性相关关系。

与ℝⁿ中一样，一个仅含一个向量v的集是线性无关的当且仅当v≠0；一个仅含两个向量的集合是线性相关的当且仅当其中一个向量是另一个的倍数；任何含有零向量的集合是线性相关的。下列定理与1.6节中定理7证法相同。

**定理4(向量集的线性相关)** 不少于两个有编号的向量的集合{`\(v_1,…,v_p\)`}，如果有v1≠0，则{`\(v_1,…,v_p\)`}是线性相关的，当且仅当某vj(j>1)是其前面向量`\(v_1,…,v_{j-1}\)`的线性组合。

**定义(向量空间线性相关与ℝⁿ线性相关区别)** 一般向量空间中的线性相关与ℝⁿ中的线性相关的主要不同点在于当向量不是n元数组时，齐次方程(1)通常不能被写成一个n元线性方程组。换句话说，为了研究方程Ax=0，向量不能从一个矩阵A的列中得到，取而代之的是我们必须要依靠线性相关的定义和定理4。

**定义(向量空间的基)** 令H是向量空间V的一个子空间，V中向量的指标集B={`\(b_1,…,b_p\)`}称为H的一个`基`，如果

1. B是一个线性无关集
2. 由B生成的子空间与H相同，即H=Span{`\(b_1,…,b_p\)`}

**例4** 令e1,…,en是 n x n单位矩阵In的列，即`\(e_1=\begin{bmatrix}
1 \\
0 \\
\vdots \\
0
\end{bmatrix}\)`,`\(e_2=\begin{bmatrix}
0 \\
1 \\
\vdots \\
0
\end{bmatrix}\)`,...,`\(e_n=\begin{bmatrix}
0 \\
0 \\
\vdots \\
1
\end{bmatrix}\)`,集合{e1,…,en}称为ℝⁿ的`标准基`。

![25](/assets/2014-01-15-linear-algebra/25.png)

**定理5(生成集定理)** 令S={`\(v_1,…,v_p\)`}是V中的向量集，H=Span{`\(v_1,…,v_p\)`}。

1. 若S中某一个向量，比如说`\(v_k\)`，是S中其余向量的线性组合，则S中去掉`\(v_k\)`后形成的集合仍然可以生成H。
2. 若H≠{0}，则S的某一子集是H的一个基。

**定理6(ColA的基)** 矩阵A的主元列构成ColA的一个基。

**关于基的两点观察** 一个基是一个尽可能小的生成集，还是尽可能大的线性无关集。

###4.4 坐标系
**定理7(惟一表示定理)** 令B={`\(b_1,…,b_p\)`}是向量空间V的一个基，则对V中每个向量x，存在惟一的一组数`\(c_1,…,c_n\)`使得`\(x=c_1b_1+…+c_nbn\)` (1)

**定义(B-坐标向量)** 假设集合B={`\(b_1,…,b_p\)`}是V的一个基，x在V中，x相对于基B的坐标(或x的B-坐标)是使得`\(x=c_1b_1+…+c_nbn\)`的权`\(c_1,…,c_n\)`。若`\(c_1,…,c_n\)`是x的B-坐标，则ℝⁿ中的向量`\([x]_B=\begin{bmatrix}
c_1 \\
c_2 \\
\vdots \\
c_n
\end{bmatrix}\)`是x(相对于B)的坐标向量，或x的`B-坐标向量`，映射x⟼[x]B称为(由B确定的)坐标映射。

**例1(坐标的几何意义)** 考虑ℝ2中的一个基B={`\(b_1,b_2\)`},这里`\(b_1=\begin{bmatrix}
1 \\
0 
\end{bmatrix}\)`,`\(b_2=\begin{bmatrix}
1 \\
2 
\end{bmatrix}\)`,假设ℝ2中一向量x具有坐标向量`\([x]_B=\begin{bmatrix}
-2 \\
3 
\end{bmatrix}\)`,求x。

解 x的B-坐标揭示如何由B中的向量求x。即x=-2b1+3b2=(-2)`\(\begin{bmatrix}
1 \\
0 
\end{bmatrix}\)`+3`\(\begin{bmatrix}
1 \\
2 
\end{bmatrix}\)`=`\(\begin{bmatrix}
1 \\
6 
\end{bmatrix}\)`

一个集合上的坐标系由此集合中点到ℝⁿ中的一一映射组成。例如，当我们选取垂直的轴同时在每个轴上取一个相同的度量单位时，通常的图纸给出了平面上的一个坐标系。下图1展示了标准基{e1,e2}，例1中的向量b1(=e1)和b2以及向量x=`\(\begin{bmatrix}
1 \\
6 
\end{bmatrix}\)`。坐标1和6给出x相对于标准基的位置：在e1方向上有1个单位，在e2方向上有6个单位。下图2展示来自下图1的向量b1,b2,x。(从几何意义上看，这三个向量在这两个图中均位于一条垂线上)然而，标准坐标的格子被去掉同时被特别适合例1中的坐标B的格子所取代。坐标向量`\([x]_B=\begin{bmatrix}
-2 \\
3 
\end{bmatrix}\)`给出x在新的坐标系中的位置：在b1方向上有-2个单位，在b2方向上有3个单位。

![25-1](/assets/2014-01-15-linear-algebra/25-1.png)

**例4(坐标变换矩阵)** 令`\(b_1=\begin{bmatrix}
2 \\
1 
\end{bmatrix}\)`,`\(b_2=\begin{bmatrix}
-1 \\
1 
\end{bmatrix}\)`,`\(x=\begin{bmatrix}
4 \\
5 
\end{bmatrix}\)`,B={b1,b2},求出x相对于B的坐标向量`\([x]_B\)`

解 x的B-坐标c1,c2满足

![25-2](/assets/2014-01-15-linear-algebra/25-2.png)

这个方程可以通过在一增广矩阵上做行变换或利用左边矩阵的逆解出。不论哪种解法，其解均为c1=3,c2=2,从而x=3b1+2b2,同时有`\([x]_B=\begin{bmatrix}
c_1 \\
c_2 
\end{bmatrix}\)`=`\(\begin{bmatrix}
3 \\
2 
\end{bmatrix}\)`,见下图

![25-3](/assets/2014-01-15-linear-algebra/25-3.png)

(3)式中的矩阵将向量x的B-坐标变为x的标准坐标，对ℝⁿ中的一个基B={`\(b_1,...,b_n\)`}，可以施行类似的坐标变换，令`\(P_B=[b_1\ b_2\ ...\ b_n]\)`

则向量方程`\(x=c_1b_1+c_2b_2+...+c_nb_n\)`

等价于`\(x=P_B[x]_B\)`，我们称`\(P_B\)`为从B到ℝⁿ中标准基的`坐标变换矩阵`。通过左乘`\(P_B\)`将坐标向量`\([x]_B\)`变换到x。

**定理8(坐标映射)** 令B={`\(b_1,…,b_p\)`}是向量空间V的一个基，则坐标映射x⟼[x]B是一个由V映射到ℝⁿ的一对一的线性变换。

![25-4](/assets/2014-01-15-linear-algebra/25-4.png)

###4.5 向量空间的维数
**定理9(向量空间的基与线性相关)** 若向量空间V具有一组基B={`\(b_1,…,b_p\)`}，则V中任意包含多于n个向量的集合一定线性相关。

**定理10(向量空间基的向量个数)** 若向量空间V有一组基含有n个向量，则V的每一组基一定恰好含有n个向量。

**定义(向量空间的维数)** 若V由一个有限集生成，则V称为`有限维的`，V的维数写成`dimV`，是V的基中含有向量的个数，零向量空间{0}的维数定义为零。如果V不是由一有限集生成，则V称为`无穷维的`。

**定理11(有限维空间子空间的维数)** 令H是有限维向量空间V的子空间，若有需要的话，H中任一个线性无关集均可以扩充成为H的一个基，H也是有限维的并且dimH≤dimV

**定理12(基定理)** 令V是一个p维向量空间，p≥1，V中任意含有p个元素的线性无关集必然是V的一个基。任意含有p个元素且生成V的集合必然是V的一个基。

**定义(NulA和ColA的维数)** NulA的维数是方程Ax=0中自由变量的个数，ColA的维数是A中主元列的个数。

###4.6 秩
**定义(行空间)** 若A是一个m x n矩阵，A的每一行具有n个数字，即可以视为ℝⁿ中一个向量，其行向量所有线性组合的集合称为A的`行空间`，记为RowA。由于每一行具有n个数，所以RowA是ℝⁿ的一个子空间。因为A的行和`\(A^T\)`的列相同，我们也可用Col`\(A^T\)`代替RowA。

**定理13(行空间的基)** 若两个矩阵A和B行等价，则它们的行空间相同。若B是阶梯形矩阵，则B的非零行构成A的行空间的一个基同时也是B的行空间的一个基。

**例2** 分别求矩阵A的行空间、列空间和零空间的基。A=`\(\begin{bmatrix}
-2 & -5 & 8 & 0 & -17 \\
1 & 3 & -5 & 1 & 5 \\
3 & 11 & -19 & 7 & 1 \\
1 & 7 & -13 & 5 & -3 
\end{bmatrix}\)`

解 为了求行空间和列空间的基，行化简A成阶梯形:A~B=`\(\begin{bmatrix}
1 & 3 & -5 & 1 & 5 \\
0 & 1 & -2 & 2 & -7 \\
0 & 0 & 0 & -4 & 20 \\
0 & 0 & 0 & 0 & 0 
\end{bmatrix}\)`，由定理13，B的前三行构成A的行空间的一个基(也是B的行空间的一个基)，从而

RowA的基：{(1,3,-5,1,5),(0,1,-2,2,-7),(0,0,0,-4,20)}

对列空间，观察B，主元列在第1，2和4列，从而A的第1，2和4列(不是B的)构成ColA的一个基

ColA的基:{`\(\begin{bmatrix}
-2 \\
1 \\
3 \\
1
\end{bmatrix}\)`,`\(\begin{bmatrix}
-5 \\
3 \\
11 \\
7
\end{bmatrix}\)`,`\(\begin{bmatrix}
0 \\
1 \\
7 \\
5
\end{bmatrix}\)`}

对于NulA，则需要简化行阶梯形，则B进一步行变换得A~B~C=`\(\begin{bmatrix}
1 & 0 & 1 & 0 & 1 \\
0 & 1 & -2 & 0 & 3 \\
0 & 0 & 0 & 1 & -5 \\
0 & 0 & 0 & 0 & 0 
\end{bmatrix}\)`，方程Ax=0等价于Cx=0，即`\(\begin{cases} 
x_1+x_3+x_5=0 \\
x_2-2x_3+3x_5=0 \\
x_4-5x_5=0
\end{cases}\)`

所以`\(x_1=-x_3-x_5\)`,`\(x_2=2x_3-3x_5\)`,`\(x_4=5x_5\)`,`\(x_3\)`和`\(x_5\)`为自由变量，NulA的基:{`\(\begin{bmatrix}
-1 \\
2 \\
1 \\
0 \\
0
\end{bmatrix}\)`,`\(\begin{bmatrix}
-1 \\
-3 \\
0 \\
5 \\
1
\end{bmatrix}\)`}

**定义(秩)** A的秩即A的列空间的维数。

**定理14(秩定理)** m x n矩阵A的列空间和行空间的维数相等，这个公共的维数(即A的秩)还等于A的主元位置的个数且满足方程rankA+dim NulA=n

**可逆矩阵定理(续)** 令A是一个n x n矩阵，则下列的命题中的每个均等价于A是可逆矩阵：

1. A的列构成ℝⁿ的一个基
2. ColA = ℝⁿ
3. dim ColA = n
4. rankA = n
5. NulA = {0}
6. dim NulA = 0

###4.7 基的变换
**定理15(坐标变换)** 设B={`\(b_1,...,b_n\)`},C={`\(c_1,...,c_n\)`}是向量空间V的基，则存在一个n x n矩阵`\(P_{C←B}\)`使得`\([x]_C=P_{C←B}[x]_B\)`(4)

`\(P_{C←B}\)`的列是基B中向量的C-坐标向量，即`\(P_{C←B}=[[b_1]_C\ [b_2]_C\ ...\ [b_n]_C]\)`(5)

定理15中矩阵`\(P_{C←B}\)`称为由B到C的坐标变换矩阵。乘以`\(P_{C←B}\)`的运算将B-坐标变为C-坐标。

![26](/assets/2014-01-15-linear-algebra/26.png)

`\(P_{C←B}\)`的列是线性无关的，这是因为它们是线性无关集B的坐标向量，于是得到`\(P_{C←B}\)`是可逆的。将(4)两边乘以`\((P_{C←B})^{-1}\)`，得`\((P_{C←B})^{-1}[x]_C=[x]_B\)`

于是`\((P_{C←B})^{-1}\)`是将C-坐标变为B-坐标的矩阵，即`\((P_{C←B})^{-1}=P_{B←C}\)`

**ℝⁿ中基的变换** 若B={`\(b_1,...,b_n\)`},`\(\xi\)`是ℝⁿ中的标准基{`\(e_1,...,e_n\)`},则`\([b_1]_\varepsilon=b_1\)`,B中其他向量也类似。在此情形下，`\(P_{\xi←B}\)`与4.4节引入的坐标变换矩阵`\(P_B\)`相同，即`\(P_B=[b_1\ b_2\ ...\ b_n]\)`，而为了在ℝⁿ中两个非标准基之间变换坐标，我们需要定理15。

###4.8 差分方程中的应用
**定义(线性差分方程)** 给定数量`\(a_0,...,a_n\)`,`\(a_0\)`和`\(a_n\)`不为零，给定一个信号{`\(z_k\)`},方程`\(a_0y_{k+n}+a_1y_{k+n-1}+...+a_{n-1}y_{k+1}+a_ny_k=z_k\)` 对所有k成立(3) 称为一个n阶线性差分方程。为了简化，`\(a_0\)`通常取1.若`\(z_k\)`是零序列，则方程是齐次的；否则，方程是非齐次的。

**定义(线性差分方程的解集)** 给定`\(a_0,...,a_n\)`,考虑映射T:𝕊→𝕊,将信号{`\(y_k\)`}变换到信号{`\(w_k\)`}，由下式给出`\(w_k=y_{k+n}+a_1y_{k+n-1}+...+a_{a-1}y_{k+1}+a_ny_k\)`。容易验证T是一个线性变换，这蕴涵齐次方程`\(a_0y_{k+n}+a_1y_{k+n-1}+...+a_{n-1}y_{k+1}+a_ny_k=0\)` 对所有k成立的解集是T的核(经T映射到零信号的信号的集合)，进而这个解集是𝕊的一个子空间，任何解的线性组合仍然是解。

**定理16(线性差分方程的惟一解)** 若`\(a_n\)`≠0且{`\(z_k\)`}给定，只要`\(y_0,...,y_{n-1}\)`给定，方程

`\(a_0y_{k+n}+a_1y_{k+n-1}+...+a_{n-1}y_{k+1}+a_ny_k=z_k\)` 对所有k成立(7)

有惟一解。

**定理17(线性差分方程的解向量空间)** n阶齐次线性差分方程

`\(y_{k+n}+a_1y_{k+n-1}+...+a_{n-1}y_{k+1}+a_ny_k=0\)` 对所有k成立(10)

的解集H是一个n维向量空间。

**定义(基础解系)** 描述(10)式的“通解”的标准方法是对所有解构成的子空间给出它的一个基，这样的基称为(10)的`基础解系`。实际上，如果我们能找到n个线性无关的信号满足(10)，它们必然生成这个n维解空间。

**定义(非齐次方程的通解)** 非齐次差分方程

`\(y_{k+n}+a_1y_{k+n-1}+...+a_{n-1}y_{k+1}+a_ny_k=z_k\)` 对所有k成立(11)

的通解能写成(11)的一个特解加上对应其次差分方程(10)的一个基础解系的任意线性组合。这个结果类似于1.5节中关于Ax=b和Ax=0的解集关系，二者是类似的。这两个结果有相同的意义：映射x⟼Ax是线性的，(11)中将信号{`\(y_k\)`}变换成信号{`\(z_k\)`}的映射也是线性的。

###4.9 马尔可夫链中的应用
**定义(马尔可夫链)** 一个具有非负分量且各分量的数值相加等于1的向量称为`概率向量`；`随机矩阵`是各列向量均在概率向量的方阵；`马尔可夫链`是一个概率向量序列`\(x_0,x_1,x_2,...\)`和一个随机矩阵P，使得`\(x_1=Px_0,x_2=Px_1,x_3=Px_3,...\)`,于是马尔可夫链可用一阶差分方程来刻画：

`\(x_{k+1}=Px_k,k=0,1,2,...\)`

当向量在ℝⁿ中的一个马尔可夫链描述一个系统或实验的序列时，`\(x_k\)`中的数值分别列出系统在n个可能状态中的概率，或试验结果是n个可能结果之一的概率。因此，`\(x_k\)`通常称为`状态向量`。

**定义(稳态向量)** 若P是一个随机矩阵，则相对于P的`稳态向量`(或平衡向量)是一个满足Pq=q的概率向量q。可以证明每一个随机矩阵有一个稳态向量。

**定义(正规随机矩阵)** 一个随机矩阵是`正规`的，如果矩阵的某次幂`\(P^k\)`仅包含正的数值。对某个P来说，若`\(P^2\)`中每个数是严格正的，故P是一个正规随机矩阵。

**定理18(马尔可夫链的收敛)** 若P是一个n x n正规的随机矩阵，则P具有惟一稳态向量q。进一步，若`\(x_0\)`是任一个起始状态，且`\(x_{k+1}=Px_k,k=0,1,2,...\)`，则当k→∞时，马尔可夫链{`\(x_k\)`}收敛到q。

