FROM snaekobbi/system:1.8.0-latest

MAINTAINER Jostein Austvik Jacobsen
MAINTAINER Bert Frees

RUN sed -i 's|\(eval exec \"\\\"\$JAVA\"\\\" \"\$JAVA_OPTS\"\)|\1 -agentpath:/mnt/yourkit/libyjpagent.so=listen=0.0.0.0:10001|' /opt/daisy-pipeline2/bin/pipeline2

EXPOSE 10001

CMD service pipeline2d start && tail -f /var/log/daisy-pipeline2/daisy-pipeline.log
