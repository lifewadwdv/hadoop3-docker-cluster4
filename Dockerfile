FROM centos
MAINTAINER lifewadwdv1029 <lifewadwdv1029@gmail.com>

USER root

RUN yum -y update

RUN yum install -y openssh-server openssh-clients openssh-askpass

# add hadoop user
RUN useradd -m -s /bin/bash hadoop

# set pubkey authentication
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config
RUN mkdir -p /home/hadoop/.ssh
RUN echo "PubkeyAcceptedKeyTypes +ssh-dss" >> /home/hadoop/.ssh/config
RUN echo "PasswordAuthentication no" >> /home/hadoop/.ssh/config

# copy keys
ADD id_rsa.pub /home/hadoop/.ssh/id_rsa.pub
ADD id_rsa /home/hadoop/.ssh/id_rsa
RUN chmod 400 /home/hadoop/.ssh/id_rsa
RUN chmod 400 /home/hadoop/.ssh/id_rsa.pub
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
RUN chown hadoop -R /home/hadoop/.ssh

# remove openjdk
RUN yum -y autoremove java

ENV HADOOP_HOME /opt/hadoop
ENV JAVA_HOME /opt/jdk1.8.0_271

ADD jdk-8u271-linux-x64.tar.gz /opt


RUN yum install -y rsync
RUN yum install -y vim
RUN yum install -y net-tools
RUN yum install -y wget

RUN yum -y reinstall which clear
RUN yum install -y ncurses
RUN yum groupinstall -y "Development tools"

RUN echo "export JAVA_HOME=$JAVA_HOME">>/etc/profile
RUN echo "export PATH=$JAVA_HOME/bin:$PATH">>/etc/profile
RUN echo "export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar">>/etc/profile


RUN if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python2.7 /usr/bin/python; fi

ADD hadoop-3.2.0.tar.gz /

RUN mv hadoop-3.2.0 $HADOOP_HOME && \
    for user in hadoop hdfs yarn mapred; do \
         useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user}; \
    done && \

    for user in root hdfs yarn mapred; do \
         usermod -G hadoop ${user}; \
    done && \

    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD *xml $HADOOP_HOME/etc/hadoop/
ADD workers $HADOOP_HOME/etc/hadoop/workers

ADD ssh_config /root/.ssh/config
ADD *start-all.sh /
RUN chmod 755 *start-all.sh
RUN mkdir $HADOOP_HOME/logs

RUN chmod 600 ~/.ssh/config

# RUN chown $USER ~/.ssh/config

EXPOSE 50010 50020 50070 50075 50090 8020 9000 50070
EXPOSE 10020 19888
EXPOSE 8088 9870 9864 19888 8042 8888 8088 8020 9000 8485 8019 

EXPOSE 2181 2888 3888

EXPOSE 60010 60030

EXPOSE 9083 10000

EXPOSE 7077 8080 8081 4040 18080

EXPOSE 9092

EXPOSE 6379

EXPOSE 7180 7182



CMD ["/usr/sbin/init"]
