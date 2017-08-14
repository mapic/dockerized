// require libs
var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var _ = require('lodash');
var dir = require('node-dir');
var moment = require('moment');
var node_uuid = require('node-uuid');
var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
var args = process.argv;
var stripComments = require('strip-json-comments');
moment.utc(); // set utc

var debug = process.env.MAPIC_DEBUG;

var MAPIC_API_DOMAIN = process.env.MAPIC_API_DOMAIN;
var MAPIC_API_UPLOAD_DATASET = '/mapic_upload' + process.env.MAPIC_API_UPLOAD_DATASET;        // absolute path of dataset
var MAPIC_API_UPLOAD_PROJECT = process.env.MAPIC_API_UPLOAD_PROJECT;        // null if new project
var MAPIC_API_PROJECT_NEW_TITLE = process.env.MAPIC_API_PROJECT_NEW_TITLE;  // name of new project
var MAPIC_API_DATASET_TITLE = process.env.MAPIC_API_DATASET_TITLE;          // name of new dataset
var MAPIC_API_USERNAME = process.env.MAPIC_API_USERNAME;                    // username 
var MAPIC_API_AUTH = process.env.MAPIC_API_AUTH;                            // password

// domain resolution compatible with localhost setup (must run from within Docker container)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + MAPIC_API_DOMAIN;
var api = supertest(domain);
var wd = process.cwd();

debug && console.log('Domain: ', domain);

// default int16 styles
var default_cartocss = "#layer { raster-opacity: 1; raster-colorizer-default-mode: linear; raster-colorizer-default-color: transparent; raster-comp-op: color-dodge; raster-colorizer-stops:  stop(0, rgba(0,0,0,0)) stop(31999, rgba(0,0,0,0)) stop(32000, rgba(255,255,255,0)) stop(32767, rgba(101,253,0,1)) stop(33400, rgba(255,255,0,1)) stop(36999, rgba(255,0,0,1)) stop(37000, rgba(0,0,0,0)) stop(65534, rgba(0,0,0,0), exact);}";
var default_style = "{\"stops\":[{\"val\":32000,\"col\":{\"r\":255,\"g\":255,\"b\":255,\"a\":0},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":0,\"right\":false,\"value\":\"rgba(255,255,255,0)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":0,\"right\":false,\"value\":\"rgba(255,255,255,0)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":32767,\"col\":{\"r\":101,\"g\":253,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":1,\"right\":false,\"value\":\"rgba(101,253,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":1,\"right\":false,\"value\":\"rgba(101,253,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":33400,\"col\":{\"r\":255,\"g\":255,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":2,\"right\":false,\"value\":\"rgba(255,255,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"addButton\":{\"_leaflet_events\":{}},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":2,\"right\":false,\"value\":\"rgba(255,255,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}},{\"val\":36999,\"col\":{\"r\":255,\"g\":0,\"b\":0,\"a\":1},\"DOM\":{\"wrapper\":{},\"container\":{},\"range\":{},\"number\":{},\"colorBall\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":3,\"right\":false,\"value\":\"rgba(255,0,0,1)\",\"className\":\"raster-color\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}}},\"list\":{\"line\":{},\"noWrap\":{},\"noTitle\":{},\"valWrap\":{},\"valInput\":{\"_leaflet_events\":{}},\"colWrap\":{},\"rInput\":{\"_leaflet_events\":{}},\"gInput\":{\"_leaflet_events\":{}},\"bInput\":{\"_leaflet_events\":{}},\"alphaWrap\":{},\"aInput\":{\"_leaflet_events\":{}},\"colorWrap\":{},\"color\":{\"options\":{\"appendTo\":{},\"type\":\"colorball\",\"id\":3,\"right\":false,\"value\":\"rgba(255,0,0,1)\",\"className\":\"stop-list-color-ball\",\"on\":true,\"showAlpha\":true,\"format\":\"rgba\"},\"color\":{}},\"killButton\":{\"_leaflet_events\":{}}}}],\"range\":{\"min\":0,\"max\":65534}}";

// todo: default Byte styles

var ops = {};
var tmp = {};

console.log('');
console.log('Uploading to Mapic API...')

// get user
ops.get_user = function (callback) {
    utils.get_user(function(err, user) {
        if (err) return callback(err);
        tmp.user = user;
        console.log('   Found user')
        debug && console.log('      user:', user);
        callback();
    }, true);
}

ops.upload = function (callback) {

    var dataset_path = MAPIC_API_UPLOAD_DATASET;

    debug && console.log('dataset_path', dataset_path);

    token(function (err, access_token) {
        if (err) {
            console.log("There was an error:", err);
            process.exit(1);
        }
        
        api.post(endpoints.data.import)
        .type('form')
        .field('access_token', access_token)
        .field('data', fs.createReadStream(dataset_path))
        .end(function (err, res) {
            if (err) return callback(err);
            console.log('   Uploaded dataset')
            debug && console.log('      dataset:', res.body);
            tmp.upload_status = res.body;
            callback(err);
        });
    });

}

// to get the File.Model after upload is done processing
// todo: check status first to see if processing is done
ops.get_file = function (callback) {
    console.log('   Checking file...')
    setTimeout(function () {
        token(function (err, access_token) {
            var fileUuid = tmp.upload_status.file_id;
            var GET = '/v2/data/import?fileUuid=' + fileUuid + '&access_token=' + access_token;
            api.get(GET)
            .end(function (err, response) {
                var body = response.body;
                tmp.file_model = body;
                debug && console.log('      get file:', body);
                callback(err);
            });
        });
    }, 10000)
};

if (_.size(MAPIC_API_UPLOAD_PROJECT) == 0) {
    ops.create_project = function (callback) {

        token(function (err, access_token) {
            var project_json = {
                "name": MAPIC_API_PROJECT_NEW_TITLE || 'New project - ' + new Date().toDateString(),
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
                var body = response.body;
                tmp.project = body.project;
                console.log('   Created project')
                debug && console.log('      project:', body.project);
                callback();
            });
        });
    };
} else {
    console.log('   Using existing project')
    tmp.project = {
        uuid : MAPIC_API_UPLOAD_PROJECT
    }
}

ops.create_tile_layer = function (callback) {

    token(function (err, access_token) {

        // todo: rast/raster is not compatible with vector uploads.
        //       need to disccover type automatically

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
            if (err) console.log('err: ', err);
            // console.log('tiles create', err, response);
            var body = response.body;
            tmp.tile_layer = body.options;
            debug && console.log('  Created tile layer');
            callback();
        });
    });
};

ops.create_engine_layer = function (callback) {

    token(function (err, access_token) {

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
            var body = response.body;
            tmp.layer = body;
            debug && console.log('  Created layer.');
            callback();
        });

    });

};


ops.add_to_layermenu = function (callback) {

    token(function (err, access_token) {

        var layermenu_json = {
            "layermenu": [
                {
                    "uuid" : "layerMenuItem-" + node_uuid.v4(),
                    "layer": tmp.layer.uuid,
                    "caption": MAPIC_API_DATASET_TITLE + '-layer',
                    "pos": "0",
                    "opacity": "1",
                    "zIndex": "1"
                }
            ],
            "uuid": tmp.project.uuid,
            "access_token": access_token
        };

        // create tile layer
        api.post('/v2/projects/update')
        .send(layermenu_json)
        .end(function (err, response) {
            var body = response.body;
            console.log('   Added layer to menu')
            debug && console.log('add to layermenu:', body);
            callback();
        });
    });
};



async.series(ops, function (err, results) {
    debug && console.log('All done!');
    debug && console.log(err, results);
    debug && console.log(tmp);

    // error
    if (err) {
        console.log('There was an error. Please try again.')
        console.log('Error:', err);
        process.exit(err);

    // success
    } else {
        
        console.log('');
        console.log('Upload success!');
        console.log('Your data (' + MAPIC_API_UPLOAD_DATASET + ') was uploaded to ' + MAPIC_API_DOMAIN);
        console.log('');
    }
});
