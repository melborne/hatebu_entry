require 'hatebu_entry'

githubio = 'http://melborne.github.io'
githubcom = 'http://melborne.github.com'
hatena = 'http://d.hatena.ne.jp/keyesberry'

def get_entries(url_list, pages=1)
  url_list.map do |url|
    puts "Bookmark entries retrieving from #{url}..."
    HatebuEntry.new(url).entries(pages).tap do |s|
      puts "#{s.size} entries retrieved."
    end
  end
end

gitio_ent, gitcom_ent, hatena_ent = get_entries([githubio, githubcom, hatena], 5)

puts "\nMerging entries..."

entries = HatebuEntry::Entry.merge(gitio_ent, gitcom_ent)
entries = HatebuEntry::Entry.merge(entries, hatena_ent)

puts "\nFollowing is top 20 entries."
puts

puts entries.lazy
            .sort_by{ |e| -e.count }
            .map { |h| "%i: %s (%s)" % [h.count, h.title, h.link] }
            .take(20)
