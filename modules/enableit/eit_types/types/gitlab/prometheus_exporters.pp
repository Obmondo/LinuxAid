type Eit_types::Gitlab::Prometheus_exporters = Struct[{
  'redis'     => Optional[Eit_types::Listen],
  'postgres'  => Optional[Eit_types::Listen],
  'puma'      => Optional[Eit_types::Listen],
  'registry'  => Optional[Eit_types::Listen],
  'gitlab'    => Optional[Eit_types::Listen],
}]
