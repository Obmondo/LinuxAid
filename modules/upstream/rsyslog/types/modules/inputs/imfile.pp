# Data type for Rsyslog Input module parameters for file inputs.
type Rsyslog::Modules::Inputs::Imfile = Struct[{
    mode               => Optional[Enum['inotify', 'polling']],
    readtimeout        => Optional[Integer],
    timeoutgranularity => Optional[Enum['on', 'off']],
    sortfiles          => Optional[Enum['on', 'off']],
    pollinginterval    => Optional[Integer],
}]
