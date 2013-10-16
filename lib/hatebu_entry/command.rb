require 'thor'

class HatebuEntry::Command < Thor
  desc "get [URL]", "Get Hatena bookmark entries for URL"
  option :sort, aliases:"-s", default:"count"
  option :pages, aliases:"-p", default:0
  def get(url)
    hbent = HatebuEntry.new(url, options[:sort])
    pretty_print hbent.entries(options[:pages].to_i)
  rescue
    abort "something go wrong."
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