FROM snaekobbi/system:1.8.0-latest

MAINTAINER Jostein Austvik Jacobsen

# Enable SSH login (user:pass = root:root)
RUN apt-get update && apt-get install -y openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN sed -i 's/\(eval exec \"\\\"\$JAVA\"\\\" \"\$JAVA_OPTS\"\)/\1 -agentpath:\/mnt\/yourkit\/libyjpagent.so=listen=0.0.0.0:10001/' /opt/daisy-pipeline2/bin/pipeline2

ADD pipeline.sh /usr/bin/

EXPOSE 10001

CMD /usr/bin/pipeline.sh
