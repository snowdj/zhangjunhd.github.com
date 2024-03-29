---
layout: post
title: "读书笔记-数据挖掘导论之分类"
description: "读书笔记-数据挖掘导论之分类"
category: 大数据
tags: [数据挖掘]
---
{% include JB/setup %}

读[《数据挖掘导论》](http://book.douban.com/subject/5377669/)。

![zen](http://img3.douban.com/lpic/s4548758.jpg)

##第4章 分类：基本概念、决策树与模型评估
###4.1 预备知识
1. `分类`(classification)任务就是通过学习得到一个`目标函数`(target function)f，把每个属性集x映射到一个预先定义的类标号y。
2. 目标函数也称`分类模型`(classification model)。用于以下目的
    * 描述性建模(作为解释性工具，区分不同类中的对象)
    * 预测性建模(预测未知记录的类标号)

###4.2 解决分类问题的一般方法
1. 需要一个`训练集`(training set)，由类标号已知的记录组成。使用训练集建立分类模型后，该模型随后将运用于`检验集`(test set)，检验集由类标号未知的记录组成。![11](/assets/2014-02-08-data-mining/11.png)
2. 分类模型的`性能度量`(performance metric),通过`混淆矩阵`(confusion matrix)![12](/assets/2014-02-08-data-mining/12.png)
    * `\(准确率=\frac{正确预测数}{预测总数}=\frac{f_{11}+f_{00}}{f_{11}+f_{10}+f_{01}+f_{00}}\)`
    * `\(错误率=\frac{错误预测数}{预测总数}=\frac{f_{10}+f_{01}}{f_{11}+f_{10}+f_{01}+f_{00}}\)`

###4.3 决策树归纳
1. 在决策树中，每个`叶结点`(leaf node)都赋予一个类标号。`非终结点`(non-terminal node)包含属性测试条件，用以分开具有不同特性的记录。![13](/assets/2014-02-08-data-mining/13.png)
2. 如何建立决策树
    * `Hunt算法`，设`\(D_t\)`是与结点t相关联的训练记录集，而y=`\(y_1,y_2,...,y_c\)`是类标号，Hunt算法的递归定义如下。
        * 如果`\(D_t\)`中所有记录都属于同一个类`\(y_t\)`，则t是叶结点，用`\(y_t\)`标记。
        * 如果`\(D_t\)`中包含属于多个类的记录，则选择一个`属性测试条件`(attribute test condition)，将记录划分成较小的子集。对于测试条件的每个输出，创建一个子女结点，并根据测试结果将`\(D_t\)`中的记录分布到子女结点中，然后，对于每个子女结点，递归地调用算法。![14](/assets/2014-02-08-data-mining/14.png)![15](/assets/2014-02-08-data-mining/15.png)
    * 决策树归纳的设计问题
        * 如何分裂训练记录？算法必须提供为不同类型的属性指定测试条件的方法，并且提供评估每种测试条件的客观度量。
        * 如何停止分裂过程？需要有结束条件。
3. 表示属性测试条件的方法
    * 二元属性![16](/assets/2014-02-08-data-mining/16.png)
    * 标称属性(多路划分、二元划分)![17](/assets/2014-02-08-data-mining/17.png)
    * 序数属性(不违背序数属性值的有序性)![18](/assets/2014-02-08-data-mining/18.png)
    * 连续属性(可参考2.3.6离散化策略)![19](/assets/2014-02-08-data-mining/19.png)
4. 选择最佳划分的度量
    * 通常是根据划分后子女结点的不纯度性的程度。不纯的程度越低，类分布就约倾斜。
    * 不纯性度量：
        * `\(Entropy(t)=-\sum_{i=0}^{c-1}{p(i|t)log_2p(i|t)}\)`
        * `\(Gini(t)=1-\sum_{i=0}^{c-1}[p(i|t)]^2\)`
        * `\(Classification error(t)=1-max_i[p(i|t)]\)`
        * 其中c是类的个数。
        * ![20](/assets/2014-02-08-data-mining/20.png)
        * ![21](/assets/2014-02-08-data-mining/21.png)
    * 为了确定测试条件的效果，需要比较父结点(划分前)的不纯程度和子女结点(划分后)的不纯程度，差越大，效果越好。
        * 增益`\(\triangle=I(parent)-\sum_{j=1}^k\frac{N(v_j)}{N}I(v_j)\)`
        * 其中，I(.)是给定结点的不纯性度量，N是父结点上的记录总数，k是属性值的个数，`\(N(v_j)\)`是与子女结点`\(v_j\)`相关联的记录个数。
        * 决策树归纳算法通常选择最大化增益`\(\triangle\)`的测试条件(即最小化子女结点的不纯度量的加权平均值)。
        * 当选择熵(entropy)作为公式的不纯性度量时，熵的差就是所谓`信息增益`(information gain)`\(\triangle_{info}\)`
    * 当每个划分相关联的记录太少时，无法做出可靠预测。两种解决方法：
        * 限制测试条件只能是二元属性(CART决策树)
        * `增益率`(gain ratio)来评估划分。`\(Gain ratio=\frac{\triangle_{info}}{Split Info}\)`
            * `\(Split Info=-\sum_{i=1}^kP(v_i)log_2P(v_i)\)`,k是划分总数。
5. 决策树算法
    * 输入是训练记录集E和属性集F。
    * createNode()建立新结点。该结点要么是一个测试条件node.test_cond，要么是一个类标号node.label
    * find_best_split()确定应当选择哪个属性作为划分训练记录的条件。(方法见4.3.4)
    * Classify()为叶结点确定类标号。对于每个叶结点t，令p(i|t)表示该结点上属于类i的训练记录所占的比例，大多数情况，将叶结点指派到具有多数记录的类：`\(label.leaf=argmax_ip(i|t)\)`
    * stopping_cond()通过检查是否所有记录都属于一个类，或者都具有相同的属性值，决定是否终止决策树的增长。
    * ![22](/assets/2014-02-08-data-mining/22.png)
6. 决策树特点
    * 决策树归纳是一种构建分类模型的非参数方法。
    * 找到最佳决策树是NP完全问题。4.3.5是贪心算法，自顶向下的递归划分策略建立决策树。
    * 已开发的构建决策树技术不需要昂贵的计算代价。决策树一旦建立，未知样本分类很快。最坏情况下时间复杂度O(w)，w是树的最大深度。
    * 相对容易解释。
    * 是学习离散函数的典型代表，但不能很好的推广到某些布尔问题。
    * 对于噪声干扰具有相当好的鲁棒性，采用避免`过分拟合`的方法之后有其如此。
    * 冗余属性不会对决策树的准确率造成不利影响。如果一个属性在数据中与它的另一个属性是强相关的，那么它是`冗余`的。
    * 由于大多数的决策树算法都采用自顶向下的递归划分方法，因此沿着树向下，记录会越来越少。在叶结点记录可能太少。对于叶结点代表的类，不能做出具有统计意义的判决，是所谓的`数据碎片`(data fragmentation)问题。解法是设定阈值停止分裂。
    * 子树可能在决策树中重复出现。
    * 两个不同类的相邻之间的边界称作`决策边界`(decision boundary)。由于测试条件只涉及单个属性，因此决策边界是直线(图4-20)。图4-21的边界很难用单个属性的测试条件分类。![23](/assets/2014-02-08-data-mining/23.png)
        * `斜决策树`(oblique decision tree)，允许测试条件涉及多个属性。图4-21的决策条件是x+y<1
        * `归纳构造`(constructive induction)，创建复合属性，代表已有属性的算术或逻辑组合(2.3.5)。

###4.4 模型的过分拟合
分类模型的误差分为两种：`训练误差`(training error)和`泛化误差`(generalization error)。训练误差也称`再代入误差`(resubstitution error)或`表现误差`(apparent error)，是训练记录上误分类样本比例，而泛化误差是模型在未知记录上的期望误差。当决策树很小时，训练和检验误差都很大，这种情况称作`模型拟合不足`(model underfitting)。一旦树的规模变得太大，即时训练误差还在继续降低，但检验误差开始增大，这种现象称作`模型过分拟合`(model pverfitting)。![24](/assets/2014-02-08-data-mining/24.png)

1. 噪声导致的过分拟合
2. 缺乏代表性样本导致的过分拟合
3. 过分拟合与多重比较过程
    * 所谓的`多重比较过程`(multiple comparison procedure)，举例，考虑预测股市。如果股票分析师随机预测，则预测正确的概率为0.5，10次中预测至少正确8次的概率是P=0.0547(J:3次n重伯努利试验，n分别为8，9，10)。
    * 假定现在从50个预测师中选择一个最佳预测者，至少有一人至少预测成功8次的概率是`\(1-(1-P)^{50}=0.9399\)`，可见概率相当高。
    * 设`\(T_0\)`是初始决策树，`\(T_x\)`是插入属性x的内部结点后的决策树。原则上，如果观察的增益`\(\triangle(T_0,T_x)\)`大于预先设定的阈值`\(\alpha\)`，就可以将x添加到树中。
    * 如果属性测试条件很多，并且从候选集{`\(x_1,x_2,...,x_k\)`}中选择最佳属性`\(x_{max}\)`，这其实就是多重比较过程。
    * 当选择属性`\(x_{max}\)`的训练集很小时，这种影响会加剧，因为当训练记录较少时，函数`\(\triangle(T_0,T_x)\)`的方差会很大。这样找到`\(\triangle(T_0,T_x)>\alpha\)`的概率就增大了。(J:?)
4. 泛化误差估计
    * `再代入估计`方法假设训练数据集可以很好地代表整体数据，因而，可以使用训练误差提供对泛化误差的乐观估计。
    * `奥多姆剃刀`(Occam's razor)或`节俭原则`(principle of parsimony)。奥多姆剃刀:给定两个具有相同泛化误差的模型，较简单的模型比较复杂的模型更可取。
    * `悲观误差评估`(pessimistic error estimate)。设n(t)是结点t分类的训练记录数，e(t)是被误分类的记录数。决策树T的悲观误差估计`\(e_g(T)=\frac{\sum_{i=1}^k[e(t_i)+\Omega(T)]}{\sum_{i=1}^kn(t_i)}=\frac{e(T)+\Omega(T)}{N_t}\)`，其中，k是决策树的叶结点数，e(T)是决策树的总训练误差，`\(N_t\)`是训练记录数，`\(\Omega(t_i)\)`是每个结点`\(t_i\)`对应的罚项。
        * 图4-27，如果`\(\Omega(t_i)=0.5\)`，左决策树`\(e_g(T_L)=\frac{4+7·0.5}{24}=0.3125\)`，右决策树`\(e_g(T_R)=\frac{6+4·0.5}{24}=0.3333\)`。对二叉树来说，0.5的罚项意味着只要至少能够改善一个训练记录的分类，结点就应当扩展，因为扩展一个结点等价于总误差增加0.5，代价比犯一个训练错误小。![25](/assets/2014-02-08-data-mining/25.png)
        * 如果`\(\Omega(t_i)=1\)`，左决策树`\(e_g(T_L)=\frac{4+7·1}{24}=0.458\)`，右决策树`\(e_g(T_R)=\frac{6+4·1}{24}=0.417\)`。因此，右边决策树比左边决策树具有更好的悲观错误率。这样，除非能够减少一个以上训练记录的误分类，否则结点不应当扩展。
    * `最小描述长度原则`(minimum description length,MDL)
        * 考虑图4-28，A和B都是已知属性x值的给定记录集。另A知道每个记录的确切类标号，B不知道。B可通过要求A顺序传送类标号而获得每个记录分类。一条消息需要`\(\Theta(n)\)`比特信息，其中n是记录总数。![26](/assets/2014-02-08-data-mining/26.png)
        * 另一种可能是，A决定建立一个分类模型，概括x和y之间的关系。在传送给B之前，模型用压缩编码形式编码。传输代价等于模型代价(Cost(model))和哪些记录被模型错误分类(Cost(data|model))。即Cost(model,data)=Cost(model)+Cost(data|model)
    * 估计统计上界(J:统计理解)
    * 使用确认集。保留2/3的训练集来建立模型，剩余1/3用作误差估计。
5. 处理决策树归纳中的过分拟合
    * 先剪枝(提前终止规则)
    * 后剪枝

###4.5 评估分类器的性能
1. 保持方法(Holdout)。4.4.4的使用确认集提到的，将原始数据划分成两个不相交的集合。
2. 随机二次抽样(random subsampling)。多次重复保持方法。设`\(acc_i\)`是第i次迭代的模型准确率，总准确率`\(acc_{sub}=\sum_{i=1}^k\frac{acc_i}{k}\)`
3. 交叉验证(cross-validation)。每一个记录用于训练的次数相同，且恰好验证一次。`k折交叉验证`，把数据分成相同的k份，在每次运行时，选择其中一份作检验集，其余的全作训练集，该过程重复k次，使得每一份数据都用于检验恰好一次。一种特殊情况，k=N，N是数据集大小，即所谓的`留一方法`(leave-one-out)，每个检验集只有一个记录。
4. 自助法(bootstrap)。前面的方法都假定训练记录采用不放回抽样，因此训练集和检验集都不包含重复记录。此法，训练记录采用有放回抽样。可证明(J:如何证明?)大小为N的自助样本大约包含原始数据中63.2%的记录。`.632自助`(.632 bootstrap)，通过组合每个自助样本的准确率`\(\xi_i\)`和由包含所有标记样本的训练集计算的准确率`\(acc_s\)`计算总准确率`\(acc_{boot}=\frac{1}{b}\sum_{i=1}^b(0.632·\xi_i+0.368·acc_s)\)`

###4.6 比较分类器的方法
(J:统计理解)

##第5章 分类：其他技术







`\(\)`
