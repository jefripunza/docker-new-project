# ============================================
# FrankenPHP + Code Server + PostgreSQL + MongoDB
# DEV MODE (HTTP only, no auto HTTPS)
# ============================================

FROM dunglas/frankenphp:latest

ENV DEBIAN_FRONTEND=noninteractive
# ENV SERVER_NAME=:80

# --------------------------------------------
# Install system dependencies
# --------------------------------------------
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    git \
    unzip \
    curl \
    nano \
    pkg-config \
    autoconf \
    build-essential \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libxslt1-dev \
    libgmp-dev \
    libsodium-dev \
    libmagickwand-dev \
    imagemagick \
    nmap \
    net-tools \
    dnsutils \
    iputils-ping \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------
# Install additional PHP extensions
# --------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        gd \
        bcmath \
        gmp \
        zip \
        pdo_mysql \
        pdo_pgsql \
        pgsql

# --------------------------------------------
# Install PECL extensions
# --------------------------------------------
RUN             pecl install redis mongodb imagick \
    && docker-php-ext-enable redis mongodb imagick

# --------------------------------------------
# Install Composer
# --------------------------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# --------------------------------------------
# Install NodeJS
# --------------------------------------------
COPY --from=node:latest /usr/local/bin/node /usr/local/bin/node
COPY --from=node:latest /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node:latest /usr/local/lib/node_modules /usr/local/lib/node_modules

# --------------------------------------------
# Install BunJS
# --------------------------------------------
RUN curl -fsSL https://bun.sh/install | bash

# --------------------------------------------
# Install DenoJS
# --------------------------------------------
RUN curl -fsSL https://deno.land/install.sh | sh

# --------------------------------------------
# Install Golang
# --------------------------------------------
RUN curl -fsSL https://go.dev/dl/go1.25.6.linux-amd64.tar.gz | tar -C /usr/local -xz

# --------------------------------------------
# Install code-server
# --------------------------------------------
RUN curl -fsSL https://code-server.dev/install.sh | sh

# --------------------------------------------
# Working directory
# --------------------------------------------
WORKDIR /app

# --------------------------------------------
# Copy Caddyfile & entrypoint
# --------------------------------------------
COPY Caddyfile /etc/frankenphp/Caddyfile
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# --------------------------------------------
# Expose ports
# --------------------------------------------
EXPOSE 80
EXPOSE 8080

# --------------------------------------------
# Entrypoint
# --------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]
