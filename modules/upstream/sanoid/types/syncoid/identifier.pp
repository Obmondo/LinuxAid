# Valid identifier chars: a-z, A-Z, 0-9, _, -, :, .
type Sanoid::Syncoid::Identifier = Pattern[/^[a-zA-Z0-9_\-:.]+$/]
