# Matches valid cron minute parameter
#
# Tested with Rubular: https://rubular.com/r/kBrcbFmFldCR7q
type Simplib::Cron::Minute_entry = Variant[Integer[0,59],Pattern['^(?x)(?:\*|
(?:\*\/(?:[0-5]?\d))|
(?:(?:[0-5]?\d)(?:(?:(-|,)(?:[0-5]?\d))?(?:\/(?:[0-5]?\d))?)?)
)$']]
