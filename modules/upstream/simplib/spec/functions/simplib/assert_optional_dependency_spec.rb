require 'spec_helper'

describe 'simplib::assert_optional_dependency' do
  let(:source_metadata) {
    {
      'name'    => 'my/module',
      'version' => '1.2.3',
      'simp'    => {
        'optional_dependencies' => [
          {
            'name'                => 'dep-one',
            'version_requirement' => '>= 0.0.1 < 2.0.0'
          },
          {
            'name'                => 'dep/two'
          }
        ]
      }
    }
  }

  let(:dep_one_metadata) {
    {
      'name'    => 'dep/one',
      'version' => '1.0.0'
    }
  }

  let(:dep_two_metadata) {
    {
      'name'    => 'dep-two',
      'version' => '3.4.5'
    }
  }

  let(:dep_one_bad_author) {
    {
      'name'    => 'narp/one',
      'version' => '1.0.0'
    }
  }

  let(:dep_one_bad_version) {
    {
      'name'    => 'dep/one',
      'version' => '5.5.5'
    }
  }

  context 'with a source module' do
    it 'should run with no errors' do
      subject.func.expects(:call_function).with('load_module_metadata', 'my/module').returns(source_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'one').returns(true).once
      subject.func.expects(:call_function).with('load_module_metadata', 'one').returns(dep_one_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'two').returns(true).once
      subject.func.expects(:call_function).with('load_module_metadata', 'two').returns(dep_two_metadata).once

      is_expected.to run.with_params('my/module')
    end

    it 'should fail on one missing module' do
      subject.func.expects(:call_function).with('load_module_metadata', 'my/module').returns(source_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'one').returns(true).once
      subject.func.expects(:call_function).with('load_module_metadata', 'one').returns(dep_one_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'two').returns(false).once
      subject.func.expects(:call_function).with('load_module_metadata', 'two').never

      expect{is_expected.to run.with_params('my/module')}.to raise_error(%r(optional dependency 'two' not found)m)
    end

    it 'should fail on all missing modules' do
      subject.func.expects(:call_function).with('load_module_metadata', 'my/module').returns(source_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'one').returns(false).once
      subject.func.expects(:call_function).with('load_module_metadata', 'one').never
      subject.func.expects(:call_function).with('simplib::module_exist', 'two').returns(false).once
      subject.func.expects(:call_function).with('load_module_metadata', 'two').never

      expect{is_expected.to run.with_params('my/module')}.to raise_error(%r(optional dependency 'one' not found.+optional dependency 'two' not found)m)
    end
  end

  context 'with a target module' do
    before(:each) do
      subject.func.expects(:call_function).with('load_module_metadata', 'my/module').returns(source_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'two').never
      subject.func.expects(:call_function).with('load_module_metadata', 'two').never
    end

    context 'that exists' do
      before(:each) do
        subject.func.expects(:call_function).with('simplib::module_exist', 'one').returns(true).once
      end

      context 'valid' do
        before(:each) do
          subject.func.expects(:call_function).with('load_module_metadata', 'one').returns(dep_one_metadata).once
        end

        it 'long name' do
          is_expected.to run.with_params('my/module', 'dep/one')
        end

        it 'hyphen name' do
          is_expected.to run.with_params('my/module', 'dep/one')
        end

        it 'short name' do
          is_expected.to run.with_params('my/module', 'one')
        end
      end

      context 'invalid' do
        it 'author' do
          subject.func.expects(:call_function).with('load_module_metadata', 'one').returns(dep_one_bad_author).once

          expect{is_expected.to run.with_params('my/module', 'dep/one')}.to raise_error(%r('dep/one' does not match 'narp/one'))
        end

      end
    end

    context 'that is not in the metadata' do
      before(:each) do
        subject.func.expects(:call_function).with('simplib::module_exist', 'one').never
      end

      it 'should fail' do
        subject.func.expects(:call_function).with('simplib::module_exist', 'one').never

        expect{is_expected.to run.with_params('my/module', 'three')}.to raise_error(%r('three' not found in metadata.json))
      end
    end
  end

  context 'with an out of range module' do
    it 'should fail on the invalid module' do
      subject.func.expects(:call_function).with('load_module_metadata', 'my/module').returns(source_metadata).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'one').returns(true).once
      subject.func.expects(:call_function).with('load_module_metadata', 'one').returns(dep_one_bad_version).once
      subject.func.expects(:call_function).with('simplib::module_exist', 'two').returns(true).once
      subject.func.expects(:call_function).with('load_module_metadata', 'two').returns(dep_two_metadata).once

      expect{is_expected.to run.with_params('my/module')}.to raise_error(%r('one-.+' does not satisfy)m)
    end
  end
end
