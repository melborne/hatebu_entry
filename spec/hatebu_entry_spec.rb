require 'spec_helper'

describe HatebuEntry do
  it 'should have a version number' do
    HatebuEntry::VERSION.should_not be_nil
  end

  before(:each) do
    FakeWeb.clean_registry
    site = "http://melborne.github.com"
    @hent = HatebuEntry.new(site)
  end

  describe '#build_json_uri' do
    it 'returns json uri for Hatena bookmark entry' do
      expected = "http://b.hatena.ne.jp/entrylist/json?" +
                 "url=http%3A%2F%2Fmelborne.github.com&sort=count&of=0"
      expect(@hent.build_uri '/json?').to eq expected
    end
  end

  describe '#call_hatena_entry_api' do
    it 'returns jsonp data of Hatena bookmark info' do
      uri = @hent.build_uri('/json?')
      mock_hatebu_entry_api(uri)
      expect(@hent.call_hatena_entry_api :jsonp).to match /^\(\[{"link":.+}\]\);$/
    end

    it 'returns empty jsonp data with a no bookmarked site' do
      site = "http://melborne.github.co.jp"
      hent = HatebuEntry.new(site)
      mock_hatebu_entry_api('http://sample.com', 'no_entry.jsonp')
      expect(hent.call_hatena_entry_api :jsonp).to eq "([]);"
    end
  end

  describe '#get_entries' do
    context 'gets Bookmark entries with jsonp' do
      it 'returns entries with an array' do
        uri = @hent.build_uri('/json?')
        mock_hatebu_entry_api(uri)
        entries = @hent.get_entries(:jsonp)
        expect(entries.size).to eq 10
        expect(entries.first).to be_instance_of(HatebuEntry::Entry)
        expect(entries.first.count).to eq 1377
      end
    end

    context 'gets Bookmark entries with html' do
      it 'returns entries with an array' do
        uri = @hent.build_uri('?')
        mock_hatebu_entry_api(uri, 'hatebu_entry0.html')
        entries = @hent.get_entries(:html)
        expect(entries.size).to eq 20
        expect(entries.first).to be_instance_of(HatebuEntry::Entry)
      end
    end
  end

  describe '#parse_jsonp' do
    it 'returns an array of hashes containing entry data' do
      str = fixture('hatebu_entry.jsonp')
      entries = @hent.parse_jsonp(str)
      expect(entries).to be_instance_of(Array)
      expect(entries.first).to be_instance_of(Hash)
    end
  end

  describe '#parse_html' do
    it 'returns an array of hashes containing entry data' do
      str = fixture('hatebu_entry0.html')
      entries = @hent.parse_html(str)
      expect(entries).to be_instance_of(Array)
      expect(entries.first).to be_instance_of(Hash)
    end
  end

  describe '#entries' do
    it 'returns entries with jsonp' do
      uri = @hent.build_uri('/json?')
      mock_hatebu_entry_api(uri)
      entries = @hent.entries
      expect(entries.size).to eq 10
    end

    context 'get entries with html' do
      before(:each) do
        uri = @hent.build_uri('?')
        3.times do |i|
          h = {url: @hent.site, sort: @hent.sort, of: i*20}
          @hent.instance_variable_set("@params", h)
          mock_hatebu_entry_api(uri, "hatebu_entry#{i}.html")
        end
      end

      it 'returns first 20 entries' do
        entries = @hent.entries(1)
        expect(entries.size).to eq 20
      end

      it 'returns first 60 entries' do
        entries = @hent.entries(3)
        expect(entries.size).to eq 60
        expect(entries.last.title).to match /Graphviz/
      end
    end
  end
end
