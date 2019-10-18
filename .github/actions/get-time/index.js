const core = require('@actions/core');

try {
    const time = Date.now().toString();
    core.setOutput('time', time);
} catch (err) {
    core.setFailed(err.message);
}