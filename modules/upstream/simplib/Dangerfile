# Knowing if a change is "trivial" or not may have an effect on multiple tests
declared_trivial = (github.pr_title.match(/^(?:WIP: ?)?\(SIMP-MAINT/) || github.pr_body.match(/^#trivial/))

# Show our appreciation.
unless github.api.organization_member?('simp', github.pr_author)
  message(':tada: Thanks for your contribution!')
end

# Don't allow Work in Progress PRs to merge
fail('PR is classed as Work in Progress') if github.pr_title.start_with? 'WIP:'

# Various failure modes for PR message formatting
if github.pr_title =~ /^(?:WIP: ?)?\(SIMP-\d{1,5}\) [[:print:]]+/
  bad_pr_message ||= true
  fail 'PR title improperly formated'
end

if github.pr_title.length > 50
  bad_pr_message ||= true
  fail 'PR title is too long'
end

if (github.pr_body.split.size < 2 || github.pr_body.length < 5)
  bad_pr_message ||= true
  fail 'PR message body is not long enough'
end

if github.pr_body.lines.map {|line| line.length > 72 }.include? true
  bad_pr_message ||= true
  warn 'PR message body contains long lines'
end

# Include this help message if any of the PR message checks failed or warned
if bad_pr_message
  pr_err_msg = "Please review the project's [commit message conventions]"
  pr_err_msg << "(httsp://simp.readthedocs.io/en/master/contributors_guide/Contribution_Procedure.html?utm_source=danger#commit-message-conventions)"
  message pr_err_msg
end

# Discourage change-sets over 200 lines of code; fail if it is "trivial."
# See: http://support.smartbear.com/support/media/resources/cc/book/code-review-cisco-case-study.pdf#page=16
case
when git.lines_of_code > 400
  warn 'This PR is **very large**.  Consider splitting it up into multiple smaller PRs.', :sticky => true
when git.lines_of_code > 200
  if declared_trivial
    fail 'Trival change-sets must be 200 lines or fewer.'
  else
    warn 'This is a large PR.  Consider splitting it up into multiple smaller PRs.', :sticky => true
  end
end

# vi:ts=2:sw=2:et:ft=ruby
