var utils = require('./utils');
var tiles = require('./tile-requests.json');
var _ = require('lodash');
var async = require('async');
var request = require('request');

console.time('  Benchmark')
async.map(tiles, function(url, callback) {
  request(url, function(error, response, html) {
    if (error) console.log('err', error);

    // Some processing is happening here before the callback is invoked
    callback(error, html);
  });
}, function(err, results) {
    if (err) console.log('err', err);
    console.timeEnd('  Benchmark')

});