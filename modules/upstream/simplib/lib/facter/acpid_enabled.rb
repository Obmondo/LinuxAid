# _Description_
#
# Return true if ACPI is available on the system.
#
if Facter.value(:kernel).downcase == "linux" then
  Facter.add("acpid_enabled") do
    setcode do
      File.exist?('/proc/acpi/event')
    end
  end
end
