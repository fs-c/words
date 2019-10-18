const core = require('@actions/core');

try {
    core.setOutput('time', Date.now());
} catch (err) {
    core.setFailed(err.message);
}