# this regex rejects any path component that is a / or a NUL
type Tea::Unixpath = Pattern[/^\/([^\/\0]+(\/)?)+$/]
