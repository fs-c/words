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
const { highlight } = require('highlightjs');

const {
    parseItem, copyFolder, removeFolder, prettyDate,
} = require('./src/utils');

const cwd = require('process').cwd();

marked.setOptions({
    highlight: (code, lang) => highlight(lang, code).value,
});

// Array of all parsed items, filter out those where parsing failed.
const items = fs.readdirSync(path.join(cwd, 'content'))
    .map((item) => path.resolve('content', item), 'utf8').map(parseItem)
    .filter((item) => item);

// Absolute path to the public/ folder.
const publicPath = path.resolve(path.join(cwd, 'public'));

// Remove and recreate it if it exists.
if (fs.existsSync(publicPath))
    removeFolder(publicPath);

fs.mkdirSync(publicPath);

// Copy static files from static/ into public/static/.
copyFolder(path.resolve(path.join(cwd, 'static')),
    path.resolve(path.join(cwd, 'public/static')));

const templates = {
    item: fs.readFileSync('templates/item.html', 'utf8'),
    front: fs.readFileSync('templates/front.html', 'utf8'),
}

// Build items and front in one loop for performance.
for (let i = 0; i < items.length; i++) {
    const item = items[i];

    // Name of the item on disk, without extension.
    const { name } = path.parse(item.path);
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

    const date = items[i].frontMatter.date = new Date(item.frontMatter.date);

    items[i].frontMatter.absoluteDate = `${date.getFullYear()}-${date.getMonth()}`
        + `-${date.getDate()}`;

    items[i].shortPath = name;
}

const renderedFront = mustache.render(templates.front, {
    // Sort items by date in descending order
    items: items.sort((a, b) => a.frontMatter.date < b.frontMatter.date),
});

fs.writeFileSync(path.join(publicPath, 'index.html'), renderedFront);
