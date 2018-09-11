import std.file;
import std.path;
import std.stdio : writefln;
import core.time;
import std.exception;
import std.algorithm.sorting;

import item;
import mustache;

alias MustacheEngine!(string) Mustache;

void main()
{
	auto start = MonoTime.currTime;

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
		Item i = items[++items.length - 1] = parseItem(e);

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

	Duration elapsed = MonoTime.currTime - start;

	writefln("built %d items in %s", items.length, elapsed);
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

// import std.stdio : writefln;
// import std.datetime.stopwatch : benchmark, StopWatch;
// void main()
// {
// 	immutable runs = 1000;
// 	auto b = benchmark!(_main)(runs);

// 	writefln("average: %s", b[0] / runs);
// }
