const jsftp = require("jsftp");
const async = require('async');

// connect
const ftp = new jsftp({
  host: process.env.MAPIC_FTP_HOST, // Host name for the current FTP server.
  port: process.env.MAPIC_FTP_PORT, // Port number for the current FTP server (defaults to 21).
  user: process.env.MAPIC_FTP_USER, // Username
  pass: process.env.MAPIC_FTP_PASS, // Password
});

// list files
ftp.ls(".", function (err, res) {

    // debug
    console.log('res:', res);
    process.exit();

    // for each file
    async.eachSeries(res, function (file, callback) {

        // download file
        ftp.get(file.name, 'test-data/' + file.name, function (err) {
            
            if (err) {
                console.error("There was an error retrieving the file.");
                return callback(err);
            }
            
            console.log("File copied successfully!");
            callback();

        });

    // final callback
    }, function (err) {
        if (err) console.log('async err:', err);
        console.log('async done');
        process.exit();
    });
   
});



