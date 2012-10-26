EventEmitter = require('events').EventEmitter
colors = require('colors')
coffeelint = require('coffeelint')
fs = require('fs')
module.exports = class ByCoffeeLint extends EventEmitter
  constructor: (@opts = {}) ->
    @opts.config ?= {}

  _setListeners: (@bystander) ->
    @bystander.by.coffeescript.on('compiled', (data) =>
      data.lint = @_coffeeLint(data.code)
      unless @opts.nolog
        console.log(@_parseLint(data.lint).message + " <= #{data.file}".grey+'\n')
      @emit('linted', data)
    )

  # #### Parse a lint result
  # `lint (Object)` : a result form linting 
  _parseLint: (lint) ->
    errorCount = 0
    warnCount = 0
    if lint.err
      return {message : "\n  lint compile error: #{lint.err}".red, errorCount : errorCount}
    else if lint.length is 0
      return {message : "", errorCount : errorCount}
    else
      errors = []
      for v in lint
        if v.level is 'error'
          errorCount += 1
          lcolor = 'red'
        else if v.level is 'warn'
          lcolor = 'yellow'
          warnCount += 1
        error = [("  ##{v.lineNumber} #{v.message}.")[lcolor]]
        if v.context?
          error.push(" #{v.context}."[lcolor])
        error.push(" (#{v.rule})".grey)
        if v.line
          error.push("\n    => #{v.line}".grey)
        errors.push(error.join(''))
      errors.push(
        "  CoffeeLint: ".grey +
        "#{errorCount} errors".red +
        " #{warnCount} warnings".yellow
      )
      return {message : '\n' + errors.join('\n'), errorCount : errorCount}

  # #### Coffeelint source code 
  # `code (String)` : a CoffeeScript source code to lint 
  _coffeeLint: (code) ->
    # abort if `@lintConfig.nolint` is true
    try
      lint = coffeelint.lint(code, @opts.config)
    catch e
      lint = {err: e}
    return lint
