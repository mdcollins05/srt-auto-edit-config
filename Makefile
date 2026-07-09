.PHONY: help build test generate-expected

help:
	@echo "Targets:"
	@echo "  build               Build the srt-auto-edit image (needs ../srt-auto-edit checkout)"
	@echo "  test                Run the rule fixtures against expected outputs"
	@echo "  generate-expected   Regenerate expected outputs after rule changes"
	@echo ""
	@echo "Typical workflow after editing rules:"
	@echo "  make generate-expected   # then review the git diff in tests/expected/"
	@echo "  make test"

build:
	docker compose build

test:
	docker compose run --rm test

generate-expected:
	docker compose run --rm generate-expected
