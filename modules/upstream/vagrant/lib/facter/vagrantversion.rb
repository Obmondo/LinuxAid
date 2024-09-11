Facter.add('vagrantversion') do
  setcode do
    begin
      Facter::Util::Resolution.exec('vagrant --version').split[-1]
    rescue NoMethodError
      nil
    end
  end
end
