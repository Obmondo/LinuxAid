def verify_concat_fragment_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  (content.split("\n") & expected_lines).should == expected_lines
end

def verify_concat_fragment_exact_contents(subject, title, expected_lines)
  content = subject.resource('concat::fragment', title).send(:parameters)[:content]
  content.split(%r{\n}).reject { |line| line =~ %r{(^#|^$|^\s+#)} }.should == expected_lines
end

def verify_exact_contents(subject, title, expected_lines)
  content = subject.resource('file', title).send(:parameters)[:content]
  content.split(%r{\n}).reject { |line| line =~ %r{(^#|^$|^\s+#)} }.should == expected_lines
end
