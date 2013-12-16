---
layout: post
title: "Apache Hadoop-Related Projects Design Architecture2"
description: ""
category: 云计算
tags: [Hadoop, Hcatalog, Whirr, Mahout]
---
{% include JB/setup %}

##Apache Hadoop-Related Projects List

- [Ambari][1] : Deployment, configuration and monitoring, see [part1][20]
- [Flume][2]:Collection and import of log and event data, see [part1][20]
- [MapReduce][4]: Parallel computation on server clusters, see [part1][20]
- [HDFS][5] Distributed redundant filesystem for Hadoop, see [part1][20]
- [HBase][3]:Column-oriented database scaling to billions of rows, see [part2][21]
- [Zookeeper][6]:Configuration management and coordination, see [part3][22]
- [Pig][7]:High-level programming language for Hadoop computations, see [part4][23]
- [Hive][8]: Data warehouse with SQL-like access, see [part7][25]
- [Oozie][9]: Orchestration and workflow management, see [part6][24]
- [Sqoop][10]: Imports data from relational databases, see [part7][25]
- [HCatalog][11]: Schema and data type sharing over Pig, Hive and MapReduce
- [Whirr][12]: Cloud-agnostic deployment of clusters
- [Mahout][13]: Library of machine learning and data mining algorithms

<!--break-->

## 1 HCatalog
HCatalog is a table and storage management layer for Hadoop that enables users with different data processing tools – Pig, MapReduce, and Hive – to more easily read and write data on the grid. HCatalog’s __table abstraction presents__ users with a relational view of data in the Hadoop distributed file system (HDFS) and ensures that users need not worry about where or in what format their data is stored – RCFile format, text files, or SequenceFiles.  
![HCatalog](http://incubator.apache.org/hcatalog/docs/r0.5.0/images/hcat-product.jpg)

__Data Flow Example__  
__First__ Joe in data acquisition uses distcp to get data onto the grid.

    hadoop distcp file:///file.dat hdfs://data/rawevents/20100819/data

    hcat "alter table rawevents add partition (ds='20100819') location 'hdfs://data/
    rawevents/20100819/data'"

__Second__ Sally in data processing uses Pig to cleanse and prepare the data.

Without HCatalog, Sally must be manually informed by Joe when data is available, or poll on HDFS.

    A = load '/data/rawevents/20100819/data' as (alpha:int, beta:chararray, …);
    B = filter A by bot_finder(zeta) = 0;
    …
    store Z into 'data/processedevents/20100819/data';

With HCatalog, HCatalog will send a JMS message that data is available. The Pig job can then be started.

    A = load 'rawevents' using HCatLoader();
    B = filter A by date = '20100819' and by bot_finder(zeta) = 0;
    …
    store Z into 'processedevents' using HCatStorer("date=20100819");

__Third__ Robert in client management uses Hive to analyze his clients' results.

Without HCatalog, Robert must alter the table to add the required partition.

    alter table processedevents add partition 20100819 hdfs://data/processedevents/
    20100819/data

    select advertiser_id, count(clicks)
    from processedevents
    where date = '20100819' 
    group by advertiser_id;

With HCatalog, Robert does not need to modify the table structure.

    select advertiser_id, count(clicks)
    from processedevents
    where date = ‘20100819’ 
    group by advertiser_id;

## 2 Whirr
Apache Whirr is a set of libraries for running cloud services.

__Steps in writing a Whirr service__  

   * Identify service roles
   * Write a ClusterActionHandler for each role
   * Write scripts that run on cloud nodes
   * Package and install
   * Run

__Example:Flume Service__(a service for collecting and moving large amounts of data)  

* Identify service roles
  * Flume Master
     * The head node, for coordination
     * Whirr role name:flumedemo-master
  * Flume Node
     * Runs agents (generate logs) or collectors (aggregate logs)
     * Whirr role name:flumedemo-node  
![flume](/assets/2013-03-06-apache-related-projects2/flume.png)

* Write a ClusterActionHandler for each role

{% highlight java %}  
public class FlumeNodeHandler extends ClusterActionHandlerSupport {
    public static final String ROLE = "flumedemo-node";
    @Override 
    public String getRole() { return ROLE; }
    @Override
    protected void beforeBootstrap(ClusterActionEvent event) throws
        IOException, InterruptedException {
        addStatement(event, call("install_java"));
        addStatement(event, call("install_flumedemo"));
    }
    // more ...
}
{% endhighlight %}

 * Write scripts that run on cloud nodes
   * install_java is built in
   * Other functions are specified in individual files

{% highlight java %}  
function install_flumedemo() {
    curl -O http://cloud.github.com/downloads/cloudera/flume/flume-0.9.3.tar.gz
    tar -C /usr/local/ -zxf flume-0.9.3.tar.gz
    echo "export FLUME_CONF_DIR=/usr/local/flume-0.9.3/conf" >> /etc/profile
}
{% endhighlight %}

* Package and install
  * Each service is a self-contained JAR

        functions/configure_flumedemo_master.sh
        functions/configure_flumedemo_node.sh functions/install_flumedemo.sh
        META-INF/services/org.apache.whirr.service.ClusterActionHandler
        org/apache/whirr/service/example/FlumeMasterHandler.class
        org/apache/whirr/service/example/FlumeNodeHandler.class
* Run
  * Create a cluster spec file

        whirr.cluster-name=flumedemo
        whirr.instance-templates=1 flumedemo-master,1 flumedemo-node
        whirr.provider=aws-ec2
        whirr.identity=${env:AWS_ACCESS_KEY_ID}
        whirr.credential=${env:AWS_SECRET_ACCESS_KEY}

  * Then launch from the CLI

        %whirr launch-cluster --config flumedemo.properties
  
  * or Java

{% highlight java %}  
Configuration conf = new PropertiesConfiguration("flumedemo.properties");

ClusterSpec spec = new ClusterSpec(conf);
Service s = new Service();
Cluster cluster = s.launchCluster(spec);
  
// interact with cluster
s.destroyCluster(spec);
{% endhighlight %}

* Orchestration
  * Instance templates are acted on independently in parallel
  * Bootstrap phase
    * start 1 instance for the flumedemo-master role and run its bootstrap script
    * start 1 instance for the flumedemo-node role and run its bootstrap script
  * Configure phase
    * run the configure script on the flumedemo-masterinstance
    * run the configure script on the flumedemo-nodeinstance
  * Note there is a barrier between the two phases, so nodes can get the master address in the configure phase

## 3 Mahout
__What is Apache Mahout?__  
Machine learning and data mining framework for classification, clustering and recommendation.

__Applications__

1. Recommendation features(find items a user might like / find items that appear together)  
![recommend](/assets/2013-03-06-apache-related-projects2/recommend.png)

2. Clustering of information(group items that are topically related)  
![cluster](/assets/2013-03-06-apache-related-projects2/cluster.png)

3. Classification(learn to assign categories to documents)  
![classification](/assets/2013-03-06-apache-related-projects2/classification.png)

[1]:http://incubator.apache.org/ambari/ "Apache Ambari"
[2]:http://flume.apache.org/ "Apache Flume"
[3]:http://hbase.apache.org/ "Apache Hbase"
[4]:http://wiki.apache.org/hadoop/MapReduce "Apache MapReduce"
[5]:http://hadoop.apache.org/docs/r1.1.1/hdfs_desig5.html "HDFS Architecture Guide"
[6]:http://zookeeper.apache.org/ "Apache Zookeeper"
[7]:http://pig.apache.org/ "Apache Pig"
[8]:http://hive.apache.org/ "Apache Hive"
[9]:http://oozie.apache.org/ "Apache Oozie"
[10]:http://sqoop.apache.org/ "Apache Sqoop"
[11]:http://incubator.apache.org/hcatalog/ "Apache Hcatalog"
[12]:http://whirr.apache.org/ "Apache whirr"
[13]:http://mahout.apache.org/ "Apache Mahout"

[20]:http://zhangjunhd.github.com/2013/02/24/apache-related-projects/
[21]:http://zhangjunhd.github.com/2013/02/25/apache-hbase/
[22]:http://zhangjunhd.github.com/2013/03/01/zookeeper/
[23]:http://zhangjunhd.github.com/2013/03/03/pig/
[24]:http://zhangjunhd.github.com/2013/03/04/oozie/
[25]:http://zhangjunhd.github.com/2013/03/04/hive/