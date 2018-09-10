/**
 * - Staging
 *      - Fetch the paths to all items
 *      - Create the public/ directory, remove if it already exists
 *      - Copy static/ to public/
 * 
 * - Item processing: for all items...
 *      - Parse the item, including markown
 *      - Render the item and write it to disk
 *      - Tack on information relevant to front building
 *  
 * - Front building
 *      - Sort items in descending order by date created
 *      - Render the front and write it to disk
 */

const fs = require('fs');
const path = require('path');

const marked = require('marked');
const mustache = require('mustache');

const {
    parseItem, copyFolder, removeFolder,
} = require('./src/utils');

const cwd = require('process').cwd();

const start = process.hrtime();

// Absolute path to the public/ folder, which will be our deployment area.
const publicPath = path.resolve(path.join(cwd, 'public'));

// Delete it and all contents recursively if it already exists.
if (fs.existsSync(publicPath))
    removeFolder(publicPath);

fs.mkdirSync(publicPath);

// Copy static files into our deployment directory.
copyFolder(path.resolve(path.join(cwd, 'static')),
    path.resolve(path.join(cwd, 'public/static')));

const templates = {
    item: fs.readFileSync('templates/item.html', 'utf8'),
    front: fs.readFileSync('templates/front.html', 'utf8'),
};

const items = [];
// Array of relative paths to all items.
const files = fs.readdirSync(path.join(cwd, 'content'));

for (const file of files) {
    // This will act as a "staging item".
    const item = parseItem(path.resolve('content', file));

    // Absolute path to the folder for the item in public/.
    const itemPath = path.join(publicPath, item.slug);

    fs.mkdirSync(itemPath);

    const renderedItem = mustache.render(templates.item, {
        title: item.title,
        content: marked(item.content),
    });

    fs.writeFileSync(path.join(itemPath, 'index.html'), renderedItem);

    items.push(item);
}

const renderedFront = mustache.render(templates.front, {
    // Sort items by date in descending order.
    items: items.sort((a, b) => new Date(a.date) < new Date(b.date)),
});

fs.writeFileSync(path.join(publicPath, 'index.html'), renderedFront);

const diff = process.hrtime(start);

console.log(`built ${items.length} items in ${diff[0]}s and ${diff[1] / 1000000}ms`);
