FROM 9.212.156.58:6000/library/smd_rhel65_server

ENV ARTIFACT_REPO http://sbybz221159.cloud.dst.ibm.com/artifacts
ENV IBM_JRE_VERSION 8.0-1.10
ENV UCB_SERVER IBM_UCB_SERVER_6.1.0.2
ENV UCB_SERVER_URL $ARTIFACT_REPO/$UCB_SERVER.zip
ENV JAVA_TAR ibm-java-x86_64-jre-8.0-1.10.tar.gz
ENV JAVA_URL $ARTIFACT_REPO/$JAVA_TAR
ENV IBM_UCB_SECURE true

RUN set -x \
    && yum -y --quiet update \
    && yum -y --quiet install tar \
    && yum -y --quiet install unzip \
    && yum -y --quiet install openssh-clients \
    && yum clean packages

RUN set -x \
    && mkdir -p /opt/java \
    && cd /opt/java \
    && wget -q -O - $JAVA_URL | tar xzf - \
    && rm -f $JAVA_TAR

ENV JAVA_HOME /opt/java/ibm/java-x86_64-80/jre
ENV PATH $JAVA_HOME/bin:$PATH

EXPOSE 8080 9443 7919

WORKDIR /opt/IBM/UCBuild/server
COPY installtools/ /installtools/

RUN set -x \
    && /installtools/install_ucb.sh $UCB_SERVER_URL \
    && rm -f /$UCB_SERVER.zip
    
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server", "run"]
