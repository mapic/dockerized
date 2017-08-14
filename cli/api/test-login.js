var utils = require('./utils');

// get user
utils.get_user(function(err, user) {
    var exitCode = (err || !user) ? 1 : 0;
    // process.exit(1); // debug
    process.exit(exitCode);
}, true);
