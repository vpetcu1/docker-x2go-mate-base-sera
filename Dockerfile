FROM ubuntu:18.04
#MAINTAINER Josh Lukens <jlukens@botch.com>
ENV DEBIAN_FRONTEND noninteractive

ARG GRAAL_VERSION=1.0.0-rc16

USER root

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update -y -qq && \
    apt-get dist-upgrade -y && \
    apt-get install locales software-properties-common -y && \
    locale-gen en_US.UTF-8 && \

# add x2go repositoires
    add-apt-repository ppa:x2go/stable && \
    apt-get update -y -qq && \

# install supervisor and openssh
    apt-get install -y supervisor openssh-server pwgen vim && \

# install x2go and Mate
    apt-get install -y x2goserver x2goserver-xsession && \
    apt-get install -y ubuntu-mate-desktop --no-install-recommends && apt-get install -y x2gomatebindings && \
#install Global Menu & plank & wallpapers
    apt-get install -y mate-applet-brisk-menu mate-applet-appmenu

# sshd stuff
RUN mkdir -p /var/run/sshd && \
    sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config && \

# fix so resolvconf can be configured
   echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \

# create needed folders
    mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && \
    mkdir -p /var/run/dbus


#clean up
RUN rm -rf /tmp/*
RUN apt-get remove -y apport && apt autoremove -y
RUN apt-get autoclean && apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*


ENV REMOTE_USER=desktop
ENV PROJECT_NAME=Test
ENV REMOTE_PASSWORD=password

#copy necessary to configure workingstation
COPY ["*.conf", "/etc/supervisor/conf.d/"]
COPY ["*.sh", "/"]
COPY ["eclipse_preferences.epf", "/"]

RUN cp /set_env.sh /etc/profile.d/set_env.sh
RUN chmod +x /*.sh

EXPOSE 22
ENTRYPOINT ["/docker-entrypoint.sh"]
