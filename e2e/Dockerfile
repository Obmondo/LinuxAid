FROM ruby:3.1-slim

RUN apt-get update && apt-get install -y \
    git make nodejs cmake pkg-config \
    build-essential libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && git config --global --add safe.directory /workspace

WORKDIR /workspace
COPY e2e/Gemfile e2e/Gemfile.lock* e2e/bin/patch_multi_json.rb ./
RUN bundle install && ruby patch_multi_json.rb

ENV OCTOCATALOG_DIFF_CONFIG_FILE=/workspace/.octocatalog-diff.cfg.rb
CMD ["bundle", "exec", "octocatalog-diff", "--help"]
