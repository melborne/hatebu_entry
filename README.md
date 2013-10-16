# HatebuEntry

HatebuEntry is a tool for retrieving and handling Hatena Bookmark entry lists written in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'hatebu_entry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hatebu_entry

## Usage

Try this;

```ruby
require 'hatebu_entry'

uri = 'http://d.hatena.ne.jp'
hent = HatebuEntry.new(uri)

puts hent.entries
```

You will get like this.

     6691: 僕は自分が思っていたほどは頭がよくなかった - しのごの... (http://d.hatena.ne.jp/tictac/20120110/p1)
     5788: 「 2 」か「 9 」で割ってみる - ナイトシフト (http://d.hatena.ne.jp/nightshift/20090121/1232521713)
     5605: 読みやすい文章を書くための技法 - RyoAnna’s iPhone Blog (http://d.hatena.ne.jp/RyoAnna/20100824/1282660678)
     4483: この「いじめ対策」はすごい！ - 森口朗公式ブログ (http://d.hatena.ne.jp/moriguchiakira/20090520)
     4167: 知らないと損する英語の速読方法（1） - 一法律学徒の英語... (http://d.hatena.ne.jp/kousuke-i/20081203/1228314824)
     3973: パワポでもここまでできる！米財務省から学べる美しい資... (http://d.hatena.ne.jp/stj064/20120401/p1)
     3968: デジタル一眼レフカメラの基礎から実践まで - #RyoAnnaBlog (http://d.hatena.ne.jp/RyoAnna/20120501/1335884196)
     3853: 『忙しい人』と『仕事ができる人』の２０の違い (http://d.hatena.ne.jp/favre21/20070927)
     3717: MacBook Air 11インチ欲しい！とは - はてなキーワード (http://d.hatena.ne.jp/keyword/MacBook%20Air%2011%A5%A4%A5%F3%A5%C1%CD%DF%A4%B7%A4%A4%A1%AA)
     3715: おさえておきたいメールで使う敬語 - かみんぐあうとっ (http://d.hatena.ne.jp/komoko-i/20110524/p1)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
