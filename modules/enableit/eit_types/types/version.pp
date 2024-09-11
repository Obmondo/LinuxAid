# Version
# NOTE: Regex may not work for all types of versioning numbers current
type Eit_types::Version = Variant[Pattern[/^(\d+\.)?(\d+\.)?(\d+)$/],Eit_types::Package_version]
