# @summary Valid rpm release fields.
# It may not contain a dash.
# Output of `rpm -q --queryformat '%{release}\n' package`.
# Examples 3.4 3.4.el6, 3.4.el6_2
# @see http://ftp.rpm.org/max-rpm/ch-rpm-file-format.html
type Yum::RpmRelease = Pattern[/\A([^-]+)\z/]
