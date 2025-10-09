# @summary Type Alias for Nginx::DebugConnection
type Nginx::DebugConnection = Variant[Stdlib::Host, Stdlib::IP::Address, Enum['unix:']]
