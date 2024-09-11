# Struct data type for general Rsyslog Action parameters
#
# @author Vox Pupuli <voxpupuli@groups.io>
#
# @see https://www.rsyslog.com/doc/v8-stable/configuration/actions.html#general-action-parameters Rsyslog General Action Parameters
#
type Rsyslog::Actions::Parameters = Struct[{
  'action.writeallmarkmessages'            => Optional[Enum['on', 'off']],
  'action.execonlyeverynthtime'            => Optional[Integer],
  'action.execonlyeverynthtimeout'         => Optional[Integer],
  'action.errorfile'                       => Optional[Stdlib::Absolutepath],
  'action.execonlyonceeveryinterval'       => Optional[Integer],
  'action.execonlywhenpreviousissuspended' => Optional[Enum['on', 'off']],
  'action.repeatedmsgcontainsoriginalmsg'  => Optional[Enum['on', 'off']],
  'action.resumeretrycount'                => Optional[Integer],
  'action.resumeinterval'                  => Optional[Integer],
  'action.reportsuspension'                => Optional[Enum['on', 'off']],
  'action.reportsuspensioncontinuation'    => Optional[Enum['on', 'off']],
  'action.copymsg'                         => Optional[Enum['on', 'off']]
}]
