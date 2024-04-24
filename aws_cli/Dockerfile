# ///////////////////////////////////////////////////////////////////////////// #
#  This Dockerfile sets up a container environment with the AWS CLI installed.  #
#  It facilitates AWS command-line operations by allowing users to pass their   #
#  AWS access key ID, secret access key, and preferred region as environment    #
#  variables.                                                                   #
# ///////////////////////////////////////////////////////////////////////////// #


# Use the lightwiegh official alphine image 
FROM alpine:3.14


# Install Python and Python pip
RUN apk update
RUN apk add --no-cache python3 py3-pip


# Set environment variables for AWS credentials and region
ENV AWS_ACCESS_KEY_ID=<YOUR KEY ID>
ENV AWS_SECRET_ACCESS_KEY=<YOUR KEY SECRETE>
ENV AWS_DEFAULT_REGION=eu-west-1

# Optionally, you can provide placeholders for these environment variables
# and pass them when running the container using the --env option.
#
# Example:
# docker run --env AWS_ACCESS_KEY_ID=your_access_key_id \
#            --env AWS_SECRET_ACCESS_KEY=your_secret_access_key \
#            --env AWS_DEFAULT_REGION=your_default_region \
#            your_custom_image_name aws <your_command>
# 
# Note: It's recommended to use AWS IAM roles or securely manage credentials
# rather than embedding them directly into Dockerfiles or containers.


# Install AWS CLI
RUN pip3 install awscli
