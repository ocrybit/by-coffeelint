By-CoffeeLint
=============

A Bystander plugin to auto-CoffeeLint after CoffeeScript compilation.  
Note it has to be used in conjunction with [by-coffeescript](http://tomoio.github.com/by-coffeescript/) plugin.

Installation
------------

To install **by-coffeelint**,

    sudo npm install -g by-coffeelint

Options
-------

> `config` : an object of coffeelint options.

See the [CoffeeLint website](http://coffeelint.org/#options) for the lint options and an example json config data.

#### Examples

Set `no_trailing_whitespace` to `warn` level.

    // .bystander config file
	.....
	.....
      "plugins" : ["by-coffeescript", "by-write2js"],
      "by" : {
        "coffeelint" : {
          "config" : {
            "no_trailing_whitespace" : {
              "level" : "warn"
            }
          }
        }
      },
    .....
	.....


Broadcasted Events for further hacks
------------------------

> `linted` : successfully linted the given code.

See the [annotated source](docs/by-coffeelint.html) for details.

Running Tests
-------------

Run tests with [mocha](http://visionmedia.github.com/mocha/)

    make
	
License
-------
**By-CoffeeLint** is released under the **MIT License**. - see the [LICENSE](https://raw.github.com/tomoio/by-coffeelint/master/LICENSE) file

