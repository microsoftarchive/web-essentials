default:
	rake build

build:
	rake build

dist:
	rake dist

install:
	npm install
	npm install basswork clean-css -g
	gem install bundler --no-ri --no-rdoc
	bundle install
	cp pre-commit .git/hooks/

start:
	rake serve ~build

clean:
	rake clean
	git clean -X -d -f
	git clean -d -f
