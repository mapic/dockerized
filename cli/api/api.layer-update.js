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
    debug : true
}
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
const MAPIC_API_LAYER_UPDATE_LAYER_ID = process.env.MAPIC_API_LAYER_UPDATE_LAYER_ID;
const MAPIC_API_LAYER_UPDATE_DATASET = process.env.MAPIC_API_LAYER_UPDATE_DATASET;
const VERBOSE = (process.env.MAPIC_API_VERBOSE == "true");
var uploaded;

ops.upload = function (done) {

    Cube.upload_data({
        path : MAPIC_API_LAYER_UPDATE_DATASET
    }, function (err, result) {
        if (err) return done(err);
        uploaded = result;
        console.log('Uploaded', result.filename);
        done();
    });

}

ops.add_dataset = function (done) {

    // add dataset to cube
    Cube.add_dataset({
        cube_id : MAPIC_API_LAYER_UPDATE_LAYER_ID,
        datasets : [{
        id : uploaded.file_id,
        description : uploaded.filename,
        timestamp : parse_date_YYYYMMDD(uploaded.filename)
    }]
    }, function (err, cube) {
        if (err) return done(err);
        console.log('Added datasets to cube.', err);
        done();
    });
}


async.series(ops, function (err, results) {
    if (err) {
        console.log('\nSomething went wrong!', err);
        return process.exit(1);
    }

    console.log('All done.');

});








function parse_date(f) {
    var d = dataset.options.dateformat;
    if (d == "YYYYMMDD") return parse_date_YYYYMMDD(f);
    if (d == "YYYYDDD") return parse_date_YYYY_DDD(f);
}

// helper functions
function parse_date_YYYY_DDD(f) {
    // f is eg. "SCF_MOD_2014_002.tif"
    var a = f.split('.');
    var b = a[0].split('_');
    var year = b[2];
    var day = b[3];
    var yd = year + '-' + day;
    var date = moment.utc(yd, "YYYY-DDDD").format();
    return date;
}

function parse_date_YYYYMMDD(f) {
    // f is eg. "SCF_MOD_20150101.tif"
    var a = f.split('.');
    console.log('a:', a);
    var b = a[0].split('_').reverse();
    console.log('b:', b);
    var dato = b[0];
    console.log('dato: ', dato);
    var date = moment.utc(dato, "YYYYMMDD").format();
    return date;
}




