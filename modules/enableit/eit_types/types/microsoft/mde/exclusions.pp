# Microsoft Defender Exclusions
type Eit_types::Microsoft::Mde::Exclusions = Struct[{
    excludedFileExtension => Optional[Array[String]],
    excludedDirectory     => Optional[Array[Stdlib::Unixpath]],
    excludedPath          => Optional[Array[Stdlib::Unixpath]],
    excludedFileName      => Optional[Array[String]],
}]

