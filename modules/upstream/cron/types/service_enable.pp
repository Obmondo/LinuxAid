# Valid $service_enable parameter to Cron.
type Cron::Service_Enable = Variant[
  Boolean,
  Enum['manual','mask']
]
