# _Description_
#
# Return true if system booted via UEFI Secure Boot
#
Facter.add('simplib__secure_boot_enabled') do
  confine kernel: 'Linux'

  setcode do
    secure_boot_status = false
    Dir.glob('/sys/firmware/efi/efivars/SecureBoot-*').each do |file|
      begin
        File.open(file, 'r') do |hexcode|
          # skip leading status codes
          hexcode.read(4)
          code = hexcode.read
          # If we didn't get any data, unpacking will fail
          secure_boot_status = (code.unpack('H*').first.to_i == 1) if code
        end
      rescue Errno::EPERM, Errno::EACCES
        next
      end

      break if secure_boot_status
    end

    setup_mode_status = false
    if secure_boot_status
      Dir.glob('/sys/firmware/efi/efivars/SetupMode-*').each do |file|
        begin
          File.open(file, 'r') do |hexcode|
            # skip leading status codes
            hexcode.read(4)
            code = hexcode.read
            # If we didn't get any data, unpacking will fail
            setup_mode_status = (code.unpack('H*').first.to_i == 0) if code
          end
        rescue Errno::EPERM, Errno::EACCES
          next
        end

        break if setup_mode_status
      end
    end

    secure_boot_status & setup_mode_status
  end
end
