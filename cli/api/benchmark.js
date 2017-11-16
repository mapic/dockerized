var _ = require('lodash');
var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var request = require('request');
var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var tiles = require('./tile-requests.json');
var benchmark_json = require('./benchmark.json');
var debug = process.env.MAPIC_DEBUG;

console.log('tiles: ', tiles);
console.log('benchmark_json: ', benchmark_json);

var dataset_path = process.argv[2];

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_DOMAIN;
var api = supertest(domain);

// deafult styles
var default_cartocss = "#layer { raster-opacity: 1; raster-colorizer-default-mode: linear; raster-colorizer-default-color: transparent; raster-comp-op: color-dodge; raster-colorizer-stops:  stop(0, rgba(0,0,0,0)) stop(31999, rgba(0,0,0,0)) stop(32000, rgba(255,255,255,0)) stop(32767, rgba(101,253,0,1)) stop(33400, rgba(255,255,0,1)) stop(36999, rgba(255,0,0,1)) stop(37000, rgba(0,0,0,0)) stop(65534, rgba(0,0,0,0), exact);}";
var default_style = "{\"stops\":[{\"val\":32000,\"col\":{\"r\":255,\"g\":255,\"b\":255,\"a\":0},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":0,\"right\":false,\"value\":\"rgba(255,255,255,0)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":0,\"right\":false,\"value\":\"rgba(255,255,255,0)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":32767,\"col\":{\"r\":101,\"g\":253,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":1,\"right\":false,\"value\":\"rgba(101,253,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":1,\"right\":false,\"value\":\"rgba(101,253,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":33400,\"col\":{\"r\":255,\"g\":255,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":2,\"right\":false,\"value\":\"rgba(255,255,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":2,\"right\":false,\"value\":\"rgba(255,255,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":36999,\"col\":{\"r\":255,\"g\":0,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":3,\"right\":false,\"value\":\"rgba(255,0,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":3,\"right\":false,\"value\":\"rgba(255,0,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}}],\"range\":{\"min\":0,\"max\":65534}}";

// already uploaded data
var MAPIC_BENCHMARK_UPLOADED_DATA_LAYER = process.env.MAPIC_BENCHMARK_UPLOADED_DATA_LAYER
var MAPIC_API_DATASET_TITLE = 'benchmark-data';

var ops = {};
var tmp = {};

// get access token
utils.token(function (err, access_token) {

    // check if got access token
    if (err || !access_token) {
        console.log('');
        console.log('Not able to log in with credentials:')
        console.log('MAPIC_API_USERNAME:', process.env.MAPIC_API_USERNAME);
        console.log('MAPIC_API_AUTH', process.env.MAPIC_API_AUTH);
        console.log('');
        console.log('Please check your API login with "mapic api login"...');
        console.log('Exiting!');
        process.exit(1);
    }

    // if not already existing tile layer, 
    // we must upload
    if (!MAPIC_BENCHMARK_UPLOADED_DATA_LAYER) {

        // get user
        ops.get_user = function (callback) {
            console.log('Authenticating...');

            utils.get_user(function(err, user) {
                tmp.user = user;
                callback(err);
            }, true);
        };

        // upload benchmark data
        ops.upload = function (callback) {

            fs.stat(dataset_path, function (err, stats) {
                if (err) return callback(err);

                // get data size
                var size = parseInt(stats.size/1000000) + 'MB';

                console.log('Uploading benchmark data: ', path.basename(dataset_path) + ' (' + size + ')');

                api.post(endpoints.data.import)
                .type('form')
                .field('access_token', access_token)
                .field('data', fs.createReadStream(path.resolve(__dirname, dataset_path)))
                .end(function (err, res) {
                    var result = utils.parse(res.text);
                    tmp.file_id = result.file_id;
                    tmp.upload_status = res.body;
                    callback();
                });

            })


        };

        // to get the File.Model after upload is done processing
        // todo: check status first to see if processing is done
        ops.get_file = function (callback) {

            var n = 0;
            process.stdout.write('Processing data');

            var processingInterval = setInterval(function () {
                api.get(endpoints.data.getStatus)
                .query({ file_id : tmp.upload_status.file_id, access_token : access_token})
                .end(function (err, res) {
                    
                    // parse
                    var status = utils.parse(res.text);
                    
                    // check if processing is finished
                    if (status.processing_success) {
                        console.log('done!');
                        clearInterval(processingInterval);
                        tmp.file_model = status;
                        callback();
                    } else { 
                        process.stdout.write('.');
                    }
                    
                    // failsafe
                    if (n > 100) {
                        console.log('Failed to process status!');
                        callback(err);
                    }
                });
            }, 500);
        };

        // create temp project
        ops.create_project = function (callback) {
            console.log('Creating benchmark project...')

            var project_json = {
                "name": 'Benchmark-' + new Date().toDateString(),
                "description": "",
                "access": {
                    "edit": [],
                    "read": [],
                    "options": {
                        "share": true,
                        "download": true,
                        "isPublic": false
                    }
                },
                "access_token": access_token
            };

            // create project
            api.post('/v2/projects/create')
            .send(project_json)
            .end(function (err, response) {
                if (err) return callback(err);
                var body = response.body;
                tmp.project = body.project;
                callback();
            });
        };

        // create tile layer
        ops.create_tile_layer = function (callback) {

            console.log('Creating tile layer...');

            var layer_json = {
              "geom_column": "rast",
              "geom_type": "raster",
              "raster_band": "",
              "srid": "",
              "affected_tables": "",
              "interactivity": "",
              "attributes": "",
              "access_token": access_token,
              "cartocss_version": "2.0.1",
              "cartocss": default_cartocss,
              "sql": "(SELECT * FROM " + tmp.upload_status.file_id + ") as sub",
              "file_id": tmp.upload_status.file_id,
              "return_model": true,
              "projectUuid": tmp.project.uuid,
              "cutColor": false
            }

            // create tile layer
            api.post('/v2/tiles/create')
            .send(layer_json)
            .end(function (err, response) {
                if (err) return callback(err);
                var body = response.body;
                tmp.tile_layer = body.options;
                console.log('Tile Layer ID: ', tmp.tile_layer.layer_id);
                MAPIC_BENCHMARK_UPLOADED_DATA_LAYER = tmp.tile_layer.layer_id;
                callback();
            });
        };

        // create layer
        ops.create_engine_layer = function (callback) {

            console.log('Creating layer...');

            var layer_json = {
                "projectUuid": tmp.project.uuid,
                "data": {
                    "postgis": tmp.tile_layer
                },
                "metadata": tmp.tile_layer.metadata,
                "title": MAPIC_API_DATASET_TITLE || 'New dataset',
                "description": "",
                "file": tmp.tile_layer.file_id,
                "layer_type" : "defo_raster",
                "style" : default_style,
                "access_token": access_token
            }

            // create tile layer
            api.post('/v2/layers/create')
            .send(layer_json)
            .end(function (err, response) {
                if (err) return callback(err);
                var body = response.body;
                tmp.layer = body;
                callback();
            });

        };

    } else {
        console.log('Using existing benchmark data...');
    };

    // // get layer
    // ops.get_layer = function (callback) {

    //     var layer_id = MAPIC_BENCHMARK_UPLOADED_DATA_LAYER || tmp.layer.id;
    //     console.log('get_layer!!');
    //     console.log('layer_id: ', layer_id);
    //     tmp.layer_id = layer_id;


    //     api.get('/v2/tiles/layer')
    //     .query({
    //         layerUuid : layer_id,
    //         access_token : access_token
    //     })
    //     .end(function (err, response) {
    //         if (err) return callback(err);
    //         // console.log('getlayer response', response.text, err);

    //         var layer = JSON.parse(response.text);
    //         var metadata = JSON.parse(layer.options.metadata);
    //         var extent = metadata.extent;

    //         // console.log('metadat: ', metadata);
    //         console.log('layuer: ', layer);
    //         console.log('extent:', extent);

    //         tmp.extent = extent;

    //         tmp.getLayer = response.text;
    //         callback();
    //     });

    // };


    // run benchmark
    ops.benchmark = function (callback) {
        var n = 0;
        var m = 0;
        console.log('Benchmarking...');

        // var set_of_tiles = tools._getPreRenderTiles(tmp.extent, tmp.layer_id);
        // console.log('set_of_tiles', set_of_tiles, _.size(set_of_tiles));

        // create tile requests
        var tile_requests = [];
        // var benchmark_tiles = [];
        var MAPIC_BENCHMARK_NUMBER_OF_TILES = process.env.MAPIC_BENCHMARK_NUMBER_OF_TILES || 100;
        // _.each(tiles, function (t) {
        //     var ta = t.replace('MAPIC_DOMAIN', process.env.MAPIC_DOMAIN);
        //     var tb = ta.replace('LAYER_ID', MAPIC_BENCHMARK_UPLOADED_DATA_LAYER);
        //     tile_requests.push(tb);
        // });
        // while (benchmark_tiles.length < MAPIC_BENCHMARK_NUMBER_OF_TILES) {
        //     benchmark_tiles = benchmark_tiles.concat(tile_requests);
        // }

        // _.each(set_of_tiles, function (tile) {
        //     var tile_url = 'https://tiles-a-' + process.env.MAPIC_DOMAIN + '/v2/tiles/' + tile.layer_id + '/' + tile.z + '/' + tile.x + '/' + tile.y + '.png';
        //     tile_url += '?force_render=true&access_token=' + access_token;
        //     tile_requests.push(tile_url);
        // });

        // console.log('tile_requests', tile_requests, _.size(tile_requests));

        // // get exact number of tile request
        // var benchmark_tiles =  _.slice(tile_requests, 0, MAPIC_BENCHMARK_NUMBER_OF_TILES);

        // console.log('benchmark_tiles', benchmark_tiles, _.size(benchmark_tiles));

        var bench_size = 'large';
        var tile_url_template = benchmark_json[bench_size].tiles;
        var tile_layer_id = benchmark_json[bench_size].layer_id;
        var mapic_domain = process.env.MAPIC_DOMAIN;

        _.each(tile_url_template, function (t) {

            var a = t.replace('MAPICDOMAIN', mapic_domain);
            var b = a.replace('LAYERID', tile_layer_id);
            var url = b + '?force_render=true&access_token=' + access_token;

            // 20 urls
            tile_requests.push(url);
        });

        var template_size = _.size(tile_url_template);
        var desired_tiles = MAPIC_BENCHMARK_NUMBER_OF_TILES;
        var multiplier = parseInt(desired_tiles / template_size); // eg. 300 / 20 = 15

        console.log('template_size', template_size);
        console.log('desired_tiles', desired_tiles);
        console.log('multiplier', multiplier);

        var all_benchmarks_requests = [];
        _.times(multiplier, function (i) {
            all_benchmarks_requests.push(tile_requests);
        });

        all_benchmarks_requests = _.flatten(all_benchmarks_requests);

        console.log('size all_benchmarks_requests', _.size(all_benchmarks_requests));

        console.log('all_benchmarks_requests', all_benchmarks_requests);


        // mark start of bench
        var timeStart = Date.now();

        // limit concurrent requests
        var req_ops = [];
        _.each(all_benchmarks_requests, function (url) {
            req_ops.push(function (done) {
                console.log('url', url);
                // request tile
                // var tile = url + '?force_render=true&access_token=' + access_token;
                // console.log('tile:', tile);
                request(url, done);
            });
        });

        async.parallelLimit(req_ops, 100, function (err, results) {
            if (err) return callback(err);   

            // calc benchmark
            var timeEnd = Date.now();
            var benched = timeEnd - timeStart;

            // print benchmark as ms only
            console.log('');
            console.log('Benchmark completed:', benched, 'ms');
            console.log('');

            callback();
        });

    };


    ops.cleanup = function (callback) {
        console.log('Cleaning up...');

        if (tmp.project) {

            // remove project
            api.post(endpoints.projects.delete)
            .send({
                project_id: tmp.project.uuid,
                access_token: access_token
            })
            .end(function (err, res) {
                if (err) return done(err);
                callback();
            });

        } else {
            callback();
        }
    }

    async.series(ops, function (err, results) {

        if (err) {
            console.log('Error: ', err);
            console.log('Exiting!');
            process.exit(1);
        }

        // clean exit
        process.exit(0);
    });


});

var tools = {

    _getPreRenderTiles : function (extent, layer_id) {
        var tiles = [];
        var zoom = 10;
        _.times(4, function (z) {
            // z++;
            var zz = zoom + z;
            tiles.push(tools._getPreRenderTilesAtZoom(extent, layer_id, zz));
        });
        return _.flatten(tiles);
    },

    _getPreRenderTilesAtZoom : function (extent, layer_id, zoom) {

        // latitude
        var north = parseFloat(extent[1]);
        var south = parseFloat(extent[3]);

        // longitutde
        var west = parseFloat(extent[0]);
        var east = parseFloat(extent[2]);

        var minLng = west;
        var maxLng = east;
        var minLat = south;
        var maxLat = north;

        var minTileX = tools.lon_to_tile_x(minLng, zoom);
        var maxTileX = tools.lon_to_tile_x(maxLng, zoom);

        var minTileY = tools.lat_to_tile_y(minLat, zoom);
        var maxTileY = tools.lat_to_tile_y(maxLat, zoom);

        var x = minTileX;
        var z = zoom;
        var tiles = [];
        while (x <= maxTileX) {
            var y = minTileY;
            while (y <= maxTileY) {
                y++;
                var tile = layer_id + '/' + z + '/' + y + '/' + x
                var tile = {
                    layer_id : layer_id, 
                    layerUuid : layer_id,
                    z : z, 
                    x : x, 
                    y : y,
                    type : 'png',

                }
                tiles.push(tile);
            }
            x++;
        }
        return tiles;
    },

    deg_to_rad : function (deg) {
        return deg * Math.PI / 180;
    },
    lon_to_tile_x : function (lon, zoom) {
        return parseInt(Math.floor( (lon + 180) / 360 * (1<<zoom) ));
    },
    lat_to_tile_y : function (lat, zoom) {
        return Math.floor((1 - Math.log(Math.tan(tools.deg_to_rad(lat)) + 1 / Math.cos(tools.deg_to_rad(lat))) / Math.PI) / 2 * Math.pow(2, zoom));
    },
}
