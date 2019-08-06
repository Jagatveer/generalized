FROM jenkins/jenkins:2.97
USER root

ENV MAILNAME jenkins.nclouds.com
ENV MY_DESTINATION localhost.localdomain, localhost
ENV ROOT_ALIAS noreply@jenkins.nclouds.com

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz && tar --strip-components=1 -xvzf docker-1.11.2.tgz -C /usr/local/bin

RUN curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose \
    && chmod +x /usr/bin/docker-compose

RUN apt-get update -q -q && \
 echo postfix postfix/main_mailer_type string "'Internet Site'" | debconf-set-selections && \
 echo postfix postfix/mailname string jenkins.nclouds.com | debconf-set-selections && \
 apt-get --yes --force-yes install postfix && \
 postconf -e mydestination="localhost.localdomain, localhost" && \
 postconf -e smtpd_banner='$myhostname ESMTP $mail_name' && \
 postconf -e inet_protocols=ipv4

RUN apt-get install -y python-tk python-dev gcc \
    pinentry-gtk2

# setting the configuration for gpg, needed since 2.1.0 version
COPY gpg.conf /root/.gnupg/gpg-agent.conf

RUN echo "export GPG_TTY=$(tty)" >> /etc/profile

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install ecs-deploy awscli
RUN mkdir /root/.ssh
RUN mkdir /var/jenkins_home/.ssh

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

COPY seed-job.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY auth.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY cloud.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY slack.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY okta.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY sonarGlobalConfig.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY sonarRunner.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY init.groovy /usr/share/jenkins/ref/init.groovy
COPY jobs/ /usr/share/jenkins/ref/jobs/seed-job/workspace/jobs/

ENTRYPOINT ["/bin/tini", "--"]
CMD ["sh","-c","rm -r $JENKINS_HOME/jobs/seed-job/workspace/jobs; service postfix start; /usr/local/bin/jenkins.sh"]
