# Create the data directory if it doesn't exist
mkdir -p /app/data

# Agree to the EULA by creating the eula.txt file
echo "eula=true" > /app/data/eula.txt

# Generate the server.properties file with the provided environment variables or defaults
cat > /app/data/server.properties <<EOF
motd=${MOTD:-A Minecraft Server}
server-port=${SERVER_PORT:-25565}
max-players=${MAX_PLAYERS:-20}
difficulty=${DIFFICULTY:-easy}
gamemode=${GAMEMODE:-survival}
force-gamemode=${FORCE_GAMEMODE:-false}
hardcore=${HARDCORE:-false}
level-name=${LEVEL_NAME:-world}
level-seed=${LEVEL_SEED:-}
generate-structures=${GENERATE_STRUCTURES:-true}
EOF

if [ ! -f /app/data/ops.json ] || [ ${OP_PLAYER_OVERRIDE:-false} = "true" ]; then
    echo "Generating ops.json with default operator player information..."
    # Generate the ops.json file with the operator player information
    cat > /app/data/ops.json <<EOF
[
    {
        "uuid": "${OP_PLAYER_UUID:-069a79f4-44e9-4726-a5be-fca90e38aaf5}",
        "name": "${OP_PLAYER_NAME:-Notch}",
        "level": 4,
        "bypassesPlayerLimit": false
    }
]
EOF
else
  echo "ops.json already exists. Skipping generation of ops.json. Set OP_PLAYER_OVERRIDE=true to regenerate ops.json with default operator player information."
fi


# Change to the data directory before starting the server
cd /app/data

# Start the Minecraft server with the specified memory settings and port
exec java -Xms"${MEMORY:-4G}" -Xmx"${MEMORY:-4G}" \
  -jar /app/server.jar --nogui --port "${SERVER_PORT:-25565}"