default:
	gulp ejs
	gulp

install:
	npm install
	npm install gulp -g
	gem install rake rake-tilde

start:
	rake ~start

clean:
	git clean -X -d -f
	git clean -d -f
	mkdir css
	touch css/.gitkeep
	mkdir js
	touch js/.gitkeep
