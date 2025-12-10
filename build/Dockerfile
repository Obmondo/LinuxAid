FROM ruby:3.1-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    nodejs                     \
    cmake \
    pkg-config \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Puppet
RUN gem install puppet -v '~> 8.0' --no-document

# Install octocatalog-diff
RUN gem install octocatalog-diff --no-document

# Create working directory
WORKDIR /workspace

# Set environment variables
ENV OCTOCATALOG_DIFF_CONFIG_FILE=/workspace/.octocatalog-diff.cfg.rb

# Default command
CMD ["octocatalog-diff", "--help"]
