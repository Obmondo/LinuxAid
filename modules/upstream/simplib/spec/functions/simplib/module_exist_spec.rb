require 'spec_helper'

describe 'simplib::module_exist' do
  context 'with a valid module' do
    it { is_expected.to run.with_params('simplib').and_return(true) }
  end

  context 'with an author' do
    it 'should be valid with simp/simplib' do
      is_expected.to run.with_params('simp/simplib').and_return(true)
    end

    it 'should be invalid with foo/simplib' do
      is_expected.to run.with_params('foo/simplib').and_return(false)
    end
  end

  context 'with an invalid module' do
    it { is_expected.to run.with_params('superbad').and_return(false) }
  end
end
