[![Koara](http://www.koara.io/logo.png)](http://www.koara.io)

[![Build Status](https://img.shields.io/travis/koara/koara-rb.svg)](https://travis-ci.org/koara/koara-rb)
[![Coverage Status](https://img.shields.io/coveralls/koara/koara-rb.svg)](https://coveralls.io/github/koara/koara-rb?branch=master)
[![Gem](https://img.shields.io/gem/v/koara.svg?maxAge=2592000)]()
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/koara/koara-rb/blob/master/LICENSE)

# Koara-rb
[Koara](http://www.koara.io) is a modular lightweight markup language. This project is the core koara parser written in Ruby.
If you are interested in converting koara to a specific outputFormat, please look the [Related Projects](#related-projects) section.

## Getting started
- Gem

  ```bash
  gem install koara
  ```

## Usage
```ruby
require 'koara'

parser = Koara::Parser.new
result1 = parser.parse('Hello World!') # parse a string
```

## Configuration
You can configure the Parser:

-  **parser.modules**  
   Default:	`["paragraphs", "headings", "lists", "links", "images", "formatting", "blockquotes", "code"]`
   
   Specify which parts of the syntax are allowed to be parsed. The rest will render as plain text.

## Related Projects

- [koara / koara-rb-html](http://www.github.com/koara/koara-rb-html): Koara to Html renderer written in Ruby
- [koara / koara-rb-xml](http://www.github.com/koara/koara-rb-html): Koara to Xml renderer written in Ruby