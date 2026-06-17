FROM alpine:latest

# Install dependencies
RUN apk add --no-cache openjdk25 wget bash

# Everything will be stored in /app inside the container
WORKDIR /app

# Download the Minecraft server jar file
RUN wget -O server.jar https://piston-data.mojang.com/v1/objects/823e2250d24b3ddac457a60c92a6a941943fcd6a/server.jar

# Copy the entrypoint script into the container
COPY docker-entrypoint.sh docker-entrypoint.sh

# Run the entrypoint script when the container starts
ENTRYPOINT ["bash", "docker-entrypoint.sh"]