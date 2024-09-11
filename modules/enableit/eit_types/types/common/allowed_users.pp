type Eit_types::Common::Allowed_users = Hash[
  String,
  Optional[Array[String]]]      # Optional as we don't care about the value if
                                # the key is using a knockout prefix
