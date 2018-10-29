# web-essentials
The tools, concepts, and docs for building things for the web

## essentials.css

This is based initially on <http://basscss.com>. Basscss is a
lightweight collection of base element styles, utilities, layout
modules, and color styles designed for speed, performance, and
scalability.

We will modify it to suit our needs with the tradeoffs we are embracing being:

* Minimalistic OOCSS which means lots of class names per element
* Speed is prioritized the most as designs will be done in the browser
* Sacrificing semantics and higher reusability
* Speed is prioritized for the viewer through the excluding of excessive css
* Creating a new component should 95% of the time not require new css
