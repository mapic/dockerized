var fs = require('fs-extra');
var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_API_DOMAIN;
var api = supertest(domain);

// get variables
const MAPIC_API_VERBOSE = (process.env.MAPIC_API_VERBOSE == "true");
const MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID = process.env.MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID;  
const MAPIC_API_LAYER_MASK_UPDATE_MASK_ID = process.env.MAPIC_API_LAYER_MASK_UPDATE_MASK_ID;  
const MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE = process.env.MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE;
const MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON = process.env.MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON;
const MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON = process.env.MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON;

token(function (err, access_token) {

    // empty mask data
    var data = {
        access_token : access_token,
        cube_id : MAPIC_API_LAYER_MASK_UPDATE_LAYER_ID,
        mask : {}
    }

    // add mask id
    if (MAPIC_API_LAYER_MASK_UPDATE_MASK_ID) {
        data.mask.id = MAPIC_API_LAYER_MASK_UPDATE_MASK_ID;
    }

    // add mask title
    if (MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE) {
        data.mask.meta = data.mask.meta || {};
        data.mask.meta.title = MAPIC_API_LAYER_MASK_UPDATE_MASK_TITLE;
    }

    // if geojson file, add it
    if (MAPIC_API_LAYER_MASK_UPDATE_MASK_GEOJSON) {
        data.mask.geometry = fs.readJsonSync('/mask/mask.geojson');
        data.mask.type = 'geojson'; // todo: topojson
    }

    // if json file, add it
    if (MAPIC_API_LAYER_MASK_UPDATE_MASK_JSON) {
        data.mask.data = JSON.stringify(fs.readJsonSync('/mask/mask.json'));
    }

    api.post('/v2/cubes/updateMask')
    .send(data)
    .end(function (err, res) {
        if (err) console.log('Something went wrong:', err);
        if (MAPIC_API_VERBOSE) {
            console.log('Mask updated successfully!');
        }
    });
});
