# Valid Hostnames - May not match Unicode and does not validate against TLD registry
type Simplib::Hostname = Pattern['^(?i-mx:(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]{2}|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\.?)$']
