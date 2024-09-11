# Matches valid cron hour parameter
#
# Tested with Rubular: https://rubular.com/r/y7jCmNCjgTl4kx
type Simplib::Cron::Hour_entry = Variant[Integer[0,23],Pattern['^(?x)(?:\*|
(?:\*\/(?:[01]?\d|2[0-3]))|
(?:(?:[01]?\d|2[0-3])(?:(?:-(?:[01]?\d|2[0-3]))(?:\/(?:[01]?\d|2[0-3]))?)?)
)$']]
