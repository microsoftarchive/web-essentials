default:
	gulp build

install:
	npm install
	npm install gulp -g

start:
	gulp

clean:
	git clean -X -d -f
	git clean -d -f
	mkdir render
	touch render/.gitkeep
	mkdir build
	touch build/.gitkeep
