var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_API_DOMAIN;
var api = supertest(domain);
const MAPIC_API_LAYER_MASK_CREATE_LAYER_ID = process.env.MAPIC_API_LAYER_MASK_CREATE_LAYER_ID;  
const MAPIC_API_VERBOSE = (process.env.MAPIC_API_VERBOSE == "true");

token(function (err, access_token) {
  
    // empty mask data
    var data = {
        access_token : access_token,
        cube_id : MAPIC_API_LAYER_MASK_CREATE_LAYER_ID,
        mask : {
            type : 'geojson',
            geometry : null
        }
    }

    api.post(endpoints.cube.mask)
    .send(data)
    .end(function (err, res) {
        if (err) console.log('err', err);
        var mask = res.body;
        if (MAPIC_API_VERBOSE) {
            console.log('Created mask');
        }
        console.log(mask.id);
    });
});
