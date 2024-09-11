# @summary Valid rpm version fields.
# It may not contain a dash.
# Output of `rpm -q --queryformat '%{version}\n' package`.
# Examples 3.4, 2.5.alpha6
# @see http://ftp.rpm.org/max-rpm/ch-rpm-file-format.html
type Yum::RpmVersion = Pattern[/\A([^-]+)\z/]
