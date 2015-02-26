default:
	gulp ejs
	gulp make

install:
	npm install
	npm install gulp -g

start:
	gulp ejs
	gulp

clean:
	git clean -X -d -f
	git clean -d -f
	mkdir css
	touch css/.gitkeep
	mkdir js
	touch js/.gitkeep
