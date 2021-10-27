# Set the base image
FROM ubuntu:20.04

# Set environment variables
ENV USER root
ENV HOME /root

# Set working directory
WORKDIR $HOME

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd libsdl2-2.0-0:i386 \
 && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Add satisfactory user
RUN useradd -ms /bin/bash satisfactory

# Switch to satisfactory User env
USER satisfactory
WORKDIR /home/satisfactory

# Update SteamCMD and verify latest version
RUN steamcmd +quit

# Fix steamclient.so not found issue
RUN mkdir -p /home/satisfactory/.steam/sdk64/
RUN ln -s /usr/games/steamcmd/linux64/steamclient.so /home/satisfactory/.steam/sdk64/

# Set default command
ENTRYPOINT ["steamcmd"]
CMD ["+login anonymous +force_install_dir "/home/satisfactory/satisfactory" +app_update 1690800 validate +quit"]

# Run satisfactory
RUN /home/satisfactory/satisfactory/FactoryServer.sh
