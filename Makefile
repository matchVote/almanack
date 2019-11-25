.PHONY: help

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`

help:
	@echo $(APP_NAME):$(APP_VSN)
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

version: ## Show latest app version
	@echo $(APP_VSN)

build: ## Build the production Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
	--build-arg APP_VSN=$(APP_VSN) \
	-t $(APP_NAME):$(APP_VSN) .

heroku-push: ## Use Heroku to build production image and push to registry
	heroku container:push worker \
	  --verbose \
	  --arg APP_NAME=$(APP_NAME),APP_VSN=$(APP_VSN),MIX_ENV=prod \
	  --app mv-almanack

heroku-release: ## Deploy container from previously pushed image
	heroku container:release worker --app mv-almanack
