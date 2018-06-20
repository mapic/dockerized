const jsftp = require("jsftp");
const async = require('async');
const _ = require('lodash');
const supertest = require('supertest');
const api = supertest('https://' + process.env.MAPIC_API_DOMAIN);
const moment = require('moment');
const fs = require('fs');
const path = require('path');

// connect
const ftp = new jsftp({
  host: process.env.MAPIC_FTP_HOST, // Host name for the current FTP server.
  port: process.env.MAPIC_FTP_PORT, // Port number for the current FTP server (defaults to 21).
  user: process.env.MAPIC_FTP_USER, // Username
  pass: process.env.MAPIC_FTP_PASS, // Password
});

const CUBE_ID = process.argv[2];
if (!CUBE_ID) {
    console.log('');
    console.log('Usage: node ftp-update-scf-cube.js CUBE_ID');
    console.log('');
    process.exit(1);
}

console.log('CUBE_ID: ', CUBE_ID);

// process.exit();

const PATTERN = 'SCF_MOD_';
const DATE_PATTERN = 'YYYYMMDD';
// const CUBE_ID = "cube-c47bc1da-2cdb-40a5-983c-e656a916060b";
var cube_object = {};

var access_token = '';
var filtered_files = [];
var filtered_date_files = [];
var ftp_files = [];
var scf = {};
var ops = [];

ops.push(function (callback) {
    api.get('/v2/users/token')
    .query({
        username : process.env.MAPIC_API_USERNAME,
        password : process.env.MAPIC_API_AUTH,
    })
    .send()
    .end(function (err, res) {
        if (err) return callback(err);
        var tokens = JSON.parse(res.text);
        access_token = tokens.access_token;
        console.log('access_token', access_token);
        callback();
    });
});

ops.push(function (callback) {
    ftp.ls(".", callback);
});

ops.push(function (files, callback) {

    ftp_files = files;

    files.forEach(function (f) {

        // filter out only relevant files
        if (_.includes(f.name, PATTERN)) {
            filtered_files.push(f.name);
        }

    });

    callback(null);
});

ops.push(function (callback) {

    // get cube
    api.get('/v2/cubes/get')
    .query({
        access_token : access_token,
        cube_id : CUBE_ID
    })
    .end(function (err, res) {
        if (err) return callback(err);
        var cube = res.body;
        cube_object = cube;
        callback(null, cube);
    });

});

ops.push(function (cube, callback) {

    var datasets = cube.datasets;

    // get last dataset
    var last = datasets.reverse()[0];
    var last_filename = last.description;
    var date_string_1 = last_filename.split(PATTERN)[1];
    var date_string = date_string_1.split('.tif')[0];
    var last_date = moment(date_string, DATE_PATTERN);

    console.log('last_date', last_date);

    // find files in ftp which are AFTER the last date in dataset
    filtered_files.forEach(function (f) {

        var date_string_1 = f.split(PATTERN)[1];
        var date_string = date_string_1.split('.tif')[0];
        var ff_date = moment(date_string, DATE_PATTERN);

        // query
        if (ff_date.isAfter(last_date)) {
            filtered_date_files.push(f);
        }
    });

    console.log('filtered_files', filtered_files)
    console.log('filtered_date_files', filtered_date_files);

    callback();
});

ops.push(function (callback) {

    // for each file
    async.eachSeries(filtered_date_files, function (file, done) {

        console.log('');
        console.log('');
        console.log('');
        console.log('getting file from ftp:', file);

        // download file
        ftp.get(file, '/tmp/' + file, function (err, result) {
            
            if (err) {
                console.error("There was an error retrieving the file.");
                return done(err);
            }

            console.log('');
            console.log('');
            console.log('');
            console.log('got file from ftp:', file);
            console.log('result:', result);

            fs.stat('/tmp/' + file, function(err, stats) {
                console.log('stats on file:', err, stats);


                // upload dataset
                api.post('/v2/data/import')
                .type('form')
                .field('access_token', access_token)
                .field('data', fs.createReadStream(path.resolve('/tmp/' + file)))
                .end(function (err, res) {
                    if (err) {
                        console.log('post/import err:', err);
                        return done(err);
                    }
                    var status = res.body;

                    console.log('status.file_id', status.file_id);

                    if (!status.file_id) {
                        console.log('No file id -- something went wrong during upload!')
                        console.log('status: ', status);
                        console.log('skipping....');
                        return done();
                    } else {
                        console.log('status:', status);
                    }

                    // get timestamp
                    var d1 = file.split(PATTERN)[1];
                    var d2 = d1.split('.tif')[0];
                    var timestamp = moment(d2, DATE_PATTERN).format();

                    // test data
                    var data = {
                        access_token : access_token,
                        cube_id : CUBE_ID,
                        datasets : [{
                            id : status.file_id,
                            description : file,
                            timestamp : timestamp
                        }]
                    }

                    // add dataset to cube
                    api.post('/v2/cubes/add')
                    .send(data)
                    .end(function (err, res) {
                        if (err) return done(err);
                        var cube = res.body;
                        

                        setTimeout(done, 2000);
                        // done();
                    });
                
                });
            });
        });

    // final callback
    }, callback);

});


// get SCF JSON data file from ftp
ops.push(function (callback) {

    // for each of masks in cube

    var cube = cube_object;

    var mask_names = [];
    var filtered_mask_names = [];
    cube.masks.forEach(function (m) {
        // mask_names.push('mask-' + m.meta.title + '.scf.json');

        if (m.meta && m.meta.scfdata) {
            var mask_name = m.meta.scfdata;
            mask_names.push(mask_name);
        }
    });

    ftp_files.forEach(function (f) {
        if (_.includes(mask_names, f.name)) {
            filtered_mask_names.push(f.name);
        }

    });

    // for each file
    async.eachSeries(filtered_mask_names, function (file, done) {

        // download file
        var filepath = '/tmp/' + file;

        ftp.get(file, filepath, function (err) {

            var scf_file_contents = fs.readFileSync(filepath, 'utf-8');

            scf[file] = scf_file_contents;

            setTimeout(done, 2000);
        });
    }, callback);


});

ops.push(function (callback) {


    _.each(scf, function (value, key) {

        var scf_data = JSON.parse(value);
        var scf_filename = key;

        _.each(cube_object.masks, function (v, idx) {

            if (v.meta && v.meta.scfdata == scf_filename) {
                console.log('matching maskname... ', v.meta.scfdata);

                // check if same
                var original_data = JSON.stringify(cube_object.masks[idx].data);
                var new_data = JSON.stringify(scf_data);

                if (original_data != new_data) {
                    cube_object.masks[idx].data = scf_data;

                    console.log('updated SCF cube data!');
                }
            }
        });
    });

    callback();
});

ops.push(function (callback) {
    // save cube with new data...
    async.eachSeries(cube_object.masks, function (m, done) {

        // debug
        // return callback();

        // update cube mask
        api.post('/v2/cubes/updateMask')
        .send({
            access_token : access_token,
            cube_id : CUBE_ID,
            mask : m
        })
        .end(function (err, result) {
            console.log('updated mask data, err, result', err);
            setTimeout(function () {
                done(err);
            }, 2000);
        });
    }, callback);
});


async.waterfall(ops, function (err) {
    console.log('async done', err);
    process.exit();
});


