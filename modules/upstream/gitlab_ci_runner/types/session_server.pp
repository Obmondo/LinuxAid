# @summary Gitlab Runner session_server configuration
type Gitlab_ci_runner::Session_server = Struct[
  {
    listen_address    => String[1],
    advertise_address => String[1],
    session_timeout   => Optional[Integer],
  }
]
