# frozen_string_literal: true

Puppet::Type.type(:posix_acl).provide(:genericacl, parent: Puppet::Provider) do # rubocop:disable Lint/EmptyBlock
end
