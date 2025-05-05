# @summary A struct of all possible additionl options for gitlab_ci_runner::register
type Gitlab_ci_runner::Register = Struct[{
  Optional[description]     => String[1],
  Optional[info]            => Hash[String[1],String[1]],
  Optional[active]          => Boolean,
  Optional[locked]          => Boolean,
  Optional[run_untagged]    => Boolean,
  Optional[tag_list]        => Array[String[1]],
  Optional[access_level]    => Enum['not_protected', 'ref_protected'],
  Optional[maximum_timeout] => Integer,
}]
