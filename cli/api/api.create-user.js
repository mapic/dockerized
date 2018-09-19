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
const MAPIC_USER_CREATE_EMAIL=process.env.MAPIC_USER_CREATE_EMAIL
const MAPIC_USER_CREATE_USERNAME=process.env.MAPIC_USER_CREATE_USERNAME
const MAPIC_USER_CREATE_FIRSTNAME=process.env.MAPIC_USER_CREATE_FIRSTNAME
const MAPIC_USER_CREATE_LASTNAME=process.env.MAPIC_USER_CREATE_LASTNAME

if (!MAPIC_USER_CREATE_EMAIL || !MAPIC_USER_CREATE_USERNAME || !MAPIC_USER_CREATE_FIRSTNAME || !MAPIC_USER_CREATE_LASTNAME) {
    console.log('Missing arguments.')
    process.exit(1);
}

token(function (err, access_token) {
  
    var userData = {
        username : MAPIC_USER_CREATE_USERNAME,
        email : MAPIC_USER_CREATE_EMAIL,
        firstname : MAPIC_USER_CREATE_FIRSTNAME,
        lastname : MAPIC_USER_CREATE_LASTNAME,
        password : crypto.randomBytes(16).toString('hex')
    }

    // empty mask data
    api.post(endpoints.users.create)
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
        console.log('The user was successfully created! Log in to Mapic @ ' + process.env.MAPIC_API_DOMAIN + ' with these credentials:')
        console.log('Email:     ', MAPIC_USER_CREATE_EMAIL);
        console.log('Password:  ', userData.password);
       
        process.exit(0);
    });
});
