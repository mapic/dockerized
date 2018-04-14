const jsftp = require("jsftp");
const async = require('async');
const _ = require('lodash');

// connect
const ftp = new jsftp({
  host: process.env.MAPIC_FTP_HOST, // Host name for the current FTP server.
  port: process.env.MAPIC_FTP_PORT, // Port number for the current FTP server (defaults to 21).
  user: process.env.MAPIC_FTP_USER, // Username
  pass: process.env.MAPIC_FTP_PASS, // Password
});


const CUBE_ID = "cube-c12781d6-6f54-466f-98ef-9e66073fd454";

var ops = [];

ops.push(function (callback) {
    ftp.ls(".", callback);
});

ops.push(function (files, callback) {

    var filtered_files = [];

    files.forEach(function (f) {

        // filter out only relevant files
        var pattern = 'SCF_MOD_';
        if (_.includes(f.name, pattern)) {
            filtered_files.push(f.name);
        }

    });

    callback(null, filtered_files);
});

ops.push(function (files, callback) {
    console.log('filtered_files: ', files);

    callback();
})


async.waterfall(ops, function (err) {
    console.log('async done', err);
    process.exit();
})


  // // debug
  //       console.log('res:', res);
  //       process.exit();

  //       // for each file
  //       async.eachSeries(res, function (file, callback) {

  //           // download file
  //           ftp.get(file.name, 'test-data/' + file.name, function (err) {
                
  //               if (err) {
  //                   console.error("There was an error retrieving the file.");
  //                   return callback(err);
  //               }
                
  //               console.log("File copied successfully!");
  //               callback();

  //           });

  //       // final callback
  //       }, function (err) {
  //           if (err) console.log('async err:', err);
  //           console.log('async done');
  //           process.exit();
  //       });