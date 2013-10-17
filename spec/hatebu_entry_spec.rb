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
          @hent.params.update(of: i*20)
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

describe HatebuEntry::Entry do
  let(:ent) { HatebuEntry::Entry }
  before(:each) do
    @ent1 = ent.new("http://d.hatena.ne.jp/keyesberry/20130304/p1", 20,"知って得する！５５のRubyのトリビアな記法")
    @ent2 = ent.new("http://melborne.github.io/2013/03/04/ruby/", 10,"知って得する！５５のRubyのトリビアな記法")
    @ent3 = ent.new("http://melborne.github.com/2013/03/05/ruby/", 10,"知って得する！５５のRubyのトリビアな記法")
    @ent4 = ent.new("http://melborne.github.com/2013/03/04/ruby/", 10,"５５のRubyのトリビアな記法")
  end

  describe '#homogeneous?' do
    it 'returns true when date and title are same' do
      expect(@ent1.homogeneous? @ent2).to be_true
    end

    it 'returns false when title are same but date are not' do
      expect(@ent1.homogeneous? @ent3).to be_false
    end

    it 'returns false when date are same but title are not' do
      expect(@ent1.homogeneous? @ent4).to be_false
    end
  end

  describe '#merge' do
    it 'merge others count amount to self count' do
      merged = @ent1.merge(@ent2)
      expect(merged.count).to eq 30
    end

    context 'merge when these are homogeneous' do
      it 'should success when they are homogeneous' do
        merged = @ent1.merge(@ent2) { |a, b| a.homogeneous? b }
        expect(merged.count).to eq 30
      end

      it 'should fail when they are not homogeneous' do
        expect{ @ent1.merge(@ent3) { |a, b| a.homogeneous? b } }.to raise_error(HatebuEntry::Entry::MergeError)
      end
    end
  end

  describe ".merge" do
    it "merges same entries" do
      merged = HatebuEntry::Entry.merge([@ent1], [@ent2]) 
      expect(merged.size).to eq 1
    end

    it "don't merge diff entries" do
      merged = HatebuEntry::Entry.merge([@ent1], [@ent4]) 
      expect(merged.size).to eq 2
    end

    it "merge only same entries" do
      merged = HatebuEntry::Entry.merge([@ent1], [@ent4, @ent2]) 
      expect(merged.size).to eq 2
    end

    it "sort merge result in desc count order" do
      merged = HatebuEntry::Entry.merge([@ent4, @ent2], [@ent1]) 
      expect(merged.first.count).to eq 30
    end
  end
end