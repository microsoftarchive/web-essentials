default:
	gulp css js html

install:
	npm install
	npm install gulp -g

start:
	gulp

clean:
	rm -f index.html
	rm -rf node_modules
	rm -f css/*
	rm -f js/*
	touch css/.gitkeep
	touch js/.gitkeep
