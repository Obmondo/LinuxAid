# Data type for Rsyslog Input module input parameters for gssapi.
type Rsyslog::Inputs::Imgssapi = Struct[{
  inputgssserverrun            => Optional[Stdlib::Port],
  inputgssserverservicename    => Optional[String[1]],
  inputgssserverpermitplaintcp => Optional[Enum['on', 'off']],
  inputgssservermaxsessions    => Optional[Integer],
  inputgssserverkeepalive      => Optional[Enum['on', 'off']],
  inputgsslistenportfilename   => Optional[Stdlib::Port],
}]
