import std.file;
import std.path;
import std.json;
import std.string;
import std.datetime.date;

import dmarkdown;

struct Item {
	Date date;
	string path;
	string slug;
	string title;
	string content;
}

Item parseItem(const string itemPath)
{
	immutable content = itemPath.readText;
	JSONValue j = content[0 .. indexOf(content, '\n')].parseJSON;

	Item i;
	i.path = itemPath;
	i.title = j["title"].str;
	i.slug = itemPath.stripExtension.baseName;
	i.date = Date.fromISOExtString(j["date"].str);
	i.content = filterMarkdown(content[indexOf(content, '\n') .. $],
		MarkdownFlags.backtickCodeBlocks);

	return i;
}