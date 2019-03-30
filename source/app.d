import std.file : isDir, mkdir, write, exists, SpanMode, dirEntries, DirEntry,
	copy, rmdirRecurse;
import std.path : buildPath, absolutePath;
import std.stdio : writeln, writefln;
import std.getopt;
import std.datetime : MonoTime, Duration;
import std.algorithm.sorting : sort;

import item : Item, parseItem;
import mustache : MustacheEngine;

alias Mustache = MustacheEngine!(string);

void main(string[] args)
{
	string publicPath = absolutePath("public");
	string contentPath = absolutePath("content");
	getopt(args,
		"content", &contentPath,
		"public", &publicPath
	);

	if (publicPath.exists)
		publicPath.rmdirRecurse;

	publicPath.mkdir;

	immutable staticPath = absolutePath("static");
	copyDir(staticPath, buildPath(publicPath.absolutePath, "static"));

	immutable templatesPath = absolutePath("templates");
	immutable itemTemplate = buildPath(templatesPath, "item");
	immutable frontTemplate = buildPath(templatesPath, "front");

	Mustache mustache;
	mustache.ext = "html";	

	Item[] items;

	foreach(string e; dirEntries(contentPath, SpanMode.shallow)) {
		auto itemContext = new Mustache.Context;		
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

	auto frontContext = new Mustache.Context;	

	foreach(ref i; items) {
		if (i.hidden || i.draft)
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
