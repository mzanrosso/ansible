# vim:ft=make
# Makefile

.PHONY: help install run brew_dump brew_inst #test
.SILENT:

default: help

help:	## Show this help.
	awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install:	## Install ansible galaxy requirements
	ansible-galaxy install -r requirements.yml

run:	## Run ansible playbook
	ansible-playbook main.yml --ask-become-pass --tags debug,vscode

brew_dump:	## Dump Brewfile
	brew bundle dump --file ./files/Brewfile

brew_inst:	## Install manually from Brewfile
	brew bundle --file ./files/Brewfile

