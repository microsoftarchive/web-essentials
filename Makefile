default:
	gulp render
	gulp build

render:
	gulp render

build:
	gulp render
	gulp build

install:
	npm install
	npm install gulp -g
	gem install bundler
	bundle install
	cp pre-commit .git/hooks/

start:
	gulp render
	gulp build
	gulp

clean:
	git clean -X -d -f
	git clean -d -f
	rm -rf render
	mkdir render
	touch render/.gitkeep
	rm -rf build
	mkdir build
	touch build/.gitkeep
