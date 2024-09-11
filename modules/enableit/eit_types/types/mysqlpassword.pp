# FIXME: root password may not contain special characters unless it's a newer
# version of
# MySQL... https://stackoverflow.com/questions/21266059/special-characters-in-mysql-password#27760195
#
# If a password is set with weird characters, the Puppetlabs MySQL module
# fails and breaks Puppet completely until the MySQL root password is changed
# into something simpler and the /root/.my.cnf file is updated!
type Eit_types::MysqlPassword = Pattern[/[0-9a-zA-Z_.,-]+/]
