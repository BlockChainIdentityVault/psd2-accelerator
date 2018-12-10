# see
#   - https://suva.sh/posts/well-documented-makefiles/
#   - https://medium.freecodecamp.org/want-to-know-the-easiest-way-to-save-time-use-make-eec453adf7fe

# TODO
# looks like this file should/could be split in three: https://stackoverflow.com/questions/17873044/how-to-make-makefile-find-target-in-subdirectory-makefile

.PHONY: all run test test-ui test-service clean clean-ui clean-service clean-arc42 help

JAVA_SRC = $(shell find service/src)
TS_SRC = $(shell find ui/src)
ARC42_SRC = $(shell find arc42/src)
PLANTUML_SRC = $(shell find arc42/diagrams -type f -name '*.puml')

all: service/target arc42/psd2-sandbox-arc42.html ## Build all components

run: all ## Run everything with docker-compose after building
	docker-compose up --build

service/target: service/pom.xml $(JAVA_SRC) ui/dist ## Build the jar
	cd service && mvn -DskipTests clean package

ui/dist: ui/node_modules $(TS_SRC) ## Build the UI package (HTML/JS)
	cd ui && npm run build

ui/node_modules: ui/package.json ui/package-lock.json ## Install NPM dependencies
	cd ui && npm install

arc42/psd2-sandbox-arc42.html: arc42/images/generated $(ARC42_SRC) arc42/psd2-sandbox-arc42.adoc ## Generate arc42 html documentation
	cd arc42 && asciidoctor psd2-sandbox-arc42.adoc

arc42/images/generated: $(PLANTUML_SRC) ## Generate images from .puml files
# Note: Because plantuml doesnt update the images/generated timestamp we need to touch it afterwards
	cd arc42 images/* && plantuml -o "../images/generated" diagrams/*.puml && touch images/generated

test: test-ui test-service ## Run all tests

#TODO: Add e2e tests as seperate target or inside test-ui
test-ui: ui/node_modules ## Run tests in UI
	cd ui && npm run test-single-headless

test-service: service ## Run tests in service
	cd service && mvn test

clean: clean-ui clean-service clean-arc42 ## Clean everything

clean-ui: ## Clean UI temp files
	cd ui && rm -rf dist

clean-service: ## Clean service temp files
	cd service && mvn clean

clean-arc42: ## Clean arc42 temp files
	cd arc42 && rm -rf images/generated && rm -rf psd2-sandbox-arc42.html

# TODO this breaks on targets (= ignores) with slashes in the path
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)