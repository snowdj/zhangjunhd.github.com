---
layout: post
title: "读书笔记-数据挖掘导论之探索数据"
description: "读书笔记-数据挖掘导论探索数据"
category: 大数据
tags: [数据挖掘]
---
{% include JB/setup %}

读[《数据挖掘导论》](http://book.douban.com/subject/5377669/)。

![zen](http://img3.douban.com/lpic/s4548758.jpg)

##第2章 数据
###2.1 数据类型
`数据集`可以看作`数据对象`的集合。数据对象有时也叫记录、点、向量、模式、事件、案例、样本、观测和实体。数据对象用一组刻画对象基本特性(如物体质量或事件发生时间)的`属性`描述。属性有时也叫做变量、特性、字段、特征或维。

####2.1.1 属性与度量
1. 什么是属性
    * `属性`(attribute)是对象的性质或特性，它因对象而异，或随时间而变化。
    * `测量标度`(measurement scale)是将数值或符号值与对象的属性相关联的规则(函数)。
2. 属性类型
3. 属性的不同类型
    * 数值的如下性质(操作)常常用来描述属性
        * 向异性:=,≠
        * 序:<,≤,>,≥
        * 加法:+,-
        * 乘法:*,/
    * 给定这些性质，我们可以定义四种属性类型：标称(nominal)、序数(ordinal)、区间(interval)和比率(ratio)。![1](/assets/2014-02-08-data-mining/1.png)
    * 标称和序数属性统称`分类的`(categorical)或`定性的`(qualitative)属性。区间和比率属性，统称为`定量的`(quantitative)或`数值的`(numeric)属性。
    * 属性的类型也可以用不改变属性意义的变换来描述。实际上，心理学家S.Smith Stevens最先用`允许的变换`(permissible transformation)定义了表2-2所示的属性类型。![2](/assets/2014-02-08-data-mining/2.png)
4. 用值的个数描述属性
    * `离散的`(discrete)(`二元属性`(binary attribute))
    * `连续的`(continuous)
5. 非对称的属性(asymmetric attribute)(出现非零值才是重要的)

####2.1.2 数据集的类型
1. 数据集的一般特性
    * `维度`(dimensionality)：数据集的维度是数据集中的对象具有的属性的数目。分析高维度数据时有时会陷入所谓`维灾难`(curse of dimensionality)。正因为如此，数据预处理的一个重要动机就是减少维度，称为`维归约`(dimensionality reduction)。
    * `稀疏性`(sparsity)：稀疏性是一个优点，因为只有非零值才需要存储和处理。
    * `分辨率`(resolution)：如果分辨率太高，模式可能看不出，或者掩埋在噪声中；如果分辨率太低，模式可能不出现。
2. 记录数据
    * 事务数据或购物篮数据
    * 数据矩阵
    * 稀疏数据矩阵(`文档-词矩阵`(document-term matrix))![2-1](/assets/2014-02-08-data-mining/2-1.png)
3. 基于图形的数据
4. 有序数据
    * 时序数据(sequential data)
    * 序列数据(sequence data)
    * 时间序列数据(`时间自相关`(temporal autocorrelation)，即如果两个测量的时间很接近，则这些测量的值通常非常相似)
    * 空间数据(`空间自相关`(spatial autocorrelation)，即物理上靠近的对象趋向于在其他方面也相似)
5. 处理非记录数据

###2.2 数据质量
####2.2.1 测量和数据收集问题
1. 测量误差和数据收集错误
    * `测量误差`(measurement error)是指测量过程中导致的问题。对于连续属性，测量值与实际值的差称为`误差`(error)。
    * `数据收集错误`(data collection error)是指诸如遗漏数据对象或属性值，或不当地包含了其他数据对象等错误。
2. 噪声和伪像
    * `噪声`(noise)是测量误差的随机部分。许多数据挖掘工作关注设计`鲁棒算法`(robust algorithm)，即在噪声干扰下也能产生可以接收的结果。
    * 数据的确定性失真称作`伪像`(artifact)。
3. 精度、偏倚和准确率
    * `精度`(precision)(同一个量的)重复测量值之间的接近程度，值集合的标准差度量。
    * `偏倚`(bias)测量值与被测量值之间的系统的变差，值集合的均值与测出的已知值之间的差度量。
    * `准确率`(accuracy)被测量的测量值与实际值之间的接近度。准确率的一个重要方面是`有效数字`(significant digit)的使用。其目标是仅使用数据精度所能确定的数字位数表示测量或计算结果。
4. `离群点`(outlier)是在某种意义上具有不同于数据集中其他大部分数据对象的特征的数据对象，或是相对于该属性的典型值来说不寻常的属性值。
5. 遗漏值(删除、估计、忽略)
6. 不一致的值(检测，更正)
7. 重复数据(`去重复`(deduplication))

####2.2.2 关于应用的问题

* 时效性
* 相关性(`抽样偏倚`(sampling bias)样本包含的不同类型的对象与它们在总体中的出现情况不成比例)
* 关于数据的知识(描述数据的文档)

###2.3 数据预处理
####2.3.1 聚集

* `聚集`(aggregation)将两个或多个对象合并成单个对象。
* 聚集的动机有多种。首先，数据归约导致的较小数据集需要较少的内存和处理时间。其次，通过高层而不是低层数据视图，聚集起到了范围或标度转换的作用。最后，对象或属性群的行为通常比单个对象或属性的行为更加稳定。

####2.3.2 抽样
1. 抽样方法
    * `简单随机抽样`(simple random sampling)(`无放回抽样`、`有放回抽样`)。
    * `分层抽样`(stratified sampling)：预先指定组的抽样。
2. `渐进抽样`(progressive sampling)：从一个小样本开始，然后增加样本容量直至足够容量的样本。

####2.3.3 维归约
1. 维灾难。随着维度增加，数据在它所占据的空间中越来越稀疏。对于分类，这可能意味着没有足够的数据对象来创建模型，将所有可能的对象可靠地指派到一个类。对于聚类，点之间的密度和距离的定义失去了意义。
2. 维归约的线性代数技术。将数据由高维度投影到低维度空间，特别对于连续数据。`主成分分析`(Principal Components Analysis,PCA)是一种用于连续属性的线性代数技术，它找出新的属性(主成分)，这些属性是原属性的线性组合，是相互`正交的`(orthogonal)，并且捕获了数据的最大变差。`奇异值分解`(Singular Value Decomposition,SVD)是一种线性代数技术，也用于维归约。

####2.3.4 特征子集选择
1. 特征子集选择体系结构![3](/assets/2014-02-08-data-mining/3.png)
2. 特征加权

####2.3.5 特征创建
1. 特征提取:由原始数据创建新的特征集称作`特征提取`(feature extraction)。
2. 映射数据到新的空间(例如`傅里叶变换`(Fourier transform))
3. 特征构造(例如密度=质量/体积)

####2.3.6 离散化和二元化
1. `二元化`(binarization)![4](/assets/2014-02-08-data-mining/4.png)![5](/assets/2014-02-08-data-mining/5.png)
2. 连续属性`离散化`(discretization)
    * 两个子任务：决定需要多少个分类值(指定n-1个`分割点`(split point))；确定如何将连续属性值映射到这些分类值。
    * `非监督离散化`(unsupervised)：不使用类信息(等宽、等频率、等深、K均值)。![6](/assets/2014-02-08-data-mining/6.png)
    * `监督离散化`(supervised)：基于`熵`(entropy)的方法。
        * 设k是不同的类标号数，`\(m_i\)`是某划分的第i个区间中值的个数，而`\(m_{ij}\)`是区间i中类j的值的个数。第i个区间的熵`\(e_i=-\sum_{j=1}^k{p_{ij}log_2 p_{ij}}\)`，其中`\(p_{ij}=\frac{m_{ij}}{m_i}\)`是第i个区间中类j的概率。该划分的总熵e是每个区间的熵的加权平均，即`\(e=\sum_{i=1}^n{w_ie_i}\)`，其中，m是值的个数。`\(w_i=\frac{m_i}{m}\)`是第i个区间的值的比例，而n是区间个数。
        * 直观上，区间的熵是区间纯度的度量。如果一个区间只包含一个类的值(该区间非常纯)，则其熵为0并且不影响总熵。如果一个区间中的值类出现的频率相等(该区间尽可能不纯)，则其熵值最大。
        * 一个划分的方法：开始，将初始值切分成两部分，让两个结果区间产生最小熵。该技术只需要把每个值看作可能的分割点即可，因为假定区间包含有序值的集合。然后，取一个区间，通常选取具有最大熵的区间，重复此分割过程，直到区间的个数达到用户指定的个数。

####2.3.7 变量变换
* `变量变换`(variable transformation)是指用于变量的所有值的变换。
    * 简单函数
    * `标准化`(standardization)或`规范化`(normalization)

###2.4 相似性和相异性的度量
####2.4.1 概念
1. `邻近度`(proximity)表示相似性或相异性。
2. 两个对象之间的`相似度`(similarity)的非正式定义是这两个对象相似程度的数值度量。两个对象之间的`相异度`(dissimilarity)是这两个对象差异程度的数值度量。对象约类似，它们的相异度就越低。`距离`(distance)用作相异度的同义词。
3. 通常使用变换把相似度转换成相异度或相反，或者把邻近度变换到一个特定区间，如[0,1]。

####2.4.2 简单属性的相似度和相异度
![7](/assets/2014-02-08-data-mining/7.png)

####2.4.3 数据对象之间的相异度
1. 多维空间中两个点x和y之间的`欧几里得距离`(Euclidean distance)：`\(d(x,y)=\sqrt{\sum_{k=1}^n{(x_k-y_k)^2}}\)`,其中n表示维数，而`\(x_k\)`和`\(y_k\)`分别是x和y的第k个属性值(分量)。
2. 欧几里得距离可以由`闵可夫斯基距离`(Minkowski distance)推广`\(d(x,y)=(\sum_{k=1}^n{|x_k-y_k|^r})^{1/r}\)`，其中r是参数。
    * r=1，城市街区(也称曼哈顿、出租车、L1范数)距离。一个常见的例子是`海明距离`(Hamming distance)，它是两个具有二元属性的对象(即两个二元向量)之间不同的二进制位个数。
    * r=2，欧几里得距离(L2范数)。
    * r=∞，上确界(Lmax或L∞范数)距离。这是对象属性之间的最大距离。更正式地，L∞距离定义：`\(d(x,y)=\lim_{r \to \infty}(\sum_{k=1}^n{|x_k-y_k|^r})^{1/r}\)`
3. 距离的性质
    * 非负性。对所有x和y，d(x,y)≥0,当且仅当x=y时d(x,y)=0
    * 对称性。对所有x和y，d(x,y)=d(y,x)
    * 三角不等式。对所有x，y和z，d(x,z)≤d(x,y) + d(y,z)
    * 满足以上三个性质的测度称为`度量`(metric)。

####2.4.4 数据对象之间的相似度
对于相似度，三角不等式通常不成立。但对称性和非负性通常成立。如果s(x,y)是数据点x和y之间的相似度：

* 仅当x=y时s(x,y)=1,0≤s≤1
* 对于所有x和y，s(x,y)=s(y,x)    

####2.4.5 邻近性度量
1. 二元数据的相似性度量
    * 两个仅包含二元属性的对象之间的相似性度量也称为`相似系数`(similarity coefficient)，并且通常在0和1之间取值，值1表明两个对象完全相似，值0表明对象一点也不相似。
    * 设x和y是两个对象，都由n个二元属性组成。这样的两个对象(即两个二元向量)的比较可生成如下四个量(频率)：
        * `\(f_{00}\)`=x取0并且y取0的属性个数
        * `\(f_{01}\)`=x取0并且y取1的属性个数
        * `\(f_{10}\)`=x取1并且y取0的属性个数
        * `\(f_{11}\)`=x取1并且y取1的属性个数
    * `简单匹配系数`(Simple Matching Coefficient,SMC):`\(SMC=\frac{值匹配的属性个数}{属性个数}=\frac{f_{11}+f_{00}}{f_{01}+f_{10}+f_{11}+f_{00}}\)`
    * `Jaccard系数`(Jaccard Coefficient):`\(J=\frac{匹配的个数}{不涉及0-0匹配的属性个数}=\frac{f_{11}}{f_{01}+f_{10}+f_{11}}\)`
2. 余弦相似度(cosine similarity)
    * 是文档相似度最常用的度量之一。如果x和y是两个文档向量，则`\(cos(x,y)=\frac{x·y}{\lVert x \rVert\lVert y \rVert}\)`
    * 另一种形式是`\(cos(x,y)=\frac{x·y}{\lVert x \rVert\lVert y \rVert}=x'·y'\)`，其中`\(x'=\frac{x}{\lVert x \rVert}\)`，而`\(y'=\frac{y}{\lVert y \rVert}\)`。x和y被它们的长度除，将它们规范化成具有长度1.这意味着在计算相似度时，余弦相似度不考虑两个对象的量值(当量值是重要的时，欧几里得距离可能是一种更好的选择)。
3. 广义Jaccard系数
    * 可以用于文档数据，并在二元属性情况下归约为Jaccard系数，又称`Tanimoto系数`。`\(EJ(x,y)=\frac{x·y}{\lVert x \rVert^2\lVert y \rVert^2-x·y}\)`
4. 相关性
    * 两个具有二元变量或连续变量的数据对象之间的相关性是对象属性之间线性联系的度量。两个数据对象x和y之间的`皮尔森相关系数`(Pearson's correlation):`\(corr(x,y)=\frac{s_{xy}}{s_xs_y}\)`
        * 协方差`\(s_{xy}=\frac{1}{n-1}\sum_{k=1}^n{(x_k-\bar{x})(y_k-\bar{y})}\)`
        * 标准差`\(s_x=\sqrt{\frac{1}{n-1}\sum_{k=1}^n{(x_k-\bar{x})^2}}\)`
        * 标准差`\(s_y=\sqrt{\frac{1}{n-1}\sum_{k=1}^n{(y_k-\bar{y})^2}}\)`
    * 相关度总是在-1到1之间取值。相关度为1(-1)意味着x和y具有完全正(负)相关性。如果相关度为0，则两个数据对象的属性之间不存在线性关系。然而，仍然可能存在非线性关系。
5. Bregman散度
    * 一族具有共同性质的邻近函数。
    * 是损失或失真函数。损失函数的目的是度量用x近似y导致的失真或损失。x和y越类似，失真或损失就越小，因而Bregman散度可以用作相异性函数。
    * 定义：给定一个严格凸函数`\(\phi\)`，由该函数生成的Bregman散度(损失函数)：`\(D(x,y)=\phi(x)-\phi(y)-<\nabla\phi(y),(x-y)>\)`，其中`\(\nabla\phi(y)\)`是在y上计算的`\(\phi\)`的梯度，x-y是x与y的向量差，而`\(<\nabla\phi(y),(x-y)>\)`是`\(\nabla\phi(y)\)`和(x-y)的内积。
    * D(x,y)可以写成`\(D(x,y)=\phi(y)-L(x)\)`，其中`\(L(x)=\phi(x)+\phi(y)-<\nabla\phi(y),(x-y)>\)`代表在y上正切于函数`\(\phi\)`的平面方程。

####2.4.6 邻近度计算问题
1. 距离度量的标准化和相关性。当属性相关、具有不同的值域(不同的方差)、并且数据分布近似于高斯分布时，欧几里得距离的推广，`Mahalanobis距离`是有用的。两个对象(向量)x和y之间的Mahalanobis距离:`\(mahalanobis(x,y)=(x-y)\sum^{-1}(x-y)^T\)`，其中`\(\sum^{-1}\)`是数据协方差矩阵的逆。
2. 组合异种属性的相似度。
    * 对于第k个属性，计算相似度`\(s_k(x,y)\)`，在区间[0,1]中。
    * 对于第k个属性，定义一个指示变量`\(\delta_k\)`：
        * `\(\delta_k=0\)`，如果第k个属性是非对称属性，并且两个对象在该属性上的值都是0，或者如果一个对象的第k个属性具有遗漏值
        * `\(\delta_k=1\)`，否则
    * 使用公式计算两个对象之间的总相似度：`\(similarity(x,y)=\frac{\sum_{k=1}^n\delta_ks_k(x,y)}{\sum_{k=1}^n\delta_k}\)`
3. 使用权值
    * 如果权`\(w_k\)`的和为1，`\(similarity(x,y)=\frac{\sum_{k=1}^nw_k\delta_ks_k(x,y)}{\sum_{k=1}^n\delta_k}\)`
    * 闵可夫斯基距离修改为`\(d(x,y)=(\sum_{k=1}^n{w_k|x_k-y_k|^r})^{1/r}\)`

##第3章 探索数据
###3.2 汇总数据
1. 给定一个在{`\(v_1,v_2,...,v_k\)`}上取值的分类属性x和m个对象的集合。值`\(v_i\)`的`频率`:`\(frequency(v_i)=\frac{具有属性值v_i的对象数}{m}\)`，分类属性的`众数`(mode)是具有最高频率的值。![8](/assets/2014-02-08-data-mining/8.png)
2. 对于有序数据，考虑值集的`百分位数`(percentile)，给定一个有序的或连续的属性x和0-100之间的数p，第p个百分位数`\(x_p\)`是一个x值，使得x的p%的观测值小于`\(x_p\)`。![9](/assets/2014-02-08-data-mining/9.png)
3. 对于连续数据，最广泛的汇总统计是`均值`(mean)和`中位数`(median)。有时使用`截断均值`(trimmed mean)，指定0和100之间的百分位数p，丢弃高端和低端(p/2)%的数据，再计算均值。![10](/assets/2014-02-08-data-mining/10.png)
4. 连续数据的散布度量：`极差`(range)和`方差`(variance)、`标准差`(standard variance)。
    * `绝对平均偏差`(absolute average deviation,AAD),`\(AAD(x)=\frac{\sum_{i=1}^m{\lVert x_i-\bar{x} \rVert}}{m}\)`
    * `中位数绝对偏差`(median absolute deviation,MAD),`\(MAD(x)=median(\{\lVert x_1-\bar{x} \rVert,...,\lVert x_m-\bar{x} \rVert\})\)`
    * `四分位数极差`(interquartile range,IQR),`\(IQR(x)=x_{75\%}-x_{25\%}\)`
5. 多元汇总统计
    * 包含多个属性的数据(多元数据)的位置度量可以通过分别计算每个属性的均值或中位数得到：`\(\bar{x}=(\bar{x_1},...,\bar{x_n})\)`
    * 对于具有连续变量的数据，数据的散布可用`协方差矩阵`(covariance matrix)S表示，如果`\(x_i\)`和`\(x_j\)`分别是第i个和第j个属性，则
        * `\(s_{ij}=covariance(x_i,x_j)\)`,矩阵S的第ij个元素`\(s_{ij}\)`是数据的第i个和第j个属性的协方差。
        * `\(covariance(x_i,x_j)=\frac{\sum_{k=1}^m{(x_{ki}-\bar{x_i})(x_{kj}-\bar{x_j})}}{m-1}\)`,其中`\(x_{ki}\)`和`\(x_{kj}\)`分别是第k个对象的第i个和第j个属性的值。注意，`\(covariance(x_i,x_i)=variance(x_i)\)`，即协方差矩阵的对角线上是属性的方差。
    * `相关矩阵`(correlation matrix)R的第ij个元素是数据的第i个和第j个属性之间的相关性。如果`\(x_i\)`和`\(x_j\)`分别是第i个和第j个属性，则
        * `\(r_{ij}=correlation(x_i,x_j)=\frac{covariance(x_i,x_j}{s_is_j}\)`,其中`\(s_i\)`和`\(s_j\)`分别是`\(x_i\)`和`\(x_j\)`的方差。R的对角线上的元素是`\(correlation(x_i,x_j)=1\)`。

