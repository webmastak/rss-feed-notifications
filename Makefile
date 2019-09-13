FILE:= $(shell basename $(shell pwd))

all:
	@shards build --release --no-debug
	@cp bin/$(FILE) ~/.local/bin/$(FILE)
	@cp rss-feed-notifications.desktop ~/.config/autostart/rss-feed-notifications.desktop
	@rm -f bin/*
	@rm -fd bin
