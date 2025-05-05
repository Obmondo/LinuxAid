# Type to match repo_keyserver
# Regex from: https://github.com/puppetlabs/puppetlabs-apt/blob/main/manifests/key.pp
type Gitlab_ci_runner::Keyserver = Pattern[/\A((hkp|hkps|http|https):\/\/)?([a-z\d])([a-z\d-]{0,61}\.)+[a-z\d]+(:\d{2,5})?(\/[a-zA-Z\d\-_.]+)*\/?$/]

