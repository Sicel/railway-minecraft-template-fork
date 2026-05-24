FROM oven/bun:latest AS builder

WORKDIR /build
COPY package.json bun.lock ./
RUN bun install

COPY src ./src
COPY bunfig.toml tsconfig.json postcss.config.cjs tailwind.config.ts components.json ./

RUN bunx tailwindcss -c tailwind.config.ts -i src/index.css -o src/tailwind.css --minify
RUN bun build ./src/index.ts --compile --outfile=server

FROM itzg/minecraft-server:latest

ENV CONTROL_PORT=3000

# ENV EULA="TRUE"
# ENV TYPE="PAPER"
# ENV VERSION="1.20.1"

ENV SERVER_NAME="Names Are Hard"
ENV GENERIC_PACKS="/data/Liminal_Industries_Server-1.19.3.zip"
# ENV MOTD="WELCOME TO THE RICEFIELDS"
# ENV MEMORY="4G"
# ENV DIFFICULTY="normal"
# ENV MODE="survival"
# ENV VIEW_DISTANCE=10
# ENV SPAWN_PROTECTION=0
# ENV MAX-PLAYERS=6

# World settings
# ENV LEVEL_TYPE="minecraft:normal"
# ENV SEED=""
# ENV GENERATE_STRUCTURES="true"

WORKDIR /app
COPY --from=builder /build/server ./server
COPY docker/start.sh /app/docker/start.sh

RUN chmod +x /app/docker/start.sh

ENV CREATE_CONSOLE_IN_PIPE=true

EXPOSE 3000

WORKDIR /data

ENTRYPOINT ["/app/docker/start.sh"]
