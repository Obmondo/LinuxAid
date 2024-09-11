# Copy of
# https://tickets.puppetlabs.com/browse/PUP-1123?focusedCommentId=252304&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-252304

Puppet::Type.type(:info).provide(:log) do
  def exists?
    info(resource[:message])
    true
  end

  def create
    true
  end

  def destroy
    true
  end

end
