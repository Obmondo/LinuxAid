# Copy of
# https://tickets.puppetlabs.com/browse/PUP-1123?focusedCommentId=252304&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-252304

Puppet::Type.newtype(:info) do
  desc "Like the notify type, except emits to the client log at the info level, and does *not* change the exit code of puppet (which notify does)."
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Arbitrary name used as identity'
  end

  newparam(:message) do
    desc 'The message to emit (defaults to name if not given).'
    defaultto { @resource[:name] }
  end

end
