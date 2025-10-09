# Valid Hostnames with ports - May not match Unicode and does not validate against TLD registry
type Simplib::Hostname::Port = Pattern['^(?i-mx:(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]{2}|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\.?):([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$']
