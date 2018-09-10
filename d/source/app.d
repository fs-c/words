import std.file;
import std.path;
import std.stdio : writeln;
import std.exception;
import std.datetime.date;
import std.algorithm.sorting;


import item;
import mustache;

alias MustacheEngine!(string) Mustache;

void _main()
{
	immutable publicPath = absolutePath("public");

	if (publicPath.exists)
		publicPath.rmdirRecurse;

	publicPath.mkdir;

	immutable staticPath = absolutePath("static");
	copyDir(staticPath, buildPath(publicPath, "static"));

	immutable templatesPath = absolutePath("templates");
	immutable itemTemplate = buildPath(templatesPath, "item");
	immutable frontTemplate = buildPath(templatesPath, "front");

	Mustache mustache;
	mustache.ext = "html";	
	auto itemContext = new Mustache.Context;
	auto frontContext = new Mustache.Context;

	Item[] items;

	immutable contentPath = absolutePath("content");
	foreach(string e; dirEntries(contentPath, SpanMode.shallow)) {
		Item i = parseItem(e);

		items.length++;
		items[items.length - 1] = i;

		immutable itemFolder = buildPath(publicPath, i.slug);
		immutable itemPath = buildPath(itemFolder, "index.html");
		mkdir(itemFolder);

		itemContext["title"] = i.title;
		itemContext["content"] = i.content;

		write(itemPath, mustache.render(itemTemplate, itemContext));	
	}

	items.sort!("a.date > b.date");

	foreach(ref i; items) {
		auto sub = frontContext.addSubContext("items");

		sub["slug"] = i.slug;
		sub["title"] = i.title;
		sub["date"] = i.date.toISOExtString;
	}

	immutable frontPath = buildPath(publicPath, "index.html");	
	write(frontPath, mustache.render(frontTemplate, frontContext));
}

void copyDir(const string from, const string to)
{
	if (to.exists && to.isDir)
		to.rmdirRecurse;

	to.mkdir();

	foreach(DirEntry e; dirEntries(from, SpanMode.breadth)) {
		immutable newPath = absolutePath(e.name[from.length + 1 .. $],
			to);

		if (e.isDir())
			mkdir(newPath);
		else
			copy(e.name, newPath);
	}
}

import std.datetime.stopwatch : benchmark, StopWatch;
void main()
{
	auto b = benchmark!(_main)(100);

	writeln(b[0] / 100);
}
