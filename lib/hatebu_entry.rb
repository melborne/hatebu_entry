require "hatebu_entry/version"
require 'hatebu_entry/command'
require 'open-uri'
require 'json'
require 'date'
require 'cgi'

require 'nokogiri'

class HatebuEntry
  # link: uri string
  # count: integer
  # title: string
  class Entry < Struct.new(:link, :count, :title)
    alias :url :link
    alias :bookmarks :count
    def date
      @date ||= Date.parse(link)
    rescue ArgumentError
      nil
    end

    def to_s
      "%5d: %s (%s)" % [count, title, link]
    end

    # to find same entry but other hosts
    def homogeneous?(other)
      return false if self == other
      return nil if [self, other].any? { |e| e.date.nil? }
      self.date == other.date &&
          title_similar?(self.title, other.title)
    end
    alias :same? :homogeneous?

    def title_similar?(a, b)
      a, b = [a, b].map { |str| str.gsub(/\w+/, '')[0..5] }
      a == b
    end
    private :title_similar?

    class MergeError < StandardError; end

    # Merge its count
    def merge(other)
      count = self.count + other.count
      if block_given? && !yield(self, other)
        raise MergeError, "They can't merge"
      else
        Entry.new(self.link, count, self.title)
      end
    end

    # Merge two entry lists
    def self.merge(ls_a, ls_b)
      if [ls_a, ls_b].all? { |ls| ls.is_a? Entry }
        raise ArgumentError, 'Arguments must be entry objects'
      end
      entries = []
      ls_a.each do |a|
        if m = ls_b.detect { |b| a.homogeneous? b }
          entries.push a.merge(m)
          ls_b.delete(m)
        else
          entries.push a
        end
      end
      entries + ls_b
    end
  end

  attr_accessor :params
  #sort: count, eid or hot
  def initialize(site, sort='count')
    @params = {url: site, sort: sort, of: 0*20}
  end

  def entries(pages=0)
    if pages <= 0
      get_entries(:jsonp) # get 10 entries with jsonp
    else
      # get 20 entries per page with html
      mutex = Mutex.new
      pages.times.map { |i|
        Thread.fork(i) do |_i|
          mutex.synchronize {
            params.update(of: _i*20)
            get_entries(:html)
          }
        end
      }.map(&:value).flatten
    end
  end

  def get_entries(api)
    entries = 
      case api
      when :jsonp then parse_jsonp(call_hatena_entry_api :jsonp)
      when :html  then parse_html(call_hatena_entry_api :html)
      end
    entries.map { |h| Entry.new h['link'], Integer(h['count']), h['title'] }
  end

  def call_hatena_entry_api(api)
    uri = {jsonp: build_uri('/json?'), html: build_uri('?')}[api]
    get uri
  end

  def get(uri)
    open(uri).read
  rescue => e
    abort "HTTP Access Error: #{e.response}"
  end

  HatenaURI = "http://b.hatena.ne.jp/entrylist"

  def build_uri(joint, params=@params)
    HatenaURI + joint + build_params(params)
  end

  def build_params(params)
    params.map { |k, v| "#{h k}=#{h v}" } * '&'
  end

  def h(str)
    CGI.escape(str.to_s)
  end

  def parse_jsonp(jsonp)
    jsonp.scan(/{.+?}/).map { |data| JSON.parse data }
  end

  def parse_html(html)
    entries = []
    doc = Nokogiri::HTML(html)
    doc.css('li.entry-unit').each do |ent|
      count = ent['data-bookmark-count'].to_i
      a = ent.at('.entry-contents a')
      title, href = a['title'], a['href']
      entries << {'link' => href, 'count' => count, 'title' => title}
    end
    entries
  end
end
