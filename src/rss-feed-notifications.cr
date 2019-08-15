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
LOCK = File.join(WORKING_DIR, "notifi.lock")
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

      action "default", "#{label}" do
        Gio::AppInfo.launch_default_for_uri(e.link, nil)
        Pointer(Void).null.value
      end

      action "show", "#{label}" do
        Gio::AppInfo.launch_default_for_uri(e.link, nil)
        Pointer(Void).null.value
      end
    end

    if [pub_date, pub_date+days].includes?(current_date)
      unless File.exists? LOCK
        notification.update
        while !Gtk.events_pending
          Gtk.main_iteration
          break if notification.on_closed { next true }
        end
        
        if Gtk.events_pending
          File.write LOCK, e.pubDate 
          parent = Process.pid
          fork = Process.fork do
            Process.exec("#{PROGRAM_NAME}")
          end 
          Process.kill(Signal::KILL, parent)                      
        end
      end
    else
      File.delete LOCK if File.exists? LOCK
    end
  rescue error
    LOGGER.fatal error
  end
  sleep refresh.minutes
end
