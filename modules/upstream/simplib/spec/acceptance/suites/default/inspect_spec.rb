require 'spec_helper_acceptance'

test_name 'simplib::inspect function'

def normalize(puppet_log, keep_warning_lines_only = false)
  # remove normal puppet log lines and inspect/simplib::inspect
  # 'puts' lines, as their ordering relative to the Puppet warning
  # lines is non-deterministic
  normalized_lines = puppet_log.split("\n").delete_if do |line|
    line.include?('Loading facts') or
    line.include?('Compiled catalog for') or
    line.include?('Applying configuration version') or
    line.include?('Applied catalog in') or
    line.match(/^Inspect:/)
  end

  if keep_warning_lines_only
    normalized_lines.delete_if { |line| !line.include?('Warning: ') }
  end

  normalized_log = normalized_lines.join("\n")
  # remove color formatting
  yellow_bold_fmt_begin = "\e[1;33m"
  fmt_clear = "\e[0m"
  bad_fmt = "\e[m"  # used at the beginning of Notice lines
  normalized_log.gsub!(yellow_bold_fmt_begin, '')
  normalized_log.gsub!(fmt_clear, '')
  normalized_log.gsub!(bad_fmt, '')
  normalized_log + "\n"
end

describe 'simplib::inspect function' do

  hosts.each do |server|
    context "logs variables with simplib::inspect on #{server}" do
      let (:manifest) {
        <<-EOS
        $var1 = "var1 value"
        $var2 = true
        $var3 = { 'a' => 'b'}
        $var4 = undef

        simplib::inspect('var1', 'oneline_json')
        simplib::inspect('var2', 'oneline_json')
        simplib::inspect('var3', 'oneline_json')
        simplib::inspect('var4', 'oneline_json')
        EOS
      }

      it 'should be log variables' do
        results = apply_manifest_on(server, manifest)

        output = results.output

        # this is ugly, but is logged twice
        expected = <<EOM
Notice: Type => String Content => "var1 value"
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var1]/message: defined 'message' as 'Type => String Content => "var1 value"'
Notice: Type => TrueClass Content => true
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var2]/message: defined 'message' as 'Type => TrueClass Content => true'
Notice: Type => Hash Content => {"a":"b"}
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var3]/message: defined 'message' as 'Type => Hash Content => {"a":"b"}'
Notice: Type => NilClass Content => null
Notice: /Stage[main]/Main/Notify[DEBUG_INSPECT_var4]/message: defined 'message' as 'Type => NilClass Content => null'
EOM

        expect(normalize(results.output)).to eq(expected)
      end
    end
  end
end
