FROM node:22.22.2-bookworm

ARG PNPM_VERSION=10.12.1

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  SAFE_CHAIN_HOME=/home/node/.safe-chain \
  PATH=/home/node/.safe-chain/bin:${PATH}

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

RUN npm config set fetch-retries 5 \
  && npm config set fetch-retry-factor 2 \
  && npm config set fetch-retry-mintimeout 20000 \
  && npm config set fetch-retry-maxtimeout 120000 \
  && npm config set registry https://registry.npmjs.org/ \
  && npm install -g pnpm@${PNPM_VERSION} \
  && corepack enable \
  && node -v \
  && npm -v \
  && pnpm -v

USER node

RUN curl -fsSL https://github.com/AikidoSec/safe-chain/releases/latest/download/install-safe-chain.sh | sh \
  && safe-chain --version

USER root

RUN ln -sf /home/node/.safe-chain/bin/safe-chain /usr/local/bin/safe-chain

COPY .devcontainer/scripts/compose-wp.sh /usr/local/bin/compose-wp
RUN chmod +x /usr/local/bin/compose-wp

USER node

WORKDIR /workspaces/distroless-wp

CMD ["sleep", "infinity"]
