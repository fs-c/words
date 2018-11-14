import std.file : readText;
import std.path : baseName, stripExtension;
import std.json;
import std.string : indexOf;
import std.datetime.date : Date;

import dmarkdown : filterMarkdown, MarkdownFlags;

struct Item {
	Date date;
	bool draft;
	bool hidden;
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

	// TODO: I have no clue why this fails to compile on Linux, the
	//	 following is a stupid and temporary workaround.
	// i.draft = ("draft" in j) ? j["draft"].boolean : false;
	// i.hidden = ("hidden" in j) ? j["hidden"].boolean : false;

	i.draft = ("draft" in j) ? true : false;
	i.hidden = ("hidden" in j) ? true : false;

	return i;
}
