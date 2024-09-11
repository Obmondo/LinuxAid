# Valid $service_ensure parameter to Cron.
type Cron::Service_ensure =  Variant[
  Boolean,
  Enum['running','stopped']
]
