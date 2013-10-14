$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hatebu_entry'
require 'fakeweb'

module HelperMethods
  def fixture(name)
    File.read("#{__dir__}/support/#{name}")
  end

  def mock_hatebu_entry_api(uri, fix='hatebu_entry.jsonp')
    response ||= fixture(fix)
    FakeWeb.register_uri(:get, uri, :body => response)
  rescue Errno::ENOENT
    response = fixture("no_entry.jsonp")
    retry
  end
end

RSpec.configuration.include(HelperMethods)