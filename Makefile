DEFAULT_GOAL: help

.PHONY: wheel-urls
wheel-urls: ## Creates download URLs from s3 bucket from sha256sums.txt file
	./scripts/createdownloadurls.py > wheelsurls.txt

.PHONY: fetch-wheels
fetch-wheels: ## Downloads wheels and sources from the remote server
	./scripts/fetch-wheels

.PHONY: securedrop-proxy
securedrop-proxy: ## Builds Debian package for securedrop-proxy code
	PKG_NAME="securedrop-proxy" ./scripts/build-debianpackage

.PHONY: securedrop-client
securedrop-client: ## Builds Debian package for securedrop-client code
	PKG_NAME="securedrop-client" ./scripts/build-debianpackage

.PHONY: securedrop-workstation-config
securedrop-workstation-config: ## Builds Debian metapackage for Qubes Workstation base dependencies

.PHONY: securedrop-workstation-grsec
securedrop-workstation-grsec: ## Builds Debian metapackage for Qubes Workstation hardened kernel

.PHONY: install-deps
install-deps: ## Install initial Debian packaging dependencies
	./scripts/install-deps

.PHONY: requirements
requirements: ## Creates requirements files for the Python projects
	./scripts/create-requirements
	./scripts/update-requirements

.PHONY: build-wheels
build-wheels: fetch-wheels ## Builds the wheels and adds them to the localwheels directory
	./scripts/verify-sha256sum-signature
	./scripts/build-sync-wheels -p ${PKG_DIR}
	./scripts/sync-sha256sums
	./scripts/createdownloadurls.py > wheelsurls.txt
	@printf "Done! Now please follow the instructions in\n"
	@printf "https://github.com/freedomofpress/securedrop-debian-packaging-guide/issues/6\n"
	@printf "to push these changes to the FPF PyPI index\n"

.PHONY: clean
clean: ## Removes all non-version controlled packaging artifacts

.PHONY: help
help: ## Prints this message and exits
	@printf "Makefile for building SecureDrop Workstation packages\n"
	@printf "Subcommands:\n\n"
	@perl -F':.*##\s+' -lanE '$$F[1] and say "\033[36m$$F[0]\033[0m : $$F[1]"' $(MAKEFILE_LIST) \
		| sort \
		| column -s ':' -t
