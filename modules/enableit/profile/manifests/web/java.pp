# Java Profile
class profile::java (
  $version,
  Enum['jre', 'jdk', 'oracle-jre', 'oracle-jdk'] $distribution,
  Optional $use_java_alternative      = undef,
  Optional $use_java_alternative_path = undef,
) {

  class { '::java' :
    distribution          => $distribution,
    java_alternative      => $use_java_alternative,
    java_alternative_path => $use_java_alternative_path,
  }
}
