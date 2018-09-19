var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_API_DOMAIN;
var api = supertest(domain);
var Table = require('easy-table');
var crypto   = require('crypto');

// get env
const MAPIC_USER_PROMOTE_EMAIL=process.env.MAPIC_USER_PROMOTE_EMAIL

if (!MAPIC_USER_PROMOTE_EMAIL) {
    console.log('Missing arguments.')
    process.exit(1);
}

token(function (err, access_token) {
  
    var userData = {
        email : MAPIC_USER_PROMOTE_EMAIL,
        access_token : access_token
    }

    // empty mask data
    api.post(endpoints.users.promote)
    .send(userData)
    .end(function (err, res) {
        if (err) {
            console.log(err);
            process.exit(1);
        }

        var user = res.body;

        if (user.error) {
            console.log(user.error.message);
            process.exit(1);
        }
        
        // feedback
        console.log('The user ' + MAPIC_USER_PROMOTE_EMAIL + ' was successfully promoted to super!');
        process.exit(0);
    });
});
