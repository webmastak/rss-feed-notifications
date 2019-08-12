require "rss"
require "file"
require "yaml"
require "gobject/gtk"
require "gobject/gio"
require "gobject/notify"

LibNotify.init("rss-feed-notifications")

XDG_CONFIG_HOME = ENV["XDG_CONFIG_HOME"]? || File.expand_path("~/.config")
LOCK = File.join(XDG_CONFIG_HOME, "#{PROGRAM_NAME}.lock")
CONFIG = File.join(XDG_CONFIG_HOME, "#{PROGRAM_NAME}.yml")

unless File.exists? CONFIG
  File.write CONFIG, { 
    refresh: 3600,
    summary: "Forum Manjaro",
    icon: "application-rss+xml-symbolic",
    url: "https://forum.manjaro.org/c/announcements/stable-updates.rss"
  }.to_yaml
end

conf = YAML.parse(File.read(CONFIG))
refresh = conf["refresh"].as_i
summary = conf["summary"].as_s
icon = conf["icon"].as_s
url = conf["url"].as_s

loop do
  begin
    feed = RSS.parse url
    e = feed.items.first
    body = e.title.split(" - ").first
    pub_date = e.pubDate.split(" ").skip(1).first.to_i
    current_date = Time.now.to_s("%e").to_i
    
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

    if [pub_date, pub_date+1].includes?(current_date)
      unless File.exists? LOCK
        notification.update
        while !Gtk.events_pending
          Gtk.main_iteration
          break if notification.on_closed { next true }
        end
        File.write LOCK, e.pubDate if Gtk.events_pending
      end
    else
      File.delete LOCK if File.exists? LOCK
    end
  rescue
    sleep refresh
  end
  sleep refresh
end
