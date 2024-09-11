# systemd.time(7) specification with support for repetition values and "last day
# of month" operator.
#
# Ignores the special expressions in favor of explicity.
type Eit_types::SystemdTime = Struct[{
  # array of weekdays (should be joined with `,`)
  weekday => Optional[
    Array[Enum['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], 1, 7]
  ],
  year => Variant[
    Enum['*'],
    Array[Integer[1970,default]]
  ],
  # month may either be a wildcard or an integer array (should be joined with `,`)
  month => Variant[
    Enum['*'],
    Array[Integer[1,12], 1, 12]
  ],
  # day may either be a wildcard, an integer array or a pattern, optionally
  # prefixed with the "last day of month" operator `~` and optionally suffixed
  # with a repetition value
  day => Variant[
    Enum['*'],
    Array[Integer[1,31], 1, 31],
    Pattern['~?([0-2][0-9]|3[01])(/[0-9]+)?']
  ],
  # wildcard, integer, integer array (should be joined with `,`)
  hour => Variant[
    Enum['*'],
    Integer[0,23],
    Array[Integer[0,23], 1, 23],
    Pattern['(\*|([01][0-9]|2[0-3]))/[0-9]+']
  ],
  minute => Variant[
    Enum['*'],
    Integer[0,59],
    Array[Integer[0,59]],
    Pattern['(\*/[0-5][0-9])/[0-9]+']
  ],
  second => Variant[
    Enum['*'],
    Integer[0,59],
    Array[Integer[0,59]],
    Pattern['(\*|[0-5][0-9](\.[0-9]{1,6})?)/[0-9]+(\.[0-9]{1,6})?']
  ],
}]
