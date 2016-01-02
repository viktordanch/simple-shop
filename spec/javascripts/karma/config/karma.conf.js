// Karma configuration
// Generated on Fri Jan 01 2016 20:29:26 GMT+0200 (EET)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: __dirname + '/../../../../',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha', 'requirejs'],

    plugins: [
      'karma-mocha',
      'karma-requirejs',
      'karma-phantomjs-launcher'
    ],


    // list of files / patterns to load in the browser
    files: [
      {pattern: 'spec/javascripts/sample.spec.js', included: false},
      {pattern: 'spec/javascripts/libs/**/*.js', included: false},
      {pattern: 'app/assets/javascripts/**/*.js', included: false},
      {pattern: 'app/assets/javascripts/**/*.hbs', included: false},
      {pattern: 'app/assets/javascripts/**/*.handlebars', included: false},
      {pattern: 'spec/javascripts/shop_b/**/*.js', included: false},
      {pattern: 'node_modules/chai/chai.js', included: false},
      {pattern: 'node_modules/sinon/lib/sinon.js', included: false},
      {pattern: 'node_modules/sinon-chai/lib/sinon-chai.js', included: false},
      'spec/javascripts/require_js/test-main.js'
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity
  })
}