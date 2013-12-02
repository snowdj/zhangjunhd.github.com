---
layout: post
title: "Large Scale System Problems Detection by Mining Console Logs"
description: ""
category: tech 
tags: [log]
---
{% include JB/setup %}
paper review:[Large-Scale System Problems Detection by Mining Console Logs](http://www.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-103.pdf)

<!--break-->

##1 Introduction
A typical console log is much more structured than it appears: the definition of its “schema” is implicit in the log printing statements, which can be recovered from program source code. This observation is key to our log parsing approach, which yields detailed and accurate features.

Specifically, our methodology involves the following four contributions:

* A technique for analyzing source code to recover the structure inherent in console logs
* The identification of common information in logs—state variables and object identifiers—and the automatic creation of features from the logs (exploiting the structure found) that can be subjected to analysis by a variety of machine learning algorithms 
* Demonstration of a machine learning and information retrieval methodology that effectively detects unusual patterns or anomalies across large collections of such features extracted from a console log
* Where appropriate, automatic construction of a visualization that distills the results of anomaly detection in a compact and operator-friendly format that assumes no understanding of the details of the algorithms used to analyze the features.
##2 Overview of Approach 
####2.1 Information buried in textual logs
To analyze logs automatically, we need to create high quality `features`, the numerical representation of log information that is understandable by a machine learning algorithm. The following three key observations lead to our solution to this problem.
* **Source code is the “schema” of logs.** Our method leverages source code analysis to recover the inherit structure of logs. The most significant advantage of our approach is that we are able to accurately parse all possible log messages, even the ones rarely seen in actual logs.
* **Common log structures lead to useful features.** A person usually reads the log messages in Figure 1 as a constant part (starting: xact ... is) and multiple variable parts (325/326 and COMMITTING/ABORTING). In this paper, we call the constant part the `message type` and the variable part the `message variable`. `Identifiers` are variables used to identify an object manipulated by the program (e.g., the transaction ids 325 and 346 in Figure 1), while `state variables` are labels that enumerate a set of possible states an object could have in program (e.g. COMMITTING and ABORTING in Figure 1).
![log1](/assets/2013-07-17-large-scale-system-problems-detection-by-mining-console-logs/log1.png)

* **Messages are strongly correlated.** A group of related messages is often a better indicator of problems than individual messages.

####2.2 Workflow of our approach
Figure 2 shows the four steps in our general framework for mining console logs.
![log2](/assets/2013-07-17-large-scale-system-problems-detection-by-mining-console-logs/log2.png)

* **Log parsing.** We first convert a log message from unstructured text to a data structure that shows the message type and a list of message variables in (name, value) pairs. We get all possible log message template strings from the source code and match these templates to each log message to recover its structure.
* **Feature creation.** Next, we construct feature vectors from the extracted information by choosing appropriate variables and grouping related messages.
* **Anomaly detection.** Then, we apply anomaly detection methods to mine feature vectors, labeling each feature vector as normal or abnormal.
* **Visualization.**

##3 Log Parsing with Source Code
Like other log parsers, we use regular expressions; unlike other log parsers, the regular expressions we use are automatically generated from source code analysis. We call these regular expressions `message templates`.

Our parsing method involves two major steps. In the first step, the `static source code analysis` step, we generate all possible message templates from source code.

In the second step, the `log parsing` step, for each log message, we choose the best matching message template generated from the first step and use it to extract message variables.

##4 Feature Creation
The `state ratio vector` is able to capture the aggregated behavior of the system over a time window. The `message count vector` helps detect problems related to individual operations.

This section describes our technique for constructing features from parsed logs. We focus on two features, `the state ratio vector` and `the message count vector`, based on `state variables `and `identifiers` (see Section 2.1), respectively. The state ratio vector **is able to capture the aggregated behavior of the system over a time window.** The message count vector helps **detect problems related to individual operations.**

####4.1 State variables and state ratio vectors
We construct `state ratio vectors` y to encode this correlation: Each state ratio vector represents a group of state variables in a time window, while each dimension of the vector corresponds to a distinct state variable value , and the value of the dimension is how many times this state value appears in the time window.

In creating features based on state variables we used an automatic procedure that combined two desiderata: 1) message variables should be frequently reported, but 2)they should range across a small constant number of distinct values that do not depend on the number of messages.

####4.2 Identifiers and message count vectors
We observe that all log messages reporting the same identifier convey a single piece of information about the identifier. For instance, in HDFS, there are multiple log messages about a block when the block is allocated, written, replicated, or deleted. By grouping these messages, we get the message count vector, which is similar to an execution path (from custom instrumentation).

To form the message count vector, we first automatically discover identifiers, then group together messages with the same identifier values, and create a vector per group. Each vector dimension corresponds to a different message type, and the value of the dimension tells how many messages of that type appear in the message group.

Algorithm 1 summarizes our three-step process for feature construction.
     
    Algorithm 1 Message count vector construction
    1. Find all message variables reported in the log with the following properties: 
        a. Reported many times;
        b. Has many distinct values;
        c. Appears in multiple message types.
    2. Group messages by values of the variables chosen above.
    3. For each message group, create a message count vector y = [y1,y2,...,yn],
      where yi is the number of appearances of messages of type i (i = 1 ... n) 
      in the message group.
##5 Anomaly Detection
We have investigated a variety of such methods and have found that Principal Component Analysis (`PCA`) combined with term-weighting techniques from information retrieval yields excellent anomaly detection results on both feature matrices, while requiring little parameter tuning.![log3](/assets/2013-07-17-large-scale-system-problems-detection-by-mining-console-logs/log3.png)  

Figure 4 illustrates a simplified example using two dimensions (number of ACTIVE and COMMITTING per second) from Darkstar state ratio vectors. We see most data points reside close to a straight line (a one-dimensional subspace). In this case, we say the data have low effective dimensionality. The axis Sd captures the strong correlations between the two dimensions. Intuitively, a data point far from the Sd (such as point A) shows unusual correlation, and thus represents an anomaly.

In summary, PCA captures dominant patterns in data to construct a (low) k-dimensional normal subspace Sd in the original n-dimensional space. The remaining (n − k) dimensions form the abnormal subspace `Sa`. By projecting the vector y on Sa (separating out its component on `Sd`), it is much easier to identify abnormal vectors.  
We applied Term Frequency / Inverse Document Frequency (`TF-IDF`) to pre-process the data. 
