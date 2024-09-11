# Creates plugins in uwsgi via the emporer plugin dir
define uwsgi::plugin (
  $url,
  $plugin_name = $title,
){
  include ::uwsgi

  exec{"uwsgi --build-plugin ${url}":
    cwd     => $::uwsgi::plugins_directory,
    creates => "${::uwsgi::plugins_directory}/${plugin_name}_plugin.so",
  }

}
