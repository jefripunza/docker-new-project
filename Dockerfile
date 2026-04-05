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
    && rm -rf /var/lib/apt/lists/*

# --------------------------------------------
# Install additional PHP extensions
# --------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        sockets \
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
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs

# --------------------------------------------
# Install BunJS
# --------------------------------------------
RUN curl -fsSL https://bun.sh/install | bash

# --------------------------------------------
# Install DenoJS (problem)
# --------------------------------------------
RUN curl -fsSL https://deno.land/install.sh | sh

# --------------------------------------------
# Install Golang
# --------------------------------------------
RUN curl -fsSL https://go.dev/dl/go1.25.6.linux-amd64.tar.gz | tar -C /usr/local -xz

# --------------------------------------------
# Install Rust
# --------------------------------------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# --------------------------------------------
# Install Dart
# --------------------------------------------
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/dart.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" > /etc/apt/sources.list.d/dart.list \
    && apt-get update \
    && apt-get install -y dart

# --------------------------------------------
# Install Other Languages
# --------------------------------------------
RUN apt-get update \
    && apt-get install -y \
    # Python
    python3 python3-pip \
    # Java
    default-jdk default-jre \
    # Kotlin
    kotlin \
    # GCC
    gcc \
    # Ruby
    ruby \
    # Erlang
    erlang \
    # Elixir
    elixir \
    # Other
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
# Health check
# --------------------------------------------
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# --------------------------------------------
# Entrypoint
# --------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]
