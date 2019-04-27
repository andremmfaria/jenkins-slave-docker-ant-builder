FROM ubuntu:18.04
MAINTAINER Andre Faria <andremarcalfaria@gmail.com>

#ENV Sonar-Scanner
ENV SONAR_RUNNER_HOME=/opt/sonar-scanner
ENV PATH $PATH:/opt/sonar-scanner/bin
ENV TERRAFORM_VER="0.11.11"

# Update system
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y wget gnupg unzip git openssh-server curl software-properties-common
# Install requirements
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-add-repository ppa:ansible/ansible -y && \
    apt-get install -y ansible nodejs openjdk-8-jdk sshpass jq
# Install Terraform    
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -r terraform_${TERRAFORM_VER}_linux_amd64.zip
#Install Sonar-Scanner
RUN mkdir /tmp/tempdownload && \
    curl --insecure -o /tmp/tempdownload/scanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip && \
    unzip /tmp/tempdownload/scanner.zip -d /tmp/tempdownload && \
    mv /tmp/tempdownload/$(ls /tmp/tempdownload | grep sonar-scanner) /opt/sonar-scanner && \
    rm -rf /tmp/tempdownload
# Cleanup image
RUN apt-get autoclean -y && \
    apt-get autoremove -y
# Configure sshd
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
# Create sshd folder
    mkdir -p /var/run/sshd

# Add user jenkins to the image, change it's password and create m2 folder
RUN adduser --disabled-password --gecos "" jenkins && \
    echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
