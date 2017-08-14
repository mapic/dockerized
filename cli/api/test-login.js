var utils = require('./utils');

// get user
utils.get_user(function(err, user) {
    var exitCode = 2;
    if (err) {
        exitCode = 1;
    }
    if (!user) {
        exitCode = 1;
    }
    if (user && user.error) {
        exitCode = 1;
    }
    if (user && user.valid) {
        exitCode = 0;
    }

    // process.exit(1); // debug
    process.exit(exitCode);
}, true);
