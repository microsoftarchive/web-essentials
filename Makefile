default:
	rake build

build:
	rake build

install:
	./install-bundler
	npm install
	npm install browserify basswork clean-css make-livereload -g
	mkdir -p .git/hooks
	cp pre-commit .git/hooks/

start:
	rake clean
	rake serve ~build

clean:
	rake clean
	git clean -X -d -f
	git clean -d -f

urls:
	rake release:urls

release-patch:
	rake release:patch

release-minor:
	rake release:minor

release-major:
	rake release:major
.PHONY: build