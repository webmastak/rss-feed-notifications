# RSS Feed Notifications

Notifications news about the release of a new update for Linux distributive based on rolling releases, such as Manjaro and Arch linux.

This application is based on two crystal shards:
  * https://github.com/jhass/crystal-gobject
  * https://github.com/ruivieira/rss

Works like this - if the publication date is equal to the current date, shows a notification and opens the browser with the news page.


## Dependencies

* [Crystal](http://crystal-lang.org)
* libnotify
* Gtk

## Installation

In the launch shortcut file `rss-feed-notifications.desktop` replace `Icon=quiterss` with your own.

1. `git clone git: //github.com/webmastak/rss-feed-notifications`
2. `cd rss-feed-notifications`
3. `install shards`
4. `crystal build --release --no-debug src/rss-feed-notifications.cr`
5. `cp ~/rss-feed-notifications/rss-feed-notifications ~/.local/bin/rss-feed-notifications`
6. `cp ~/rss-feed-notifications/rss-feed-notifications.desktop ~/.config/autostart/rss-feed-notifications.desktop`
7. `restart system`
8. `enjoy`


## Usage

File `~/.config/rssfeed_config` with settings default to be created automatically:

1. string `news check interval at seconds`
2. string `summary`
3. string `icon notifications`
4. string `url feed`

Replace the parameters with your own.


## Contributing

1. Fork it (<https://github.com/webmastak/rss-feed/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [webmastak](https://github.com/webmastak) - creator and maintainer
