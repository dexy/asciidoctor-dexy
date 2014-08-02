FROM                    phusion/baseimage
MAINTAINER              Ana Nelson <ana@ananelson.com>

### "localedef"
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

### "squid-deb-proxy"
# Use squid deb proxy (if available on host OS) as per https://gist.github.com/dergachev/8441335
# Modified by @ananelson to detect squid on host OS and only enable itself if found.
ENV HOST_IP_FILE /tmp/host-ip.txt
RUN /sbin/ip route | awk '/default/ { print "http://"$3":8000" }' > $HOST_IP_FILE
RUN HOST_IP=`cat $HOST_IP_FILE` && curl -s $HOST_IP | grep squid && echo "found squid" && echo "Acquire::http::Proxy \"$HOST_IP\";" > /etc/apt/apt.conf.d/30proxy || echo "no squid"

### "apt-defaults"
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom
RUN echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom

### "update"
RUN apt-get update

### "utils"
RUN apt-get install build-essential
RUN apt-get install adduser sudo
RUN apt-get install curl

### "nice-things"
RUN apt-get install ack-grep strace vim git tree wget unzip rsync

### "python"
RUN apt-get install python-dev
RUN apt-get install python-pip

### "dexy"
RUN pip install dexy

### "asciidoctor"
RUN apt-get install ruby1.9.1
RUN apt-get install ruby1.9.1-dev
RUN gem install asciidoctor -v 1.5.0.rc.4
RUN gem install pygments.rb

### "fake-fuse-for-openjdk"
RUN apt-get install fuse || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get install fuse

### "install-jdk"
RUN apt-get install openjdk-7-jdk

### "create-user"
RUN useradd -m repro
RUN echo "repro:foobarbaz" | chpasswd
RUN adduser repro sudo

### "activate-user"
ENV HOME /home/repro
USER repro
WORKDIR /home/repro

### "asciidoctor-fopub"
RUN wget https://github.com/asciidoctor/asciidoctor-fopub/archive/master.zip
RUN unzip master.zip
RUN rm master.zip
RUN echo "export PATH=$PATH:/home/repro/asciidoctor-fopub-master" >> .bashrc

### "init-fopub"
WORKDIR /home/repro/asciidoctor-fopub-master
RUN ./gradlew init
RUN mkdir sample
WORKDIR /home/repro/asciidoctor-fopub-master/sample
ADD sample/minimal.xml /home/repro/asciidoctor-fopub-master/sample/minimal.xml
RUN ../fopub minimal.xml

### "reset-cwd"
WORKDIR /home/repro
