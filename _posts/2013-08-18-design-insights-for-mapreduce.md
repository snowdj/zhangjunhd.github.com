---
layout: post
title: "Design Insights for MapReduce from Diverse Production Workloads"
description: ""
category: tech
tags: [paper, MapReduce]
---
{% include JB/setup %}
paper review:[Design Insights for MapReduce from Diverse Production Workloads
](http://www.eecs.berkeley.edu/Pubs/TechRpts/2012/EECS-2012-17.pdf)

<!--break-->
##1 Introduction
Our contributions are:


* Analysis of seven MapReduce production workloads from five industries totaling over two million jobs,

* Derivation of design and operational insights, and

* Methodology of analysis and the deployment of a public workload repository with workload replay tools.
![mr1](/assets/2013-08-18-design-insights-for-mapreduce/mr1.png)

##2 Background
We analyze seven workloads from various Hadoop deployments. All seven come from clusters that support business critical processes. Five are workloads from Cloudera’s enterprise customers in e-commerce, telecommunications, media, and retail. Two others are Facebook workloads on the same cluster across two different years.

![mr2](/assets/2013-08-18-design-insights-for-mapreduce/mr2.png)

##3 Data Access Patterns
####3.1 Aggregate input/shuffle/output sizes
Figure 1 shows the aggregate input, shuffle, and output bytes. These statistics reflect I/O bytes seen from the MapReduce API.

![mr3](/assets/2013-08-18-design-insights-for-mapreduce/mr3.png)

* The aggregate traffic looks like N-to-N shuffle traffic for all three stages. Under these assumptions, recent research correctly optimize for N-to-N traffic patterns for datacenter networks [7, 8, 25, 20].
* The default behavior in Hadoop is to attempt to place map tasks for increased locality of input data. Hadoop also tries to combine or compress map outputs and optimize placement for reduce tasks to increase rack locality for shuffle. By default, for every API output block, HDFS stores one copy locally, another within-rack, and a third cross-rack. Under these assumptions, data movement would be dominated by input reads, with read locality optimizations being worthwhile [41]. 
* Facebook uses HDFS RAID, which employs ReedSolomon erasure codes to tolerate 4 missing blocks with 1.4× storage cost [15, 37]. Parity blocks are placed in a non-random fashion. Combined with efforts to improve locality, the design creates another environment in which we need to reassess optimization priority between MapReduce API input, shuffle, and output.

####3.2 Per-job data sizes
Figure 2 shows the distribution of per-job input, shuffle, and output data sizes for each workload. Most jobs have input, shuffle, and output sizes in the MB to GB range. Thus, benchmarks of TB and above captures only a narrow set of input, shuffle, and output patterns.

![mr4](/assets/2013-08-18-design-insights-for-mapreduce/mr4.png)

####3.3 Access frequency and intervals
Figure 3 shows the distribution of HDFS file access frequency, sorted by rank according to non-decreasing frequency. Note that the distributions are graphed on log-log axes, and form approximate straight lines. This indicates that the file accesses follow a Zipf distribution. 

Figure 3 indicates that few files account for a very high number of accesses. Thus, any data caching policy that includes those files will bring considerable benefit.

![mr5](/assets/2013-08-18-design-insights-for-mapreduce/mr5.png)

Figure 4 shows data access patterns plotted against file sizes. The distributions for fraction of jobs versus file size vary widely (top graphs), but converge in the upper right corner. In particular, 90% of jobs access files of less than a few GBs (note the log-scale axis). These files account for up to only 16% of bytes stored (bottom graphs). Thus, a viable cache policy would be to cache files whose size is less than a threshold. This policy would allow cache capacity growth rates to be detached from the growth rate in data.

![mr6](/assets/2013-08-18-design-insights-for-mapreduce/mr6.png)

Figure 5 indicates the distribution of time intervals between data re-accesses. 75% of the re-accesses take place within 6 hours. Thus, a possible cache eviction policy would be to evict entire files that have not been accessed for longer than a workload specific threshold duration.

![mr7](/assets/2013-08-18-design-insights-for-mapreduce/mr7.png)

Figure 6 further shows that up to 78% of jobs involve data re-accesses (CC-c, CC-d, CC-e), while for other workloads, the fraction is lower. Thus, the same cache eviction policy potentially translates to different benefits for different workloads.

![mr8](/assets/2013-08-18-design-insights-for-mapreduce/mr8.png)

##4 Workload Variation Over Time
####4.1 Weekly time series
Figure 7 depicts the time series of four dimensions of workload behavior over a week. The first three columns respectively represents the cumulative job counts, amount of I/O (again counted from MapReduce API), and computation time of the jobs submitted in that hour. The last column shows cluster utilization, which reflects how the cluster services the submitted workload describes by the preceding columns, and depends on the cluster hardware and execution environment.

The first feature to observe in the graphs of Figure 7 is that noise is high. This means that even though the number of jobs submitted is known, it is challenging to predict how many I/O and computation resources will be needed as a result. Also, standard signal process methods to quantify the signal to noise ratio would be challenging to apply to these time series, since neither the signal nor noise models are known.

![mr9](/assets/2013-08-18-design-insights-for-mapreduce/mr9.png)

####4.2 Burstiness
Another feature of Figure 7 is the bursty submission patterns in all dimensions. Burstiness is an often discussed property of time-varying signals, but it is not precisely measured.

We start defining burstiness first by using the median rather than the arithmetic mean as the measure of “average”. Median is statistically robust against data outliers, i.e., extreme but rare bursts [26].

We then observe that the peak-to-median ratio is the same as the 100th-percentile-to-median ratio. While the median is statistically robust to outliers, the 100th-percentile is not. This implies that the 99th , 95th , or 90th-percentile should also be calculated. We can graph this vector of values, with nth−percentile/median on the x-axis, versus n on the  y-axis.

Figure 8 graphs this metric for one of the dimensions of our workloads. We also graph two different sinusoidal signals to illustrate how common signals appear under this burstiness metric.

![mr10](/assets/2013-08-18-design-insights-for-mapreduce/mr10.png)

####4.3 Time series correlations
We also computed the correlation between the workload submission time series in all three dimensions, shown in Figure 9. The average temporal correlation between job submit and data size is 0.21; for job submit and com- pute time it is 0.14; for data size and compute time it is 0.62. The correlation between data size and compute time is by far the strongest. We can visually verify this by the 2nd and 3rd columns for CC-e in Figure 9. This indicates that MapReduce workloads remain data-centric rather than compute-centric. Also, schedulers and load balancers need to consider dimensions beyond number of active jobs.

![mr11](/assets/2013-08-18-design-insights-for-mapreduce/mr11.png)

##5 Computation Patterns
####5.1 Task times
Figure 10 shows the aggregate map and reduce task durations for each workload. On average, workloads spend 68% of time in map and 32% of time in reduce. For Facebook, the fraction of time spent mapping increases by 10% over a year. Thus, a design priority should be to optimize map task components, such as read locality, read bandwidth, and map output combiners.

![mr12](/assets/2013-08-18-design-insights-for-mapreduce/mr12.png)

Figure 11 shows for each workload the ratio of aggregate task durations (map time + reduce time) over the aggregate bytes (input + shuffle + output). This ratio aims to capture the amount of computation per data in the absence of CPU/disk/network level logs. 

![mr13](/assets/2013-08-18-design-insights-for-mapreduce/mr13.png)

Figure 11 shows that the ratio of computation per data ranges from 1 × 10−7 to 7 × 10−7 task-seconds per byte, with the FB-2010 workload having 9 × 10−4 task-seconds per byte. Task-seconds per byte clearly separates the workloads. A balanced system should be provisioned specifically to service the task-seconds per byte of a particular workload.

####5.2 Task granularity
Figure 12 shows the cummulative distribution of task durations per workload. The distribution is long tailed. Approximately 50% of the tasks have durations of less than a minute. The remaining tasks have durations of up to hours. Thus, the traces do not support the assumption that tasks are regularly sized.
Absent an enforcement of task size, any task-level scheduling or placement decisions are likely to be suboptimal and prone to be intentionally undermined. 

![mr14](/assets/2013-08-18-design-insights-for-mapreduce/mr14.png)

##5.3 Common job types
Each job can be represented as a six-dimensional vector described by `input size`, `shuffle size`, `output size`, `job duration`, `map task time`, and `reduce task time`. One way to group similarly behaving jobs is to find clusters of vectors close to each other in the six-dimensional space. We use a standard data clustering algorithm, k-means.

Table 4 summarizes our k-means analysis results. We have assigned labels using common terminology to describe the one or two data dimensions that separate job categories within a workload. A system optimizer would use the full numerical descriptions of cluster centroids.

![mr15](/assets/2013-08-18-design-insights-for-mapreduce/mr15.png)


##References
[7] M.Al-Fares,A.Loukissas,andA.Vahdat.Ascalable, commodity data center network architecture. In SIGCOMM 2008.

[8] M. Alizadeh, A. Greenberg, D. A. Maltz, J. Padhye, P. Patel, B. Prabhakar, S. Sengupta, and M. Sridharan. Data center tcp (dctcp). In SIGCOMM 2010.

[25] A. Greenberg, J. R. Hamilton, N. Jain, S. Kandula, C. Kim,P. Lahiri, D. A. Maltz, P. Patel, and S. Sengupta. Vl2: a scalable and flexible data center network. In SIGCOMM 2009.

[20] M. Chowdhury, M. Zaharia, J. Ma, M. I. Jordan, and I. Stoica. Managing data transfers in computer clusters with orchestra. In SIGCOMM 2011.

[15] D.Borthakur,R.Schmit,R.Vadali,S.Chen,andP.Kling.HDFS Raid. Tech talk. Yahoo Developer Network. 2010.

[37] A. Ryan. Next-Generation Hadoop Operations. Bay Area Hadoop User Group, February 2010.

[26] J. Hellerstein. Quantitative data cleaning for large databases. Technical report, United Nations Economic Commission for Eu-rope, February 2008.