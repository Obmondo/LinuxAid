type Eit_types::Storage::Quota = Struct[{
  block_soft => Optional[Eit_types::Bytes],
  block_hard => Optional[Eit_types::Bytes],
  inode_soft => Optional[Integer],
  inode_hard => Optional[Integer],
}]
