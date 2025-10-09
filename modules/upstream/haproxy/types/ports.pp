# @summary Port or list of ports for haproxy. Supports `,` seperated list of ports also.
#
type Haproxy::Ports = Variant[Array[Variant[Pattern[/^[0-9]+$/],Stdlib::Port],0], Pattern[/^[0-9,]+$/], Stdlib::Port]
