require "rss"
require "file"
require "gobject/notify"
require "gobject/gtk"
require "gobject/gio"

LibNotify.init("rss-feed")

set_count = 1
set_refresh = 3600
set_summary = "Forum Manjaro"
set_icon = "application-rss+xml-symbolic"
set_url = "https://forum.manjaro.org/c/announcements/stable-updates.rss"
conf = "#{set_refresh}\n#{set_icon}\n#{set_url}\n#{set_summary}\n#{set_count}\n"

XDG_CONFIG_HOME = ENV["XDG_CONFIG_HOME"]? || File.expand_path("~/.config")
PATH_LOCK = File.join(XDG_CONFIG_HOME, "rssfeed_lock")
PATH_CONF = File.join(XDG_CONFIG_HOME, "rssfeed_config")
PATH = File.join(XDG_CONFIG_HOME, "rssfeed_history")

unless File.exists? PATH
  File.write PATH, ""
end

unless File.exists? PATH_CONF
  File.write PATH_CONF, conf
end

conf = File.read(PATH_CONF).split("\n")
feed = RSS.parse conf.to_a.skip(2).first
refresh_interval = conf.to_a.first.to_i
icon = conf.to_a.skip(1).first
summary = conf.to_a.skip(3).first
notify_count = conf.to_a.skip(4).first.to_i

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
  body = h.to_a.skip(3).first.split(" - ").first
  url = h.to_a.skip(2).first
  pub_date = h.to_a.skip(1).first.split("#{Time.now.year}").first
  current_date = Time.now.to_s("%a, %e %b")
  compare_date = pub_date.to_s.chomp(" ") <=> current_date

  notification = Notify::Notification.build do |n|
    n.summary = summary
    n.body = body
    n.urgency = :normal
    n.icon_name = icon

    action "default", "Показать" do
      Gio::AppInfo.launch_default_for_uri(url, nil)
      Pointer(Void).null.value
    end

    action "show", "Показать" do
      Gio::AppInfo.launch_default_for_uri(url, nil)
      Pointer(Void).null.value
    end
  end

  if compare_date == 0
    count_lock = File.exists?(PATH_LOCK) ? File.read(PATH_LOCK).to_i : 1
    File.write PATH_LOCK, count_lock+1

    if notify_count >= count_lock
      notification.update
    end
  else
    File.delete PATH_LOCK if File.exists? PATH_LOCK
  end

  sleep refresh_interval
end

Gtk.main
