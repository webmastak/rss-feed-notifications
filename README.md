# RSS Feed Notifications for Manjaro and Arch Linux

Notifications news about the release of a new update for Linux distributive based on rolling releases, such as Manjaro and Arch linux.

This application is based on two crystal shards:
  * https://github.com/jhass/crystal-gobject
  * https://github.com/ruivieira/rss

It works like this - if the date of publication coincides with the current date, a notification is displayed and when you click on the notification, a browser opens with a news page.


## Dependencies

* [Crystal](http://crystal-lang.org)
* libnotify
* Gtk

## Installation

In the launch shortcut file `rss-feed-notifications.desktop` replace `Icon=quiterss` with your own.

1. `git clone git://github.com/webmastak/rss-feed`
2. `cd rss-feed`
3. `make`
7. `restart system`
8. `enjoy`


## Usage

File `~/.config/<application-name>/config.yml` with settings default to be created automatically when you first start the application, with settings:

* `days:` example the news came out on 08/15/2019, and will be show +1 day from the day  release, until it is viewed from the notification
* `refresh:` news check interval at minutes
* `label:` notification label in your language, default: Show
* `summary:` summary
* `url:` url feed
* `icon:` if you want to put your icon for notification, replace for example `icon: nil` with `icon: your-icon-symbolic`

You can change the parameters.


## Contributing

1. Fork it (<https://github.com/webmastak/rss-feed/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [webmastak](https://github.com/webmastak) - creator and maintainer
