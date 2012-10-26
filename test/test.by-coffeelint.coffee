fs = require('fs')
path = require('path')
async = require('async')
rimraf = require('rimraf')
mkdirp = require('mkdirp')
chai = require('chai')
Bystander = require('bystander')
should = chai.should()
coffee = require('coffee-script')
ByCoffeeLint = require('../lib/by-coffeelint')

describe('ByCoffeeLint', ->
  GOOD_CODE = 'foo = 1'
  BAD_CODE = 'foo ==== 1'
  TMP = "#{__dirname}/tmp"
  FOO = "#{TMP}/foo"
  FOO2 = "#{TMP}/foo2"
  NODIR = "#{TMP}/nodir"
  NOFILE = "#{TMP}/nofile.coffee"
  HOTCOFFEE = "#{TMP}/hot.coffee"
  BLACKCOFFEE = "#{TMP}/black.coffee"
  ICEDCOFFEE = "#{FOO}/iced.coffee"
  ICEDJS = "#{FOO}/iced.js"
  BIN = "#{FOO}/iced.bin.coffee"
  BINJS = "#{FOO}/iced"
  TMP_BASE = path.basename(TMP)
  FOO_BASE = path.basename(FOO)
  FOO2_BASE = path.basename(FOO2)
  NODIR_BASE = path.basename(NODIR)
  NOFILE_BASE = path.basename(NOFILE)
  HOTCOFFEE_BASE = path.basename(HOTCOFFEE)
  BLACKCOFFEE_BASE = path.basename(BLACKCOFFEE)
  ICEDCOFFEE_BASE = path.basename(ICEDCOFFEE)
  LINT_CONFIG = {"no_tabs" : {"level" : "error"}}
  NO_COMPILE = ["**/foo/*"]
  MAPPER = {"**/foo/*" : [/\/foo\//,'/foo2/']}
  COMPILED = coffee.compile(GOOD_CODE)
  bystander = new Bystander()
  byCoffeeLint = new ByCoffeeLint()
  stats = {}

  beforeEach((done) ->
    mkdirp(FOO, (err) ->
      async.forEach(
        [HOTCOFFEE, ICEDCOFFEE],
        (v, callback) ->
          fs.writeFile(v, GOOD_CODE, (err) ->
            async.forEach(
              [FOO, HOTCOFFEE,ICEDCOFFEE,BLACKCOFFEE],
              (v, callback2) ->
                fs.stat(v, (err,stat) ->
                  stats[v] = stat
                  callback2()
                )
              ->
                callback()
            )
          )
        ->
          byCoffeeLint = new ByCoffeeLint({nolog:true, root: TMP})
          done()
      )
    )
  )

  afterEach((done) ->
    rimraf(TMP, (err) =>
      byCoffeeLint.removeAllListeners()
      done()
    )
  )

  describe('constructor', ->
    it('init test', ->
      ByCoffeeLint.should.be.a('function')
    )
    it('should instanciate', ->
      byCoffeeLint.should.be.a('object')
    )
    it('should set @config', () ->
      byCoffeeLint.opts.config.should.be.empty
      byCoffeeLint = new ByCoffeeLint({config : LINT_CONFIG})
      byCoffeeLint.opts.config.should.eql(LINT_CONFIG)
    )

  )

  describe('_coffeeLint', ->
    it('return an empty array for a good code', ->
      byCoffeeLint._coffeeLint(GOOD_CODE).should.be.empty.instanceOf(Array)
    )
    it('return a not-empty array for a bad code', ->
      byCoffeeLint._coffeeLint(BAD_CODE).should.not.be.empty
      byCoffeeLint._coffeeLint(BAD_CODE).should.be.instanceOf(Array)
    )
  )

  describe('_parseLint', ->
    it('parse lint result', ->
      byCoffeeLint._parseLint(byCoffeeLint._coffeeLint(BAD_CODE)).errorCount.should.equal(1)
    )
  )

  describe('_setListeners', (done) ->
    beforeEach(->
      bystander = new Bystander(TMP,{nolog:true, plugins:['by-coffeescript']})
    )

    it('should listen to "compiled" and coffeelint the source code', (done) ->
      bystander.once('watchset', () ->
        byCoffeeLint._setListeners(bystander)
        byCoffeeLint.on('linted', (data) ->
          if data.file is ICEDCOFFEE
            byCoffeeLint.removeAllListeners()
            data.lint.should.be.empty
            done()
        )
        fs.utimes(ICEDCOFFEE, Date.now(), Date.now())
      )
      bystander.run()

    )
  )
)