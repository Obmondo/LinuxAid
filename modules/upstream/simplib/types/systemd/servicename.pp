# Valid systemd service names
type Simplib::Systemd::ServiceName = Pattern['^(([A-Za-z0-9.:_\\\\-])(@[A-Za-z0-9.:_\\\\-])?){1,256}$']
