FROM snaekobbi/system:1.8.0-latest

MAINTAINER Jostein Austvik Jacobsen
MAINTAINER Bert Frees

ADD yourkit-probes.jar /pipeline2/lib/

RUN echo 'JAVA_OPTS="-server -Xms256M -Xmx1G -XX:PermSize=16M -XX:MaxPermSize=256M -Dcom.sun.management.jmxremote"' >> /etc/default/pipeline2d
RUN echo 'JAVA_OPTS="$JAVA_OPTS -Xbootclasspath/a:/pipeline2/lib/yourkit-probes.jar"' >> /etc/default/pipeline2d
RUN echo 'JAVA_OPTS="$JAVA_OPTS -agentpath:/mnt/yourkit/bin/linux-x86-64/libyjpagent.so=listen=0.0.0.0:10001,probeclasspath=/pipeline2/lib/yourkit-probes.jar,probe=org.daisy.pipeline.yourkit.probes.Liblouis,probe=org.daisy.pipeline.yourkit.probes.XPath,probe=org.daisy.pipeline.yourkit.probes.XSLT,probe=org.daisy.pipeline.yourkit.probes.XProc"' >> /etc/default/pipeline2d
RUN echo 'export JAVA_OPTS' >> /etc/default/pipeline2d
RUN echo 'org.osgi.framework.bootdelegation=org.daisy.pipeline.yourkit.probes' >> /opt/daisy-pipeline2/etc/config.properties

EXPOSE 10001

CMD service pipeline2d start && tail -f /var/log/daisy-pipeline2/daisy-pipeline.log
