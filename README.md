# LiquidKit

Liquid template language parser engine in Swift.

## About

Liquid is a template language that is used by several projects, such as Shopify and Jekyll (which powers GitHub pages). Liquid allows conditional injection of content into html pages through a simple and elegant syntax.

LiquidKit brings the power of Liquid to iOS and macOS. It is currently under development, so not all features are available.

This project is based on the [liquid-swift](https://github.com/yourtion/liquid-swift) project by [yourtion](https://github.com/yourtion), which provided a barebones implementation of the Lexer and the Parser. However, it was lacking any logical parsing or filters, which I have added. It has been renamed and re-hosted since I intend to maintain this project myself.

## Features

- [ ] Comment
- [x] Raw
- [x] Truthy and falsy
- [ ] Whitespace control
- [x] Dot operator `dict.key[index]`
- [x] Filters
  - [x] abs
  - [x] append
  - [x] at_least
  - [x] at_most
  - [x] capitalize
  - [x] ceil
  - [x] compact
  - [x] concat
  - [x] date
  - [x] default
  - [x] divided_by
  - [x] downcase
  - [x] escape
  - [x] escape_once
  - [x] first
  - [x] floor
  - [x] join
  - [x] last
  - [x] lstrip
  - [x] map
  - [x] minus
  - [x] modulo
  - [x] newline_to_br
  - [x] plus
  - [x] prepend
  - [x] remove
  - [x] remove_first
  - [x] replace
  - [x] replace_first
  - [x] reverse
  - [x] round
  - [x] rstrip
  - [x] size
  - [x] slice
  - [x] sort
  - [x] sort_natural
  - [x] split
  - [x] strip
  - [x] strip_html
  - [x] strip_newlines
  - [x] times
  - [x] truncate
  - [x] truncatewords
  - [x] uniq
  - [x] upcase
  - [x] url_decode
  - [x] url_encode
- [x] Variable
  - [x] `assign`
  - [x] `capture`
  - [x] `increment`
  - [x] `decrement`
- [x] Operators
  - [x] `==` equals
  - [x] `!=` does not equal
  - [x] `>` greater than
  - [x] `<` less than
  - [x] `>=` greater than or equal to
  - [x] `<=` less than or equal to
  - [x] `or` logical or
  - [x] `and` logical and
  - [x] `contains` checks substring inside a string
- [x] Control flow
  - [x] `if` if a certain condition is true
  - [x] `unless` if a certain condition is not met
  - [x] `elsif` more conditions
  - [x] `else` else conditions
  - [x] `case/when` switch statement
- [ ] Iteration
  - [x] `for`
     - [x] `break`
     - [x] `continue`
     - [x] `limit` limits the loop (for parameters)
     - [x] `offset` begins the loop at the specified index (for parameters)
     - [x] `range` defines a range of numbers to loop through
     - [x] `reversed` reverses the order of the loop
  - [x] `cycle`
     - [x] `group`
  - [ ] `tablerow`
     - [ ] `cols`
     - [ ] `limit` limits the loop (for parameters)
     - [ ] `offset` begins the loop at the specified index (for parameters)
     - [x] `range` defines a range of numbers to loop through
- [x] Default Filter

## Liquid Docs

- [English](https://shopify.github.io/liquid/)
- [Chinese](https://liquid.bootcss.com/)
