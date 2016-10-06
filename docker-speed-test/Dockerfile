FROM openjdk:8

MAINTAINER Jostein Austvik Jacobsen

WORKDIR /root

# Install dependencies
RUN apt-get update && apt-get install -y git build-essential maven gradle libxml2-utils pcregrep

ADD src/ /root/src/

CMD /root/src/run.sh
