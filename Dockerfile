FROM ubuntu:18.04
MAINTAINER Andre Faria <andre.faria@multilaser.com.br>

#ENV Sonar-Scanner
ENV SONAR_RUNNER_HOME=/opt/sonar-scanner
ENV PATH $PATH:/opt/sonar-scanner/bin

# Update system
RUN apt-get update && \
    apt-get -y dist-upgrade && \
# Install essential packages   
    apt-get install -y gnupg unzip git openssh-server sshpass curl ant && \
# Install requirements
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs openjdk-8-jdk jq && \
#Install Sonar-Scanner
    curl --insecure -o /tmp/sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip && \
    unzip /tmprscanner.zip && \
    mv /tmp/sonar-scanner-cli-3.3.0.1492-linux /opt/sonarscanner && \
    rm /tmp/sonarscanner.zip && \
# Cleanup image
    apt-get autoclean -y && \
    apt-get autoremove -y && \
# Configure sshd
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
# Create sshd folder
    mkdir -p /var/run/sshd

# Add user jenkins to the image, change it's password and create m2 folder
RUN adduser --disabled-password --gecos "" jenkins && \
    echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
