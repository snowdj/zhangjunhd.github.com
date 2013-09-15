---
layout: post
title: "CAP,ACID,BASE"
description: ""
category: tech
tags: [CAP, BASE, ACID, queue, MVCC, 2PC, transaction, paxos, replication]
---
{% include JB/setup %}
CAP, BASE, ACID 相关文章 review 1-10

<!--break-->

####1 [【分布式系统工程实现】CAP理论及系统一致性][1]

1. 对A的描述通常需要明确时间标准；在某些pattern下C根本无法解决；P的场景要明确，一台机器，一个机架还是一个机房，所面临的问题可能大不相同 
2. 工程上可衡量的C：Harvest，可衡量的A：Yield
3. 对于存在Mater节点的系统一般是最终一致性系统；对于去中心化的P2P系统一般依赖冲突合并的一致性。意思是大家一般在C上面做文章。

####2 [Brewer’s CAP Theorem][2]

1. 分布式的一致性和ACID的C区别：ACID的C是指违反了某些预设的约束preset constraints就不能被持久化（persisted）。分布式的C是指：不允许同一数据有不同的值。就这一概念而言，在ACID里面是通过隔离性（Isolation）来保证数据的一致性。
2. 什么叫partition tolerance？除非把所有数据或逻辑放在一个物理节点，否则就会存在网络分区。容忍是啥意思？除非整个网络出现故障，否则系统应该继续对外正常响应。(此时应该抉择是舍弃A，暂时不提供服务，还是舍弃C，最终一致性)
3. 关于scale，业务决策决定架构设计。

####3 [Base: An acid alternative][3]

1. scaling 分两种：1.`vertical scaling`：把一台机器做强；2.`horizontal scaling`：把数据切片放到不同机器上。
2. horizontal scaling分两种：按数据概念(表)将数据划分；当单表数据很大时，可以sharding。![1](/assets/2013-09-15-capacidbase/1.png)
3. 数据切片后，为了保证ACID，会引入`2PC`(2PC (two-phase commit) for providing ACID guarantees across multiple database instances.)
4. 另外一种策略是`BASE`。Where ACID is pessimistic and forces consistency at the end of every operation, BASE is optimistic and accepts that the database consistency will be in a state of flux.
5. 引入Queue来实现BASE，避免2PC

        Begin transaction
          Insert into transaction(id, seller_id, buyer_id, amount);
          Queue message “update user(“seller”, seller_id, amount)”;
          Queue message “update user(“buyer”, buyer_id, amount)”;
        End transaction

        For each message in queue
          Peek message
          Begin transaction
            Select count(*) as processed where trans_id=message.trans_id
              and balance=message.balance 
              and user_id=message.user_id
            If processed == 0
              If message.balance == “seller”
                Update user set amt_sold=amt_sold + message.amount where id=message.id;
              Else
                Update user set amt_bought=amt_bought + message.amount where id=message.id;
            End if
            Insert into updates_applied (message.trans_id, message.balance, message.user_id);
            End if
          End transaction

          If transaction successful
            Remove message from queue //这里确保所有操作必须是idempotence
          End if
        End for

####4 [多版本并发控制(MVCC)在分布式系统中的应用][4]

1. `MVCC`是一种后验性的，读不阻塞写，写也不阻塞读，等到提交的时候才检验是否有冲突，由于没有锁，所以读写不会相互阻塞，从而大大提升了并发性能。
2. MVCC的一种简单实现是基于`CAS`（Compare-and-swap）思想的有条件更新（Conditional Update）。

####5 [Life beyond Distributed Transactions: an Apostate’s Opinion][5]

1. 定义了一个新的概念：`Entity`。
   1. 所有的Atomic Transaction不能跨Entity。
   2. Entity之间可以通过`Message`沟通。
   3. 两个Entity之间的关系集合叫做`Activity`。
   4. 为了做到idempotent(Message可以retry),接收方Entity需要记录之前收到过的Message。
2. 数据Partition的单位是Entity。所以Entity就是Atomic的边界。无法跨Entity做Transaction是因为和你相邻的Entity可能在别的机器上。
3. 跨Entity的Transaction其实就是最终一致性了：如果把中间的Queue变成协调者，不就是2PC了。想想文档3。![2](/assets/2013-09-15-capacidbase/2.png)
4. 关于Activity![3](/assets/2013-09-15-capacidbase/3.png)
5. 由于没有跨Entity的Transaction，当某Entity需要和另一个Entity达成agreement，它就必须要求对方接收某种不确定性。具体实现是：我发一条message要求commitment，但是在此期间也可能被cancel。这个叫`tentative operation`。解决的办法是通过Workflow来达成一致。

####6 [Paxos Made Simple][6]

1. 第一阶段：proposer 提议一个v给所有的acceptor，acceptor只接受比当前已接受v更高的v。第二阶段：proposer提议一个它认为最大可被通过的v，acceptor批准v，除非刚才第一阶段接受了更大的v。![4](/assets/2013-09-15-capacidbase/4.jpg)

####7 [Scaling Out][7]

1. 建第二个数据中心的目的:a.缩短访问latency;b.异地容灾
2. cache不一致的问题
   1. 更新主数据库的记录，同时删除主备的memcache，并触发异步replication。
   2. 此时如果有人访问备集群，由于cache未命中，直接访问备数据库，得到脏数据，并在备memcache中cache住。
   3. 解法：修改SQL表达式，指明脏cache，这样异步replication触发后，在更新完备数据库后，也会清理cache。
3. 存在一致性问题
   1. 当我在主region更新记录，可能此时还没有replicate过去，如果此时read的请求被分流到备的region，就会发现update未生效，导致用户困惑。所以这里就涉及了如何引导用户流量的问题。
   2. workaround：通过cookie，在发生写操作的之后20秒，强制引导流量到修改发生的region。
4. 无解的问题：写请求只能发生在一地。不然会出现一致性问题。

####8 [Design and Evaluation of a Continuous Consistency Model for Replicated Services][8]

主要介绍一个算法用于衡量Consistency以及维持之。

1. 从Strong Consistency到Optimistic Consistency设计三个系统因素的变化。Probability of Inconsistent Access、Availability和Performance。![5](/assets/2013-09-15-capacidbase/5.png)
2. 衡量Consistency的三个标准：`Numerical Error`, `Order Error`和 `Staleness`
3. 算法实现：使用`Anti-Entropy`来实现各Replica之间的Consistency。注意它必须用到Leslie Lamport的逻辑时钟。
   1. consistency = (Numerical Error, Order Error, Staleness)
   2. Staleness：逻辑时钟有多久没有sync了。对于Replica A，它发生操作的最近时钟是24，它和Replica B sync到5；对于replica B，它发生操作的最近时钟是17，因为没有和A sync过，所以sync到0.
   3. Numerical Error：本地副本的值相对于Final Image的值的差。对于Replica A，它差了一条redo-log(16,B那条，值为1)；对于Replica B，它差了三条redo-log(10,A/14,A/23,A，总值为5)
   4. Order Error：对于Replica A，它有3条tentative write，对于Replica B，它有2条
   
![6](/assets/2013-09-15-capacidbase/6.png)
 
####9 [Harvest, Yield, and Scalable Tolerant Systems][9]

针对CAP，必须P和A的情况下，细化了C，这里提到两个概念：

* yield, which is the probability of completing a request. 即一段时间内统计得到的访问请求的完成率
* harvest, which measures the fraction of the data reflected in the response, i.e. the completeness of the answer to the query.对于每个请求，返回的完成度

为了提高yield，有两种方法：

* 降低harvest来确保高yield。比如一个分布式系统，从100个节点上查询并返回数据，当其中一个节点失败时，可以正常返回，但是harvest缩减为原来的99%
* 大系统设计必须解耦成多个子系统，且各个子系统之间是正交的。这样，当某个子系统出现问题时，仅仅是它负责的功能点出现问题，这样不至于整体不服务。这就要求，各个子系统自个管理自己的状态，且它们之间最好不要有强一致性依赖。这种设计(orthogonal mechanisms)是区别于layered mechanism设计的。它的优势显而易见

####10 [Crash-Only Software][10]

1. A crash-only system : stop=crash and start=recover
2. Why Crash-Only Design ?
   1. A crash-only system makes it affordable to transform every detected failure into component-level crashes; this leads to a simple fault model, and components only need to know how to recover from one type of failure.
   2. Moreover, a system in which crash-recovery is cheap allows us to micro-reboot suspect components before they fail.
   3. Finally, if we admit that most failures can be recovered by micro-rebooting, crashing every suspicious component could shorten the fault detection and diagnosis time—a period that sometimes lasts longer than repair itself.
3. Intra-Component Properties. All important non-volatile state is managed by dedicated state stores, leaving applications with just program logic. We do not advocate that every application have its own set of state stores. Instead, we believe Internet systems will standardize on a small number of state store types:
   1. ACID stores (e.g., databases for customer and transaction data), 
   2. non-transactional persistent stores (e.g., DeStor, a crash-only system specialized in handling non-transactional persistent data, like user profiles), 
   3. session state stores (e.g., SSM for shopping carts), 
   4. simple read-only stores (e.g., file system appliances for static HTML and images), and 
   5. soft state stores (e.g., web caches).
4. Inter-Component Properties
   1. Components have externally enforced boundaries that provide strong fault containment.
   2. All interactions between components have a timeout.
   3. All resources are leased, rather than permanently allocated, to ensure that resources are not coupled to the components using them.
   4. Requests are entirely self-describing, by making the state and context needed for their processing explicit.


[1]: http://www.nosqlnotes.net/archives/21
[2]: http://code.alibabatech.com/blog/dev_related_728/brewers-cap-theorem.html
[3]: http://www.baidu.com/link?url=HeHZv-r4p8SY7DDZIxJl2IrOn9oz9B_Dm6YtsI6IW4yD9VAHxjtk8Y2C5fhbH1FdG_NzrvGDne4vc03E53dZvq
[4]: http://coolshell.cn/articles/6790.html
[5]: http://www.ics.uci.edu/~cs223/papers/cidr07p15.pdf
[6]: http://research.microsoft.com/en-us/um/people/lamport/pubs/paxos-simple.pdf
[7]: http://www.facebook.com/note.php?note_id=23844338919&id=9445547199
[8]: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.34.7743&rep=rep1&type=pdf
[9]: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.24.3690&rep=rep1&type=pdf
[10]: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.3.9953