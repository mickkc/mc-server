FROM alpine:latest

# Install dependencies
RUN apk add --no-cache openjdk25 wget bash

# Everything will be stored in /app inside the container
WORKDIR /app

# Copy the entrypoint script into the container
COPY docker-entrypoint.sh docker-entrypoint.sh

# Expose the default Minecraft server port (port can still be changed later using environment variables)
EXPOSE 25565

# Run the entrypoint script when the container starts
ENTRYPOINT ["bash", "docker-entrypoint.sh"]