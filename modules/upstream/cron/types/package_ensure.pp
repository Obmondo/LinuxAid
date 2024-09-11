# Valid $service_ensure parameter to Cron.
type Cron::Package_ensure = Variant[Cron::Package_state,Cron::Deb_version,Cron::Rpm_version]
