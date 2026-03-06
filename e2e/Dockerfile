FROM ruby:3.1-slim

LABEL org.opencontainers.image.title="linuxaid-octocatalog-diff"
LABEL org.opencontainers.image.description="Puppet catalog-diff environment for LinuxAid e2e testing"
LABEL org.opencontainers.image.source="https://gitea.obmondo.com/EnableIT/linuxaid"
LABEL org.opencontainers.image.vendor="Obmondo"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git make nodejs cmake pkg-config \
    build-essential libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global --add safe.directory /workspace

WORKDIR /workspace
COPY e2e/Gemfile e2e/Gemfile.lock* e2e/bin/patch_multi_json.rb e2e/bin/format_catalog_diff.rb ./

RUN bundle install
RUN ruby patch_multi_json.rb
RUN mkdir -p /etc/puppetlabs/puppet/eyaml/keys && \
    bundle exec eyaml createkeys \
      --pkcs7-private-key=/etc/puppetlabs/puppet/eyaml/keys/private_key.pkcs7.pem \
      --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/keys/public_key.pkcs7.pem

ENV OCTOCATALOG_DIFF_CONFIG_FILE=/workspace/.octocatalog-diff.cfg.rb
CMD ["bundle", "exec", "octocatalog-diff", "--help"]
