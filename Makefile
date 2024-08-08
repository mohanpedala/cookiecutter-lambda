SHELL := /bin/bash
.DEFAULT_GOAL := help

create:
	@echo "Bootstrapping the project..."
	./scripts/bootstrap.sh

cleanup:
	@echo "Destroying the project..."
	./scripts/cleanup.sh