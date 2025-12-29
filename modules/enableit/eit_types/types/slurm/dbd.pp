type Eit_types::Slurm::Dbd = Struct[{
  Optional['innodb_buffer_pool_size'] => Pattern[/^\d+[MG]$/],  # e.g. '3G' or '512M'
  Optional['innodb_lock_wait_timeout'] => Integer,              # e.g. 500
  Optional['innodb_log_file_size']     => Pattern[/^\d+[MG]$/], # e.g. '512M'
  'storagehost'                        => String,               # e.g. 'localhost'
  Optional['storagecharset']           => String,               # default: utf8
  Optional['storagecollate']           => String,               # default: utf8_general_ci
}]
