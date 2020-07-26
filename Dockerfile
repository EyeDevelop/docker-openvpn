FROM alpine

# Add the required packages.
RUN apk add -U easy-rsa openvpn bash

# Copy the basic config files.
COPY server.cfg /server.cfg
COPY client.cfg /client.cfg

# Make sure /data exists.
RUN mkdir /data

# Run the entrypoint.
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
