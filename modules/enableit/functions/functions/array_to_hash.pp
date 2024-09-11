# Convert Array to Hash
# Eg [{10.10.10.10 => 80}, {10.10.10.220 => 80}] => {10.10.10.10 => 80}, {10.10.10.220 => 80}
function functions::array_to_hash (
  Array $array,
) {
  $array.reduce({}) |$x, $y| {
    $x + $y
  }
}
