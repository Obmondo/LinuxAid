# interactive_shell_users

Facter.add('local_users') do
  setcode do
    users_with_ids = {}

    shell_output = Facter::Core::Execution.exec("cat /etc/passwd | grep '/bin/[bcz][a]sh' | cut -d ':' -f 1,3,7")

    shell_output.each_line do |line|
      username, uid, shell = line.strip.split(':')
      users_with_ids[username] = { 'id' => uid, 'shell' => shell }
    end

    users_with_ids
  end
end
