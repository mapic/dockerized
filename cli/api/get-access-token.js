var supertest = require('supertest');
var endpoints = require('./endpoints');

// domain resolution compatible with localhost setup (must run from within Docker container)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var MAPIC_API_DOMAIN = process.env.MAPIC_API_DOMAIN || process.env.MAPIC_DOMAIN;
var domain = (MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + MAPIC_API_DOMAIN;

var domain = 'https://maps.edinsights.no';
var api = supertest(domain);
// var debug = (process.env.MAPIC_DEBUG);

var username = 'kris.nackaerts@edinsights.no';
var password = 'lynxvision';

api.post('/v2/users/token')
.send({
    username : username,
    password : password
})
.end(function (err, res) {
    if (err) console.log(err);

    // parse
    var tokens = JSON.parse(res.text);
    var access_token = tokens.access_token;

    console.log('tokens:', tokens);
    console.log('access_token:', access_token);
});