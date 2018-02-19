FROM fedora:27
LABEL maintainer "Luiz Henrique de Sousa Ribas <lhs.ribas@gmail.com>"

ARG logs_arg="/opt/logs"
ENV logs=${logs_arg}

# Step 1
RUN groupadd jboss-eap && \
    groupadd -G jboss-eap eap && \
# Step 2
    mkdir -p /opt/rh && \
    mkdir -p /etc/jboss-as && \
    mkdir -p /var/log/jboss-as && \
# Step 3
    yum -y install wget java-1.8.0-openjdk-devel unzip && \ 
    yum clean all && \
# Step 4
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/jre && \
    export PATH=$JAVA_HOME/bin:$PATH

# Step 5 
COPY scripts/functions /etc/init.d/ && \
     eap/jboss-eap-7.0.0.zip /opt/rh/
     
# Step 6
WORKDIR /opt/rh/

# Step 7
RUN chmod 777 /etc/init.d/functions && \
# Step 8
    unzip jboss-eap-7.0.0.zip && \
    rm -rf jboss-eap-7.0.0.zip && \
# Step 9
    ln -s /opt/rh/jboss-eap-6.4/bin/init.d/jboss-as.conf /etc/jboss-as/jboss-as.conf && \
    ln -s /opt/rh/jboss-eap-6.4/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss-eap && \
# Step 10
    chown -R eap:eap /etc/init.d/jboss-eap && \
    chown -R eap:eap /opt/rh && \ 
    chown -R eap:eap /etc/jboss-as && \ 
    chown -R eap:eap /var/log/jboss-as && \ 
    chown -R eap:eap /var/run/jboss-as

##
# Change to user eap
##
USER eap

##
# Map a volume to copy your logs 
##
VOLUME ${logs}:/var/log/jboss-as/*.log

##
# Expose the ports of EAP
# 9990 - Admin port
# 8080 - App Port
##
EXPOSE 9990 8080

##
# Copy the application into jboss eap
# with your app need change the standalone.xml, will be necessary create a version into in your folder 
# and replace the actual by it.
#
# e.g. COPY 
#
##
COPY app/* /opt/rh/jboss-eap-7.0/standalone/deployments && \
     eap/init.d/jboss-eap.conf /opt/rh/jboss-eap-7.0/bin/init.d/jboss-eap.conf

##
# Start the JBoss EAP
##
CMD /etc/init.d/jboss-eap start

