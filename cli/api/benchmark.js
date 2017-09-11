var utils = require('./utils');
var tiles = require('./tile-requests.json');
var _ = require('lodash');
var async = require('async');
var request = require('request');

// create tile requests
var MAPIC_BENCHMARK_TILES = process.env.MAPIC_BENCHMARK_TILES || 300;
console.log('Benchmarking', MAPIC_BENCHMARK_TILES, 'tiles...');
var benchmark_tiles = [];
while (benchmark_tiles.length < MAPIC_BENCHMARK_TILES) {
    benchmark_tiles = benchmark_tiles.concat(tiles);
}

// console.log('while done, ', benchmark_tiles.length);

// process.exit(0);
var n = 0;

// get access token
utils.token(function (err, access_token) {

    if (err || !access_token) {
        console.log('Not able to log in with credentials:')
        console.log('MAPIC_API_USERNAME:', process.env.MAPIC_API_USERNAME);
        console.log('MAPIC_API_AUTH', process.env.MAPIC_API_AUTH);
        process.exit(1);
    }

    // mark start of bench
    var timeStart = Date.now();

    // request all tiles
    async.map(benchmark_tiles, function(url, callback) {

        // add access token
        var tile = url + '?force_render=true&access_token=' + access_token;

        n++;

        // request tile
        request(tile, callback);

    }, function(err, results) {
        if (err) {
            console.log('err', err);
            process.exit(1);    
        }

        // calc benchmark
        var timeEnd = Date.now();
        var benched = timeEnd - timeStart;

        // print benchmark as ms only
        console.log('Benchmark:', benched, 'ms');
        console.log('n:', n);

        // clean exit
        process.exit(0);
    });

});
