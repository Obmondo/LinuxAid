# Originally from stdlib's is_absolute_path, which had it from 2.7.x's lib/puppet/util.rb Puppet::Util.absolute_path?
# slash = '[\\\\/]'
# name = '[^\\\\/]+'
# %r!^(([A-Z]:#{slash})|(#{slash}#{slash}#{name}#{slash}#{name})|(#{slash}#{slash}\?#{slash}#{name}))!i,
type Tea::Windowspath = Pattern[/^(([a-zA-Z]:[\\\/])|([\\\/][\\\/][^\\\/]+[\\\/][^\\\/]+)|([\\\/][\\\/]\?[\\\/][^\\\/]+))/]
