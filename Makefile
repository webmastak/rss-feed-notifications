FILE:= $(shell basename $(shell pwd))
DIR:= ~/.local/bin

all: 
	@shards build --release --no-debug
	@mkdir -p $(DIR)
	@cp bin/$(FILE) $(DIR)/$(FILE)
	@cp rss-feed-notifications.desktop ~/.config/autostart/rss-feed-notifications.desktop
	@rm -f bin/*
	@rm -fd bin
