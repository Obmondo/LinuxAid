# RustFS release tag, e.g. 1.0.7 or 1.0.0-rc.6
# https://github.com/rustfs/rustfs/releases
type Eit_types::Rustfs::Version = Pattern[/\A[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?\z/]
