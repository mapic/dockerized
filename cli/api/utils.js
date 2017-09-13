var _ = require('lodash');
var supertest = require('supertest');
var endpoints = require('./endpoints');

// domain resolution compatible with localhost setup (must run from within Docker container)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var MAPIC_API_DOMAIN = process.env.MAPIC_API_DOMAIN || process.env.MAPIC_DOMAIN;
var domain = (MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + MAPIC_API_DOMAIN;
var api = supertest(domain);
var debug = (process.env.MAPIC_DEBUG);

debug && console.log('process.env: ', process.env);

module.exports = utils = {

    token : function (done) {
        utils.get_access_token(function (err, tokens) {
            debug && console.log('token: err, tokens', err, tokens);
            if (tokens && tokens.error) return done(tokens.error.message);
            done(err, tokens.access_token);
        });
    },

    get_user : function (done) {
        utils.token(function (err, access_token) {
            api.get(endpoints.users.token.check)
            .send({access_token : access_token})
            .end(function (err, res) {
                if (err) return done(err);
                var user = res.body;
                if (!user) return done('No such user.');
                done(null, user);
            }); 
        });
    },

    get_access_token : function (done) {
        api.get(endpoints.users.token.token)
        .query({
            username : process.env.MAPIC_API_USERNAME || 'localhost@mapic.io',
            password : process.env.MAPIC_API_AUTH || 'localhost-password'
        })
        .send()
        .end(function (err, res) {
            debug && console.log('get_access_token', err, res);
            if (!res || !res.text) return done('Failed to connect to Mapic API.');
            var tokens = utils.parse(res.text);
            done(err, tokens);
        });
    },

    parse : function (body) {
        if (_.isObject(body)) return body;
        try { var parsed = JSON.parse(body); } 
        catch (e) { return console.log('failed to parse:', body);}
        return parsed;
    },

    // create uuid.v4() with optional prefix
    guid : function (prefix) {
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
        if (prefix) { return prefix + '-' + uuid };
        return uuid;
    },
    rnd : function (len, charSet) {
        charSet = charSet || 'abcdefghijklmnopqrstuvwxyz';
        var randomString = '';
        for (var i = 0; i < len; i++) {
            var randomPoz = Math.floor(Math.random() * charSet.length);
            randomString += charSet.substring(randomPoz,randomPoz+1);
        }
        return randomString;
    },

    missing : function () {
        console.log('Please provide a dataset.json file. See dataset.json.template for an example.');
        console.log('Usage: ./upload_dataset.sh dataset.json');
        return process.exit(1);
    }
}