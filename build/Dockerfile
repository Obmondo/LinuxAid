FROM ruby:3.1-slim

RUN apt-get update && apt-get install -y \
    git make nodejs cmake pkg-config \
    build-essential libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY Gemfile Gemfile.lock* ./
ENV BUNDLE_PATH=/usr/local/bundle
RUN bundle install

ENV OCTOCATALOG_DIFF_CONFIG_FILE=/workspace/.octocatalog-diff.cfg.rb
CMD ["bundle", "exec", "octocatalog-diff", "--help"]
