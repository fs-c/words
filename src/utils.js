const fs = require('fs');
const path = require('path');

const cwd = require('process').cwd();

/**
 * @typedef {Object} Item
 * @property {string} path The absolute path to the item on disk
 * @property {number} content Trimmed  content with front matter stripped out
 * @property {string} frontMatter.title Item title
 * @property {string} frontMatter.date Publication date in any supported format
 */

/**
 * @param {string} path Absolute path to the file that is to be parsed as an
 *                      item.
 * 
 * @returns {Item}
 */
const parseItem = exports.parseItem = (path) => {
    let file = null;
    let frontMatter = null;

    try {
        file = fs.readFileSync(path, 'utf8');

        if (file[0] !== '{')
            throw new Error("Failed to find front matter");
            
        frontMatter = JSON.parse(file.slice(0, file.indexOf('}') + 1));
        
    // TODO: Maybe fall back to some defaults here?
    } catch(err) { return console.log(err); }

    // TODO: Verify that content doesn't end up to be completely bogus.
    const content = file.slice(file.indexOf('}') + 1).trim();

    return { path, content, frontMatter };
}

/**
 * Recursively copies a folder and all of its children including their contents.
 * 
 * @param {string} from Absolute path to the source folder
 * @param {string} to Absolte path to the destination folder
 */
const copyFolder = exports.copyFolder = (from, to) => {
    if (!fs.existsSync(from))
        return console.error('copyFolder: invalid path %s', from);

    if (!fs.existsSync(to))
        try { fs.mkdirSync(to); } catch (err) { return console.error(err); }

    // Array of absolute paths to all files and folders in origin.
    const folder = fs.readdirSync(from)
        .map((file) => path.resolve(from, file));

    for (const file of folder) {
        if (fs.statSync(file).isDirectory()) {
            // Get the last segment, which is always the folder we are currently
            // copying, and append it to our destination. This will grow
            // as we recursively iterate through the tree.
            const segment = file.slice(file.lastIndexOf(path.sep));
            const nested = path.join(to, segment);

            if (!fs.existsSync(nested))
                try { fs.mkdirSync(nested); } catch (err) {
                    return console.error(err);
                }

            copyFolder(file, nested);
        } else {
            const content = fs.readFileSync(file);
            const { ext, name } = path.parse(file);
            const destination = path.join(to, name);

            try {
                fs.writeFileSync(path.resolve(file, destination) + ext, content);                
            } catch (err) { return console.error(err); }
        }
    }
}

/**
 * Recursively deletes a folder and all of its children including their
 * contents.
 * 
 * @param {string} folder Absolute path to the directory that is to be deleted
 */
const removeFolder = exports.removeFolder = (folder) => {
    if (!fs.existsSync(folder))
        return console.error('removeFolder: invalid path %s', folder);

    // Array of absolute paths to all files and folders in folder to be deleted.
    const contents = fs.readdirSync(folder)
        .map((file) => path.resolve(folder, file));

    for (const file of contents) {
        if (fs.statSync(file).isDirectory()) {
            removeFolder(file);
        } else {
            fs.unlinkSync(file);
        }
    }

    // As we are going "back up" the recursive chain we delete the now empty
    // folders.
    try {
        fs.rmdirSync(folder);
    } catch (err) { return console.error(err); }
}
