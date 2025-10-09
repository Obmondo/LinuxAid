
# = Fact - Fullrun =
#
# Set a fact to determine whether or not to do an intensive run.
# This fact may, of course, be used for anything, but this was the purpose for
# which it was created.
#

Facter.add('fullrun') do
  confine kernel: :linux
  setcode do
    `if [ -f /root/.fullrun ]; then echo "true"; else echo "false"; fi`.chomp
  end
end
