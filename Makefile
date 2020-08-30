#!/usr/bin/env make

.PHONY: *

export PATH := $(shell pwd)/bin:$(shell pwd)/node_modules/.bin:$(PATH)

init:
	@echo "Installing npm dependencies..."
	@npm install
	@echo "Pulling latest from pwa-examples..."
	@git -C pwa-examples pull -r
	@echo "If there was un update to the submodule, please push an update as a PR"

.port:
	get-random-port 8080 > .port

server: start

start: .port
	PORT=$$(cat .port) npm start

restart: .port
	pm2 restart static-page-server-$$(cat .port)

stop:
	pm2 stop static-page-server-$$(cat .port)

delete: .port
	pm2 delete static-page-server-$$(cat .port)

run: .port
	pa11y --config ./pa11y.json http://localhost:$$(cat .port)

test:
	npm test
