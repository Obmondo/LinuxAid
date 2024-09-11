function thinlinc::dir_to_dirs(Stdlib::Absolutepath $path) {
  $_parts = $path.split('/')[1,-1]

  $_dirs = $_parts[1,-1].reduce(["/${_parts[0]}"]) |Array[Stdlib::Absolutepath] $acc, String $_dir| {
    $acc + ["${acc[-1]}/${_dir}"]
  }

  return $_dirs
}
