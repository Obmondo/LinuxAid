# List of string, which are class parameters
# Values always need to be declared in the class file and not in
# hiera, otherwise puppet AST, wont have the default values
type Eit_types::Encrypt::Params = Array[String]
