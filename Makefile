# vim:ft=make
# Makefile
# NOTE: Developed with GNU Make 3.81

.PHONY: %
.SILENT: # Comment this line if you need to debug a specific target
default: help

help:	## Show this help
	awk 'BEGIN {FS = ":.*##|\t#.*Example:|\t#.*Link:|\t#.*Use-case:|###LINE "; \
		printf "Usage: make \033[36m<target>\033[0m\n"} \
		/^[a-zA-Z_-]*[[:space:]]?[a-zA-Z_-]*[[:space:]]?[a-zA-Z_-]*[[:space:]]?[a-zA-Z_-]+:.*?##/ \
		{ printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 } /^##@/ \
		{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } /^\t#.*Example:.*/ \
		{ printf "   ╰─➤\033[33m %-26s %s\033[0m\n","Example:", $$2} /^\t#.*Use-case:.*/ \
		{ printf "   ╰─➤\033[34m %-26s %s\033[0m\n","Use-case:", $$2} /^\t#.*Link:.*/ \
		{ printf "   ╰─➤\033[35m %-26s %s\033[0m\n","Link:", $$2} /^###LINE.*/ \
		{ len = length($$2); left = 20; right = 85 - len - left; left_line = ""; right_line = ""; \
		for (i = 0; i < left; i++) left_line = left_line "-"; \
		for (i = 0; i < right; i++) right_line = right_line "-"; \
		printf "  %s\033[1;34m%s\033[0m%s\n", left_line, $$2, right_line }' $(MAKEFILE_LIST)

##@ Ansible targets:

init install:	## Install ansible galaxy requirements
	ansible-galaxy install -r requirements.yml

tags ?= all
verbose ?= false

ifeq ($(verbose),true)
	verbosity = -vvv
else
	verbosity =
endif

msg ?= Do you really want to proceed?
confirm:	# Internal confirm utility
	printf "\033[0;33m$(msg) \033[1;34m[y/N]\033[0m " && read ans && [ $${ans:-N} = y ] && echo ""

c check:	## Check ansible playbook
		ansible-playbook main.yml --become-password-file password.txt --tags $(tags) -CD $(verbosity)

r run: confirm	## Run ansible playbook
		ansible-playbook main.yml --become-password-file password.txt --tags $(tags) $(verbosity)

##@ Brew targets:


bd brew_dump:	## Dump Brewfile
	brew bundle dump --file ./files/Brewfile --force

bi brew_inst: confirm	## Install manually from Brewfile
	sudo chown -R $(shell whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
	brew bundle --file ./files/Brewfile

###LINE Brew auto-update targets

bas brew_auto_update_status: ## Check Brew auto-update status
	brew autoupdate status

bau brew_auto_update: confirm ## Enable Brew auto-update
	brew autoupdate start 43200 --upgrade --cleanup --sudo

##@ Others:

lpl load_pl: ## Load PowerLevel10k when it's not triggered automatically
	source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
	p10k configure

ix install_xcode: confirm ## Install and setup xcode if it's not done automatically
	mas install 497799835
	sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
	sudo xcodebuild -license accept
