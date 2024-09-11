Facter.add("php_mod_fpm_ini") do
  confine :osfamily => 'Debian'
  setcode do
    php_mod_file = "" 
    system "dpkg --status php5-fpm 2>/dev/null | grep 'Status: install ok installed' >/dev/null"
    if $?.exitstatus == 0
      php_mod_file = "/etc/php5/fpm"
    end
    php_mod_file
  end
end

Facter.add("php_mod_apache_ini") do
  confine :osfamily => 'Debian'
  setcode do
    php_mod_file = "" 
    system "dpkg --status libapache2-mod-php5 2>/dev/null | grep 'Status: install ok installed' >/dev/null"
    if $?.exitstatus == 0
      php_mod_file = "/etc/php5/apache2"
    end
    php_mod_file
  end
end
