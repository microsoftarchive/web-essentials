# Web styleguide

## Prerequisits

One needs to have these installed first:

* node
* npm

## Setup

```sh
$ make install
$ make start
```

## I just want to compile the css and not run a server, cool?

```sh
$ make
```

## gulp tasks

* css -> compile all the css into bass.css
* js -> compile all the js into app.js
* serve -> run a server that serves index.html
* default -> [css, js, serve] while watching for changes

## javascript?

The js is just for the styleguide itself. All shared javascript will be
published as private npm modules. Every project using the styleguide
will use browserify to require only what the project needs.

## base.css

We are basing this initially on <http://basscss.com>. Basscss is a
lightweight collection of base element styles, utilities, layout
modules, and color styles designed for speed, performance, and
scalability.

We will modify it to suite our needs. The tradeoffs we are embraceing
are:

* Minimalistic OOCSS which means lots of class names per element
* Speed is prioritized highest as designs will be done in the browser
* Sacrificing semantics and higher reusability
* Speed is prioritized for the viewer as well by not including lots of
  unused css
* Creating a new component should 95% of the time not require new css
* All updates are versioned with git tags: a project will freeze to a
  git tag directly
* All component updates are documented in the CHANGELOG by version
* Assets are linked directly from a CDN with url including it's version

## Future stuff

There will be an upgrade script that will scan and fine updated
components and instruct how to upgrade and what changed.
