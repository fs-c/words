/**
 * @param {object} date A JS Date object
 * 
 * @returns {string} the distance between now and the given date (which has to
 *                   be in the past) in human words.
 */
function prettyDate(date) {
    if (!date || typeof date !== 'object')
        return;

    // Difference from now to date in seconds.
    const diff = (new Date().getTime() - date.getTime()) / 1000;
    // Difference in days.
    const dayDiff = Math.floor(diff / (60 * 60 * 24));

    return ((
        dayDiff == 0 && (
            diff < 60 && "just now" ||
            diff < 120 && "1 minute ago" ||
            diff < (60 * 60) && Math.floor(diff / 60) + " minutes ago" ||
            diff < (60 * 60) * 2 && "1 hour ago" ||
            diff < (60 * 60 * 24) && Math.floor(diff / 3600) + " hours ago"
        )
    ) || (
        dayDiff == 1 && "1 day ago" ||
        dayDiff < 7 && dayDiff + " days ago" ||
        dayDiff < 31 && Math.ceil(dayDiff / 7) + " weeks ago" ||
        dayDiff < 365 && Math.ceil(dayDiff / 31) + " months ago" ||
        Math.ceil(dayDiff / 365) + " years ago"
    ));
};
