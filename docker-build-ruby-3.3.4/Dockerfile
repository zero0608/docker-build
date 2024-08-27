# Use a smaller base image for building
FROM debian:bullseye-slim AS build

# Set environment variables
ENV PATH="/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
ENV RUBY_VERSION="3.3.4"
ENV NODE_VERSION="18"
ENV RBENV_ROOT="/usr/local/rbenv"

# Install dependencies and remove cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libyaml-dev \
    libreadline-dev \
    bash \
    nodejs \
    npm \
    tzdata \
    imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rbenv and Ruby
RUN git clone --depth 1 https://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
    && git clone --depth 1 https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
    && git clone --depth 1 https://github.com/jf/rbenv-gemset.git ${RBENV_ROOT}/plugins/rbenv-gemset \
    && ${RBENV_ROOT}/plugins/ruby-build/install.sh \
    && rbenv install $RUBY_VERSION \
    && rbenv global $RUBY_VERSION

# Install Node.js using n
RUN npm install -g n \
    && n $NODE_VERSION

# Install Rails and Bundler
RUN gem install bundler rails

# Create a minimal runtime image
FROM debian:bullseye-slim

# Set environment variables
ENV PATH="/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
ENV RUBY_VERSION="3.3.4"
ENV NODE_VERSION="18"
ENV RBENV_ROOT="/usr/local/rbenv"

# Install runtime dependencies, including PostgreSQL libraries and client
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    procps \
    sudo \
    libpq5 \
    libyaml-dev \
    libpq-dev \
    build-essential \
    libffi-dev \
    postgresql-client \
    nodejs \
    npm \
    tzdata \
    imagemagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy necessary files from build stage
COPY --from=build /usr/local/rbenv /usr/local/rbenv
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/include /usr/local/include
COPY --from=build /usr/local/share /usr/local/share
COPY --from=build /usr/local/n /usr/local/n

# Add user and group
RUN groupadd dev && useradd -m -g dev dev

# Grant passwordless sudo to dev user
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /app

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Default command
ENTRYPOINT ["/docker-entrypoint.sh"]
