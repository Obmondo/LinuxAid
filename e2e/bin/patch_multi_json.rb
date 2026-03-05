path = Dir.glob('/usr/local/bundle/gems/multi_json-*/lib/multi_json/adapter.rb').first
abort 'multi_json adapter.rb not found' unless path
src = File.read(path)
patched = src.gsub(
  'options.except(:adapter).freeze',
  '(options.is_a?(Hash) ? options : {}).reject { |k, _| k == :adapter }.freeze'
)
abort 'Pattern not found — already patched or version changed' if src == patched
File.write(path, patched)
puts "Patched #{path}"
