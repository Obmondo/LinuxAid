# Matches valid cron weekday parameter
#
# Tested with Rubular: https://rubular.com/r/uuFFu5ISzdRL7l
type Simplib::Cron::WeekDay_entry = Variant[Integer[0,7],Pattern['^(?x)(?:\*|
(?i)(?:SUN|MON|TUE|WED|THU|FRI|SAT)|
(?:\*\/(?:[0-7]))|
(?:(?:[0-7])(?:(?:-[0-7])(?:\/[0-7])?)?)
)$']]
