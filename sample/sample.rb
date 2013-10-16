require 'hatebu_entry'

githubio = 'http://melborne.github.io'
githubcom = 'http://melborne.github.com'
hatena = 'http://d.hatena.ne.jp/keyesberry'

def get_entries(url, pages=1)
  puts "Bookmark entries retrieving from #{url}..."
  HatebuEntry.new(url).entries(pages).tap do |s|
    puts "#{s.size} entries retrieved."
  end
end

entries = [githubio, githubcom, hatena].map { |url| get_entries url, 2 }

puts "\nMerging entries..."
merged = entries.inject { |mem, ent| HatebuEntry::Entry.merge mem, ent }

puts "\nFollowing is top 20 entries from 3 sites."
puts
puts merged.lazy
           .sort_by{ |e| -e.count }
           .map { |h| "%i: %s (%s)" % [h.count, h.title, h.link] }
           .take(20)
