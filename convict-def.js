var convict = require('convict');

// Define a schema
var conf = convict({
    env: {
        doc: "The applicaton environment.",
        format: ["production", "development", "staging"],
        default: "development",
        env: "NODE_ENV"
    },
    backend: {
        doc: "backend url",
        format: "url",
        default: "http://127.0.0.1:5000",
        env: "BACKEND"
    },
    uploadTo: {
        doc: "upload to",
        format: "url",
        default: "http://127.0.0.1:5000/upload",
        env: "UPLOAD_TO"
    }
});

// Load environment dependent configuration
var env = conf.get('env');
env != 'development' && conf.loadFile('./config/' + env + '.json');

// Perform validation
conf.validate({strict: true});

module.exports = conf;
