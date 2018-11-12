import std.file : readText;
import std.stdio;
import std.algorithm.searching;

import item;

/* This code is never actually imported or used. It's more of a proof of
 * concept, and a full implementation would likely go beyond this project's
 * scope.
 */

string renderItemTemplate(const string templatePath, Item item)
{
	string[string] context;
	string templateFile = readText(templatePath);

	context["title"] = item.title;
	context["content"] = item.content;

	string buffer;

	string key;
	string name;
	int offset = 0;

	immutable opening = "{{";

	auto res = findSplit(templateFile, opening);

	while (res) {
		buffer ~= res[0][key.length + offset .. $];

		if (offset == 0)
			offset = opening.length;

		int i = 0;
		while (res[2][i] != '}')
			i++;

		key = res[2][0 .. i];

		buffer ~= context[key];

		templateFile = templateFile[
			res[0].length + opening.length .. $
		];

		res = findSplit(templateFile, opening);
	}

	templateFile ~= res[0][key.length .. $];

	return buffer;
}
