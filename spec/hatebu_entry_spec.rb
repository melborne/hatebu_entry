require 'spec_helper'

describe HatebuEntry do
  it 'should have a version number' do
    HatebuEntry::VERSION.should_not be_nil
  end

  it 'should do something useful' do
    false.should be_true
  end
end
