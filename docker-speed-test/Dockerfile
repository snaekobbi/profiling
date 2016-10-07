FROM openjdk:8

MAINTAINER Jostein Austvik Jacobsen

WORKDIR /root

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential maven gradle libxml2-utils pcregrep rsync

# Build once, to download dependencies (Maven JARs, etc.)
RUN git clone https://github.com/daisy/pipeline.git
RUN cd pipeline && mkdir -p .maven-cache
RUN cd pipeline && make dist-zip
RUN cd pipeline && make clean

ADD src/ /root/src/

CMD /root/src/run.sh
