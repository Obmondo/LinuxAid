# Matches valid cron month parameter
#
# Tested with Rubular: https://rubular.com/r/TSDNxt1rcWkb8U
type Simplib::Cron::Month_entry = Variant[Integer[1,12],Pattern['^(?x)(?:\*|
(?i)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)|
(?:\*\/(?:[1-9]|1[012]))|
(?:(?:[1-9]|1[012])(?:(?:-(?:[1-9]|1[012]))(?:\/(?:[1-9]|1[012]))?)?)
)$']]
