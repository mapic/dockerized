// require libs
var fs = require('fs-extra');
var path = require('path');
var async = require('async');
var _ = require('lodash');
var dir = require('node-dir');
var moment = require('moment');
var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
var config = {
    domain : process.env.MAPIC_API_DOMAIN,
    username : process.env.MAPIC_API_USERNAME,
    password : process.env.MAPIC_API_AUTH,
    debug : false
}
// var api = supertest('https://' + config.domain);
var Cube = require('./cube');
var debug = config.debug;
var args = process.argv;
var ops = {};
var tmp = {};
moment.utc(); // set utc

// domain resolution compatible with localhost setup (must run from within Docker container)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var current_domain = config.domain || process.env.MAPIC_DOMAIN;
var domain = (current_domain == 'localhost') ? 'https://172.17.0.1' : 'https://' + current_domain;
var api = supertest(domain);

// get consts
const MAPIC_API_LAYER_CREATE_PROJECT_ID = process.env.MAPIC_API_LAYER_CREATE_PROJECT_ID;
const MAPIC_API_LAYER_CREATE_LAYER_TITLE = process.env.MAPIC_API_LAYER_CREATE_LAYER_TITLE || 'timeseries-layer';
const VERBOSE = (process.env.MAPIC_API_VERBOSE == "true");

var ops = {};

ops.create_cube = function (callback) {
   
    Cube.create({
        title : MAPIC_API_LAYER_CREATE_LAYER_TITLE,
        style : Cube.get_default_cartocss(),
        options : {
            type : 'scf',
            dateformat : 'YYYYMMDD'
        },
    }, function (err, cube) {
        if (err) return callback(err);
        VERBOSE && console.log("Creating layer...done");
        tmp.cube = cube;
        callback();
    });

};

ops.create_layer = function (callback) {
    
    var layerOptions = {
        projectUuid : MAPIC_API_LAYER_CREATE_PROJECT_ID, // pass to automatically attach to project
        data : { cube : tmp.cube },
        title : MAPIC_API_LAYER_CREATE_LAYER_TITLE,
        file : 'file-' + tmp.cube.cube_id,
        style : Cube.get_default_cartocss() // save default json style
    }

    // create wu layer
    Cube.create_layer(layerOptions, function (err, layer) {
        if (err) return callback(err);
        VERBOSE && console.log('Creating tile layer...done')
        VERBOSE && console.log('Adding layer to project...done')
        tmp.layer = layer;
        callback();
    });
};

// add layer to layermenu
ops.add_layer_to_layermenu = function (callback) {
    var options = {
        layermenu : [{
            uuid : utils.guid('layerMenuItem'),
            layer : tmp.layer.uuid,
            caption : MAPIC_API_LAYER_CREATE_LAYER_TITLE,
            pos : 0,
            zIndex : 1,
            opacity : 1
        }],
        uuid : MAPIC_API_LAYER_CREATE_PROJECT_ID
    };

    Cube.update_project(options, function (err, layermenu) {
        VERBOSE && console.log('Adding layer to layermenu...done');
        callback(err);
    });
}   

// run ops
async.series(ops, function (err, results) {
    if (err) {
        console.log('\nSomething went wrong!', err);
        return process.exit(1);
    }

    VERBOSE && console.log('All done! Layer ID:');
    console.log(tmp.cube.cube_id);

});

