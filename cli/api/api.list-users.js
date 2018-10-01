var supertest = require('supertest');
var endpoints = require('./endpoints');
var utils = require('./utils');
var token = utils.token;
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_API_DOMAIN;
var api = supertest(domain);
var Table = require('easy-table');

token(function (err, access_token) {
  
    api.get(endpoints.users.list)
    .query({access_token : access_token})
    .end(function (err, res) {
        if (err) {
            console.log('Something went wrong:', err);
            console.log('Quitting!');
            process.exit(1);
        }
        
        var users = res.body;
        if (users.error) {
            console.log(users.error);
            process.exit(1);
        }

        var t = new Table;
        users.forEach(function (u, i) {
            
            // columns
            t.cell('#', i);
            t.cell('Username', u.username);
            t.cell('First Name', u.firstName);
            t.cell('Last Name', u.lastName);
            t.cell('Email', u.local.email);
            t.cell('ID', u.uuid);
            t.cell('Super', (u.access.super ? 'YES' : ''))
            t.newRow();

        });

        // pretty print
        t.sort();
        console.log('\n');
        console.log(t.toString());
        process.exit(0);
    });
});
