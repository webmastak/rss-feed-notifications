require "rss"
require "file"
require "gobject/gio"
require "gobject/notify"

LibNotify.init("rss-feed-notifications")

set_refresh = 3600
set_summary = "Forum Manjaro"
set_icon = "application-rss+xml-symbolic"
set_url = "https://forum.manjaro.org/c/announcements/stable-updates.rss"
config = "#{set_refresh}\n#{set_summary}\n#{set_icon}\n#{set_url}\n"

XDG_CONFIG_HOME = ENV["XDG_CONFIG_HOME"]? || File.expand_path("~/.config")
PATH_LOCK = File.join(XDG_CONFIG_HOME, "rssfeed_lock")
PATH_CONF = File.join(XDG_CONFIG_HOME, "rssfeed_config")
PATH = File.join(XDG_CONFIG_HOME, "rssfeed_history")

unless File.exists? PATH
  File.write PATH, ""
end

unless File.exists? PATH_CONF
  File.write PATH_CONF, config
end

conf = File.read(PATH_CONF).split("\n")
refresh_interval = conf.to_a.first.to_i
summary = conf.to_a.skip(1).first
icon = conf.to_a.skip(2).first
feed = RSS.parse conf.to_a.skip(3).first

loop do
  counter = 0
  feed.items.each do |e|
    File.open(PATH, "r+") do |file|
      counter += 1
      if counter == 1
        file << "#{e.title}\n#{e.link}\n#{e.pubDate}"
      end
    end
  end

  h = File.read(PATH).split("\n").reverse
  body = h.to_a.skip(2).first.split(" - ").first
  url = h.to_a.skip(1).first
  p_date = h.to_a.first.split("#{Time.now.year}").first
  pub_date = p_date.split(" ").skip(1).first.to_i
  current_date = Time.now.to_s("%e").to_i
  compare_date = pub_date == current_date || pub_date+1 == current_date ? 1 : 0

  notification = Notify::Notification.build do |n|
    n.summary = summary
    n.body = body
    n.urgency = :normal
    n.icon_name = icon
  end

  if compare_date == 1
    unless File.exists? PATH_LOCK
      notification.update
      Gio::AppInfo.launch_default_for_uri(url, nil)
      File.write PATH_LOCK, p_date
    end
  else
    File.delete PATH_LOCK if File.exists? PATH_LOCK
  end

  sleep refresh_interval
end
