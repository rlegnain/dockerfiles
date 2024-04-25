# /////////////////////////////////////////////////////////////////////////////// #
# This Docker container provides a simple SSH server with password authentication #
#  enabled, suitable for environments where password-based access is required or  #
#  preferred.                                                                     #
#                                                                                 #
# build image:                                                                    #
#   >> docker build -f "Dockerfile" -t sshserver:v1 "."                           #
#                                                                                 #
# Run container:                                                                  #
#   >> docker run -p 22:22 sshserver:v1                                           #
#                                                                                 #
# Test:                                                                           #
#   >> ssh user1@localhost                                                        #
#    password is password1                                                        #
# /////////////////////////////////////////////////////////////////////////////// #

FROM ubuntu:22.04

# Install required pachages
RUN apt update && apt install openssh-server sudo -y


# Set the root password for SSH access
RUN echo 'root:pass!' | chpasswd


# Add users.  You can add more users if you want
ARG USERNAME1=user1
ARG PASSWORD1=password1

ARG USERNAME2=user2
ARG PASSWORD2=password2

# Create user1 and add it to root and sudo group
RUN useradd -m -d /home/$USERNAME1 -s /bin/bash -g root -G sudo -u 1000 $USERNAME1
RUN echo "$USERNAME1:$PASSWORD1" | chpasswd

# Create user2 which is limited user
RUN useradd -m -U -d /home/$USERNAME2 -s /bin/bash -u 1001 $USERNAME2
RUN echo "$USERNAME2:$PASSWORD2" | chpasswd


# To enable root login via ssh uncomment this line.  But it is not recommended.
# Run sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 

# Allow SSH access with password
Run  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config


RUN service ssh start

# Expose SSH port
EXPOSE 22

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]

