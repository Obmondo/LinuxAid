# @summary type to enforce the different installation methods for our exporters.
type Prometheus::Install = Enum['url', 'package', 'none']
