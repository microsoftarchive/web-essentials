# web-essentials
The tools, concepts, and docs for building things for the web

## essentials.css

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
