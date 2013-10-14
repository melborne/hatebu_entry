require "hatebu_entry/version"
require 'open-uri'
require 'json'
require 'date'
require 'cgi'

require 'nokogiri'

class HatebuEntry
  class Entry < Struct.new(:link, :count, :title)
    alias :url :link
    alias :bookmarks :count
    def date
      @date ||= Date.parse(link)
    rescue ArgumentError => e
      abort "Date parse error: #{e}"
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
