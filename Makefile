# vim:ft=make
# Makefile

.PHONY: help install run brew_dump brew_inst load_pl install_xcode
.SILENT:

default: help

help:	## Show this help.
	awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install:	## Install ansible galaxy requirements
	ansible-galaxy install -r requirements.yml

run:	## Run ansible playbook
	ansible-playbook main.yml --ask-become-pass --tags debug,vscode

brew_dump:	## Dump Brewfile
	brew bundle dump --file ./files/Brewfile --force

brew_inst:	## Install manually from Brewfile
	sudo chown -R $(shell whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
	brew bundle --file ./files/Brewfile

load_pl: # Load PowerLevel10k when it's not triggered automatically
	source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
	p10k configure

install_xcode: # Install and setup xcode if it's not done automatically
	mas install 497799835
	sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
	sudo xcodebuild -license accept
