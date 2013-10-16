require 'thor'

class HatebuEntry::Command < Thor
  desc "get URL", "Get Hatena bookmark entries for URL"
  option :pages, aliases:"-p", default:0
  option :sort, aliases:"-s", default:"count"
  def get(url)
    entries = HatebuEntry.new(url, options[:sort])
                         .entries(options[:pages].to_i)
    pretty_print begin
      options[:sort]=='count' ? entries.sort_by { |ent| -ent.count } : entries
    end
  rescue
    abort "something go wrong."
  end

  desc "merge *URLs", "Merge counts for same entries on several URLs"
  option :pages, aliases:"-p", default:1
  option :sort, aliases:"-s", default:"count"
  def merge(*urls)
    abort "At least 2 urls needed." if urls.size < 2
    entries = urls.map do |url|
      HatebuEntry.new(url, options[:sort]).entries options[:pages].to_i
    end
    merged = entries.inject {|mem, ent| HatebuEntry::Entry.merge(mem, ent) }
    pretty_print merged.sort_by { |ent| -ent.count }
  end
  
  desc "version", "Show HatebuEntry version"
  def version
    puts "HatebuEntry #{HatebuEntry::VERSION} (c) 2013 kyoendo"
  end
  map "-v" => :version

  no_commands do
    def pretty_print(entries)
      lines = entries.map do |ent|
        "%5d: %s (%s)" % [ent.count, c(ent.title), ent.link]
      end
      puts lines
    end

    def c(str, n='32')
      "\e[#{n}m#{str}\e[0m"
    end
  end
end