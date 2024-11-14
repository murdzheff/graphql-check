

# Use an official Node.js image with Alpine
FROM debian:latest


RUN apt-get update && \
    apt-get install -y curl mailutils swaks netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Copy necessary files
COPY bash-getGraph.sh /bash-getGraph.sh
COPY getgraph.sh /getgraph.sh

# Set the default command
CMD ["bash", "/bash-getGraph.sh"]

