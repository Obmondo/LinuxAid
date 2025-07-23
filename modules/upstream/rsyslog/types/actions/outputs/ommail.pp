# Struct data type for the Rsyslog E-Mail module's Action options
type Rsyslog::Actions::Outputs::Ommail = Struct[{
    server             => Stdlib::Host,
    port               => Stdlib::Port,
    mailfrom           => Pattern[/.+@.+\..+/],
    mailto             => Pattern[/.+@.+\..+/],
    'subject.template' => Optional[String[1]],
    'subject.text'     => Optional[String[1]],
    'body.enable'      => Optional[Enum['on', 'off']],
    template           => Optional[String[1]],
}]
