.PHONY: default
default: compile

.PHONY: check_deps
check_deps:
	if [ ! -d deps ]; then mix deps.get; fi

.PHONY: compile
compile: check_deps
	mix compile --force --warnings-as-errors

.PHONY: install
install: compile
	mix do escript.build, escript.install --force

.PHONY: uninstall
uninstall:
	mix escript.uninstall brain

.PHONY: clean
clean:
	rm brain || true
	rm _build -rf || true

.PHONY: clean_deps
clean_deps:
	rm deps/ -rf || true

.PHONY: deep_clean
deep_clean: clean clean_deps

.PHONY: loc
loc:
	find lib -type f | while read line; do cat $$line; done | sed '/^\s*$$/d' | wc -l


