FROM jenkins/jenkins:lts
USER root
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
# RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz && tar --strip-components=1 -xvzf docker-1.11.2.tgz -C /usr/local/bin
#
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
# RUN curl -O https://bootstrap.pypa.io/get-pip.py
# RUN python get-pip.py
# RUN pip install ecs-deploy awscli
# RUN mkdir /root/.ssh
# RUN mkdir /var/jenkins_home/.ssh
#
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
#
# COPY seed-job.groovy /usr/share/jenkins/ref/init.groovy.d/
# COPY auth.groovy /usr/share/jenkins/ref/init.groovy.d/
# COPY cloud.groovy /usr/share/jenkins/ref/init.groovy.d/
# COPY slack.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY init.groovy /usr/share/jenkins/ref/init.groovy
# COPY jobs/ /usr/share/jenkins/ref/jobs/seed-job/workspace/jobs/
#
