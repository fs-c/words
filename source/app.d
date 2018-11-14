import std.file : isDir, mkdir, write, exists, SpanMode, dirEntries, DirEntry,
	copy, rmdirRecurse;
import std.path : buildPath, absolutePath;
import std.stdio : writeln, writefln;
import std.getopt;
import std.datetime : MonoTime, Duration;
import std.algorithm.sorting : sort;

import item : Item, parseItem;
import mustache : MustacheEngine;

alias MustacheEngine!(string) Mustache;

void main(string[] args)
{
	string contentPath = absolutePath("content");
	getopt(args, "content", &contentPath);

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

	foreach(string e; dirEntries(contentPath, SpanMode.shallow)) {
		Item i = items[++items.length - 1] = parseItem(e);

		if (i.draft)
			continue;

		immutable itemFolder = buildPath(publicPath, i.slug);
		immutable itemPath = buildPath(itemFolder, "index.html");
		mkdir(itemFolder);

		itemContext["title"] = i.title;
		itemContext["content"] = i.content;

		if (i.hidden)
			itemContext.useSection("hidden");

		write(itemPath, mustache.render(itemTemplate, itemContext));
	}

	items.sort!("a.date > b.date");

	foreach(ref i; items) {
		if (i.hidden)
			continue;

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
			newPath.mkdir();
		else
			copy(e.name, newPath);
	}
}

/* In order to do a benchmarking run, uncomment the following block and rename
 * the original main() to _main().
 */

// import std.stdio : writefln;
// import std.datetime.stopwatch : benchmark, StopWatch;
// void main()
// {
// 	immutable runs = 1000;
// 	auto b = benchmark!(_main)(runs);

// 	writefln("average of %d runs: %s", runs, b[0] / runs);
// }
