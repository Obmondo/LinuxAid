require 'spec_helper'

# This just gives us a hook so that we can call the function later on
describe 'simplib::stages', type: :class do

  let(:pre_condition) {%(
    define mydef::test (
      $attribute = simplib::dlookup('mydef::test', 'attribute', $title, { 'default_value' => 'lucille2' })
    ){
      notify { "$title says": message => $attribute }
    }

    define mydef::othertest (
      $attribute = simplib::dlookup('mydef::test', 'attribute', { 'default_value' => 'lucille2' })
    ){
      notify { "other $title says": message => $attribute }
    }

    mydef::test { 'gob': }
    mydef::test { 'tobias': }
    mydef::test { 'michael': attribute => 'bananastand' }

    mydef::othertest { 'gob': }
    mydef::othertest { 'tobias': }
    mydef::othertest { 'michael': attribute => 'bananastand' }
  )}

  let(:gob){catalogue.resource('Mydef::Test[gob]')}
  let(:tobias){catalogue.resource('Mydef::Test[tobias]')}
  let(:michael){catalogue.resource('Mydef::Test[michael]')}

  let(:gob_other){catalogue.resource('Mydef::Othertest[gob]')}
  let(:tobias_other){catalogue.resource('Mydef::Othertest[tobias]')}
  let(:michael_other){catalogue.resource('Mydef::Othertest[michael]')}

  it { is_expected.to compile.with_all_deps }

  context 'no overrides' do
    it { expect(gob[:attribute]).to eq('lucille2') }
    it { expect(tobias[:attribute]).to eq('lucille2') }
    it { expect(michael[:attribute]).to eq('bananastand') }
    it { expect(gob_other[:attribute]).to eq('lucille2') }
    it { expect(tobias_other[:attribute]).to eq('lucille2') }
    it { expect(michael_other[:attribute]).to eq('bananastand') }
  end

  context 'overrides' do
    let(:facts){{
      :cache_bust => Time.now.to_s,
      :hieradata => 'simplib_dlookup_overrides'
    }}

    let(:hieradata){ 'simplib_dlookup_overrides' }

    context 'with global overrides' do
      it { expect(gob[:attribute]).to eq('illusions') }
      it { expect(gob_other[:attribute]).to eq('illusions') }
      it { expect(tobias_other[:attribute]).to eq('illusions') }
    end
    context 'with specific overrides' do
      it { expect(tobias[:attribute]).to eq('blueman') }
    end
    context 'with a static value' do
      it { expect(michael[:attribute]).to eq('bananastand') }
      it { expect(michael_other[:attribute]).to eq('bananastand') }
    end
  end
end
