require "rss"
require "file"
require "gobject/gtk"
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

unless File.exists? PATH_CONF
  File.write PATH_CONF, config
end

conf = File.read(PATH_CONF).split("\n")
refresh_interval = conf.to_a.first.to_i
summary = conf.to_a.skip(1).first
icon = conf.to_a.skip(2).first
feed = RSS.parse conf.to_a.skip(3).first

loop do

  e = feed.items.first
  body = e.title.split(" - ").first
  pub_date = e.pubDate.split(" ").skip(1).first.to_i
  current_date = Time.now.to_s("%e").to_i
  compare_date = pub_date == current_date || pub_date+1 == current_date ? 1 : 0

  notification = Notify::Notification.build do |n|
    n.summary = summary
    n.body = body
    n.urgency = :normal
    n.icon_name = icon

    action "default", "Show" do
      Gio::AppInfo.launch_default_for_uri(e.link, nil)
      Pointer(Void).null.value
    end

    action "show", "Show" do
      Gio::AppInfo.launch_default_for_uri(e.link, nil)
      Pointer(Void).null.value
    end
  end

  if compare_date == 1
    unless File.exists? PATH_LOCK
      notification.update
      while !Gtk.events_pending
        Gtk.main_iteration
        break if notification.on_closed { next true }
      end
      File.write PATH_LOCK, e.pubDate
    end
  else
    File.delete PATH_LOCK if File.exists? PATH_LOCK
  end

  sleep refresh_interval
end
