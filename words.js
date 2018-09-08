/**
 * - Common Tasks
 *      - Fetch and parse all items
 *      - Create the public/ directory, remove if it already exists
 *      - Copy static/ to public/.
 * 
 * - Build Front
 *      - Reduce items to relevant data: title, date, content snippet
 *      - Insert fetched (meta)data into Front template
 *      - Write resulting HTML to public/index.html
 * 
 * - Build Content
 *      - For every item, parse markdown to HTML
 *      - Insert HTML into Item template
 *      - Write resulting HTML to public/content/<title>.html
 */

const fs = require('fs');
const path = require('path');

const marked = require('marked');
const mustache = require('mustache');

const {
    parseItem, copyFolder, removeFolder, prettyDate,
} = require('./src/utils');

const cwd = require('process').cwd();

console.time('built site in');

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
}

const items = [];
// Array of relative paths to all items.
const files = fs.readdirSync(path.join(cwd, 'content'));

for (const file of files) {
    // This will act as a "staging item".
    const item = parseItem(path.resolve('content', file));

    // Name of the item on disk, without extension.
    const name = file.split('.')[0];
    // Absolute path to the folder for the item in public/.
    const itemPath = path.join(publicPath, name);
    
    fs.mkdirSync(itemPath);

    const renderedItem = mustache.render(templates.item, {
        title: item.frontMatter.title,
        content: marked(item.content),
    });

    fs.writeFileSync(path.join(itemPath, 'index.html'), renderedItem);

    // Now that it's written to disk, prepare the item with information for the
    // front template.

    const date = item.frontMatter.date = new Date(item.frontMatter.date);

    item.frontMatter.absoluteDate = `${date.getFullYear()}-${date.getMonth()}`
        + `-${date.getDate()}`;

    item.shortPath = name;

    // Push the processed item.
    items.push(item);
}

const renderedFront = mustache.render(templates.front, {
    // Sort items by date in descending order.
    items: items.sort((a, b) => a.frontMatter.date < b.frontMatter.date),
});

fs.writeFileSync(path.join(publicPath, 'index.html'), renderedFront);

console.timeEnd('built site in');
