FROM openjdk:8

MAINTAINER Jostein Austvik Jacobsen

WORKDIR /root

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential maven gradle libxml2-utils pcregrep

# Download and build Pipeline 2, so that we normally only need to do incremental builds
RUN git clone https://github.com/daisy/pipeline.git
RUN cd pipeline && mkdir -p .maven-cache && make

ADD src/ /root/src/

CMD /root/src/run.sh
