# Environment variables for a GitLab runner ("environment" in config.toml),
# as KEY=value strings. Quotes, backslashes, '|' and '&' are not allowed in
# the value, as it is written into the TOML config.
type Eit_types::Gitlab::Runner::Environment = Array[Pattern[/\A[A-Za-z_][A-Za-z0-9_]*=[^"'\\|&\n]*\z/]]
