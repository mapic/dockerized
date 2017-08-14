var supertest = require('supertest');
var utils = require('./utils');
var token = utils.token;
var MAPIC_API_CREATE_PROJECT_NAME = process.env.MAPIC_API_CREATE_PROJECT_NAME;  
var MAPIC_API_CREATE_PROJECT_PUBLIC = process.env.MAPIC_API_CREATE_PROJECT_PUBLIC; 
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0" 
var domain = (process.env.MAPIC_API_DOMAIN == 'localhost') ? 'https://172.17.0.1' : 'https://' + process.env.MAPIC_API_DOMAIN;
var api = supertest(domain);


token(function (err, access_token) {
    var project_json = {
        "name": MAPIC_API_CREATE_PROJECT_NAME || 'New project - ' + new Date().toDateString(),
        "description": "",
        "access": {
            "edit": [],
            "read": [],
            "options": {
                "share": true,
                "download": true,
                "isPublic": MAPIC_API_CREATE_PROJECT_PUBLIC
            }
        },
        "access_token": access_token
    };

    // create project
    api.post('/v2/projects/create')
    .send(project_json)
    .end(function (err, response) {
        if (err) {
            console.log(err);
            process.exit(1);
        }
        var body = response.body;
        console.log(body.project.uuid);
        process.exit(0);
    });
});
