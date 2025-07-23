# Struct data type alias for MySQL Rsyslog output module.
#
# @see https://www.rsyslog.com/doc/v8-stable/configuration/modules/ommysql.html Rsyslog MySQL output module
type Rsyslog::Actions::Outputs::Ommysql = Struct[{
    server                => Stdlib::Host,
    socket                => Optional[Stdlib::Absolutepath],
    db                    => String[1],
    uid                   => String[1],
    pwd                   => String[1],
    serverport            => Optional[Stdlib::Port],
    'mysqlconfig.file'    => Optional[Stdlib::Absolutepath],
    'mysqlconfig.section' => Optional[String[1]],
    template              => Optional[String[1]],
}]
