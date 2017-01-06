FROM openjdk:8

MAINTAINER Jostein Austvik Jacobsen

WORKDIR /root

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential maven gradle libxml2-utils pcregrep rsync
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
RUN apt-get update && apt-get install -y golang vim zip

# Clone and fetch (Maven JARs, etc.)
RUN git clone https://github.com/daisy/pipeline
RUN cd pipeline && git remote add sbsdev https://github.com/sbsdev/pipeline
RUN cd pipeline && git remote add nlbdev https://github.com/nlbdev/pipeline
RUN cd pipeline && mkdir -p .maven-cache
RUN cd pipeline && git fetch --all

ADD src/ /root/src/

CMD /root/src/run.sh
