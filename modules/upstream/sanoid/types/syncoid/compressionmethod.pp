# Valid compression methods for syncoid
type Sanoid::Syncoid::CompressionMethod = Enum[
  'gzip',
  'pigz-fast',
  'pigz-slow',
  'zstd-fast',
  'zstd-slow',
  'lz4',
  'xz',
  'lzo',
  'none',
]
