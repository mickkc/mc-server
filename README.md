# MC-Server

A minecraft server configuration using Docker and Docker compose to automatically download and configure a server.

- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
- [Usage](#usage)
    - [Configuration](#configuration)
    - [Server Operators](#server-operators)
- [Technical explanation](#technical-explanation)
    - [Dockerfile](#dockerfile)
    - [Entrypoint script](#entrypoint-script)
    - [Docker compose file](#docker-compose-file)

## Prerequisites

- [Docker](https://docs.docker.com/engine/install)
- [Docker compose](https://docs.docker.com/compose/install/)

## Quickstart


1. Clone this repository
    ```bash
    git clone https://
    ```
2. Copy the `example.env` and configure the server to your liking.
    ```bash
    # Copy it:
    cp example.env .env

    # Edit it:
    nano .env
    ```
    The default configuration already contains comments explaining each option, but you can also check out the [Configuration section](#configuration).
3. Start the server using `docker compose`:
    ```bash
    docker compose up -d --build
    ```
    This will build the image (`--build`) and start the container (`up`), running in the background (`-d`)
4. You can now access your server on port `25565` (or the port you configured in the `CONTAINER_PORT` environment variable).

## Usage

### Configuration

The server is configured using environment variables. They are written into the `server.properties` when the container starts.

These options can either be specified in your `.env`-file (recommended, see [.env.example](/.env.example)) or directly in the container:

```yml
services:
    mc-server:
        ...
        environment:
            - DIFFICULTY=medium
```

| Name | Description | Default |
|------|-------------|---------|
| MOTD | The message displayed in the server list, under the servers name. | `A Minecraft Server` |
| SERVER_PORT | The port the server will run on inside the container. | `25565` |
| MEMORY | The amount of memory allocated to the server. This should be in a format like "4G" for 4 gigabytes or "512M" for 512 megabytes. | `4G` |
| CONTAINER_PORT | The port that will be mapped to the container's port. This is the port your host machine can connect to. | `25565` |
| MAX_PLAYERS | The maximum amount of players that can join the server. | `20` |
| DIFFICULTY | The game difficulty: `peaceful`, `easy`, `normal` or `hard`. | `easy` |
| HARDCORE | Whether to enable hardcore mode. | `false` |
| GAMEMODE | The default gamemode for new players: `survival`, `creative` or `adventure` | `survival` |
| FORCE_GAMEMODE | Whether to switch to the default gamemode every time a player joins. | `false` |
| LEVEL_NAME | The world name (used to save and load world files) | `world` |
| LEVEL_SEED | The seed to use to generate new worlds | None (random seed) |
| GENERATE_STRUCTURES | Whether to generate structures like villages, mansions, etc. | `true` |
| OP_PLAYER_NAME | The name of the operator player (the player with admin permissions). | `Notch` |
| OP_PLAYER_UUID | The UUID of the operator player. You can find this using a service like https://mcuuid.net/. | `069a79f4-44e9-4726-a5be-fca90e38aaf5` |
| OP_PLAYER_OVERRIDE | Setting this to `true` will override the existing `ops.json` file, replacing all entries with `OP_PLAYER_NAME` and `OP_PLAYER_UUID`. | `false` |

### Server Operators

On first start, a `ops.json` is generated from the specified `OP_PLAYER_NAME` and `OP_PLAYER_UUID`.
After that, the file is not overridden to keep operators added through the in-game `/op`-command.

To explicitly override all operators with the configured player-data, set `OP_PLAYER_OVERRIDE` to `true`.

## Technical explanation

### Dockerfile

The server image is built using the [Dockerfile](/Dockerfile), which installs performs the following steps:

1. Install dependencies:
    - `openjdk25`: The java runtime required to run the server.
    - `wget`: Used to download the server binary. (Not included in the repo).
    - `bash`: Used to run the entry point script.
2. Change the working directory to `/app`
    - This is where all files related to the minecraft server are stored.
3. Download the server.jar file using `wget`.
    - The file is not included in this repo because using large binary files is not recommended in git.
4. Copy the [docker entrypoint script](/docker-entrypoint.sh)
5. Run the entrypoint script when the container is started.

### Entrypoint script

The entrypoint converts the environment variables into files that are readable by the server and runs it:

1. Create the `/app/data` directory if it does not exist already.
    - In this directory, all the server data is saved. It should be mounted using volumes in docker compose.
2. Agree to the EULA by writing to `/app/data/eula.txt`.
3. Fills the `server.properties` with the configured environment variables (or their default value if they are not set).
4. Generate the `ops.json` file if it does not exist or overriding is explicitly enabled.
5. Change the working directory to `/app/data`, so the server saves its files there.
6. Run the server with the specified memory and port options.

### Docker compose file

The [docker-compose.yml] file specifies how the container should be run. The image is built using the dockerfile using `build: .` (`.` means the `Dockerfile` is in the same directory as the `docker-compose.yml`).

It also specifies the ports, that are loaded from the environment variables, where `CONTAINER_PORT` is the port reachable from the host, and `SERVER_PORT` is the port inside the container. Both default to `25565`.

At the bottom, there is a volume defined, that is mounted to `/app/data` to save the server's state.

The `env_file` is also specified and is the source of all environment variables used inside the container and the docker-compose.yml.

It is also set to always restart, unless explicitly stopped using `restart: unless-stopped`.