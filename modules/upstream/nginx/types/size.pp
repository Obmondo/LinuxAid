# @summary Type Alias for Nginx::Size
type Nginx::Size = Variant[
  Integer[0],
  Pattern[/\A\d+[k|K|m|M]?\z/],
]
