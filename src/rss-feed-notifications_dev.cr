require "rss"
require "file"
require "yaml"
require "logger"
require "gobject/gtk"
require "gobject/gio"
require "gobject/notify"

LibNotify.init("rss-feed-notifications")

XDG_CONFIG_HOME = ENV["XDG_CONFIG_HOME"]? || File.expand_path("~/.config")
WORKING_DIR = File.join(XDG_CONFIG_HOME, "/#{PROGRAM_NAME}")
Dir.mkdir WORKING_DIR unless File.exists? WORKING_DIR
LOG = File.join(WORKING_DIR, "error.log")
CONFIG = File.join(WORKING_DIR,"config.yml")
LOGGER = Logger.new(File.open(LOG, "a"), level: Logger::ERROR)
ICON = File.expand_path("../res/icon/application-rss+xml-symbolic.svg", File.dirname(__FILE__))

unless File.exists? CONFIG
  File.write CONFIG, { 
    days: 1,
    refresh: 60,
    label: "Show",
    summary: "Forum Manjaro",
    url: "https://forum.manjaro.org/c/announcements/stable-updates.rss",
    icon: "nil"   
  }.to_yaml
end

conf = YAML.parse(File.read(CONFIG))
days = conf["days"].as_i
refresh = conf["refresh"].as_i
label = conf["label"].as_s
summary = conf["summary"].as_s
url = conf["url"].as_s
icon = conf["icon"].as_s
icon = icon != "nil" ? icon : ICON  
lock = false

#GLib.timeout(refresh.minutes.to_i) do 
GLib.timeout(refresh) do 
  begin
    feed = RSS.parse url
    e = feed.items.first
    body = e.title.split(" - ").first
#    pub_date = e.pubDate.split(" ").skip(1).first.to_i
    pub_date = YAML.parse(File.read(CONFIG))["date"].as_i 
    current_date = Time.local.to_s("%e").to_i
    
    notification = Notify::Notification.build do |n|
      n.summary = summary
      n.body = body
      n.urgency = :normal
      n.icon_name = icon

      action "default", "#{label}" do
        Gio::AppInfo.launch_default_for_uri(e.link, nil) unless lock
        Pointer(Void).null.value
        lock = true
      end

      action "show", "#{label}" do
        Gio::AppInfo.launch_default_for_uri(e.link, nil) unless lock
        Pointer(Void).null.value
        lock = true
      end
    end
    
    if [pub_date, pub_date+days].includes?(current_date)
      notification.update unless lock
    else 
      lock = false
    end
    
  rescue error
    LOGGER.fatal error
  end    
  true
end  

Gtk.main
