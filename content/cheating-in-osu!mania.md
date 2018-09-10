{ "title": "Cheating in osu!mania", "date": "2018-07-15" }

I’ve been dabbling in memory reading on Linux recently, and I’ve also been having fun with a little application called [scanmem](https://github.com/scanmem/scanmem) which can be used to isolate the address of a variable in a process.

And coincidence has it that I’ve also started playing the game [osu!mania](https://osu.ppy.sh/) somewhat actively in the last few weeks. Well, one thing led to another and now we are here.

Essentially, what we are going to be doing can be divided into two stages:

- Parse a beatmap file (the `.osu` files in your `.../osu!/Songs/` path) and get the hitpoints described in it.
- Read the current songs playing time from the game process’ memory and determine which hitpoints are “due”.

By parsing hits from the `.osu` file we avoid having to do too much memory reading or (god forbid) reading the screens’ pixels.

It should be noted that I will be using APIs that are specific to Linux and the X Window System in order to read the little memory we have to, and to simulate keypresses. The parts that require this are easily replaceable with close Windows equivalents, and no changes to the main program logic are required.

### Parsing the beatmap

Information about beatmaps is stored in plaintext in `.osu` files, and the format is [well documented](https://osu.ppy.sh/help/wiki/osu!_File_Formats/Osu_(file_format)). These files contain many sections, of which only the last `[HitObjects]` section is relevant to us.

The Hit Objects section is made up of CSV lines with a syntax like this: 

```yaml
x, y, time, type, hitSound, [endTime], extras
```

Of these values we only need

-  `x ` to determine the column this point falls in, 
- `time` to determine when to press the button and
-  `endTime` to determine when to release the button.

Do note that `endTime` will be zero if this is a simple hit object, ergo if it’s not a Hold Note. In our implementation, if `!endtime`, we will simply set it to `time + TAPTIME` where `TAPTIME` is something like 15.

A `hitpoint` struct containing only the requires values could look like this:

```c
struct hitpoint {
	int column;
	int end_time;
	int start_time;
};
```

These beatmaps are sorted by `time`, but their `endTime`s can be all over the place, so we’ll parse them into objects which we can properly sort and then execute one by one as they are due. For this we’ll build an action struct which will represent either keydown or keyup:

```C
struct action {
	int time;
	char key;
	bool down;
};
```

A Hit Object line like

```yaml
64,192,1000,128,0,3670:0:0:0:0:
```

can then be parsed into a hitpoint,

```C
{ column: 0, start_time: 1000, end_time: 1128 }
```

which can be parsed into two actions.

```json
[ { time: 1000, down: true, key: 'd' },
  { time: 1128, down: false, key: 'd' } ]
```

_For readability I’ve borrowed from the JSON syntax here._

An important calculation to consider in the CSV to `hitpoint` conversion is that of the `column` property. We know that `x` determines the column, and the documentation provides us with the following formula:

`column = X / column width` _where_ `column width = 512 / number of columns`

Since we’re only going to support maps with four columns (aka keys) this can be shortened to `column = 64 / 128 ` which, when discarding decimal places, is zero.

The default key layout in osu!mania is `'d'` for the first column, `'f'` for the second, `'j'` for the third and `'k'` for the fourth and last. Therefore the first colum (with index zero) gets converted to a `'d'` when parsing the `hitpoint` struct into `action`s.

I’m not going to go into map parsing any further than this since in the end it’s really just splitting up and parsing lines, but you can take a look at the code in [beatmap.c](https://github.com/LW2904/maniac/blob/master/src/beatmap.c) where it’s fully implemented.

### Finding the gametime

All time points in .osu files are defined as ‘miliseconds from the beginning of the song’, so it’s crucial that we be able to read the current songs playback time (from now on referred to as ‘gametime’) from the osu! process in order to be able to accurately replay them.

In order to do this we will have to find the address of that particular variable in the game’s memory, which we can very conveniently do using the _scanmem_ tool.

While having osu! opened and with the current song’s playback stopped, start scanmem like so:

```bash
$ scanmem -p <PID of osu! process>
```

Having started scanmem and after beeing greeted with the default License and Warranty information, simply input zero and wait for the search to complete.

![](https://i.imgur.com/V2VrCaB.png)

_The result of searching for zero, note the stopped playback. Don’t mind wine’s messages in the background, they don’t bite._

Now, start the playback and, in scanmem keep inputting `>` (indicating that the value we are searching for has increased since the last search) until you are left with a reasonable amount of matches. Other commands that can be used to narrow down the list include `<` and `=`. Go wild until you reach a number you are comfortable with, don’t forget to check the current list of matches using the `list` command.

![](https://i.imgur.com/osRrpHY.png)

A lot of these can be discarded immediately, and the addresses with potential can be quickly narrowed down to those at the indices 1, 3, 6, 30, 37 and 41. After a second look, 1-6 can be discarded since `I16` has a maximum size of `2^16 = 65536` which is much too small to hold an average song’s playtime. Of the rest we are going to pick 30 (`0x36e59ec`) since it has the largest range.

I’m not going to implement pattern scanning here since it is not required on Linux and I feel like it would go too far beyond the scope of this post, reference implementations can be found all over the web though. To get the surrounding memory for a signature simply use the `dump` command.

### Reading the gametime

Now, having found the address we want to read from, we can simply use the [`process_vm_readv`](http://man7.org/linux/man-pages/man2/process_vm_readv.2.html) function introduced in recent Linux Kernel versions (>= 3.2). I want to encourage you to read the manpage on it, although its interface should be obvious from the example code below.

```c
#define TIME_ADDRESS 0x36e59ec

/* ... */

int32_t get_gametime(pid_t pid)
{
	int32_t time;
	size_t size = sizeof(int32_t);

	struct iovec local[1];
	struct iovec remote[1];

	local[0].iov_len = size;
	local[0].iov_base = &time;

	remote[0].iov_len = size;
	remote[0].iov_base = TIME_ADDRESS;

	process_vm_readv(pid, local, 1, remote, 1, 0);

	return time;
}
```

### Implementation

Before jumping into the meat of the matter, let’s think about user input for a second. We will need to a path to the beatmap file to parse, and the process ID of the osu! process. This can be implemented in a clean way with the [`getopt`](https://www.gnu.org/software/libc/manual/html_node/Using-Getopt.html#Using-Getopt) function, a GNU extension to the C standard.

```c
/* ... */

int main(int argc, char *argv[])
{
	char *map = "map.osu";
    int game_proc_id = 0, c;

	while ((c = getopt(argc, argv, "m:p:")) != -1) {
		switch (c) {
		case 'm': map = optarg;
			break;
		case 'p': game_proc_id = strtol(optarg, NULL, 10);
			break;
		}
	}
    
    if (!game_proc_id || !map) {
		printf("usage: %s -p <pid of osu! process> ", argv[0]);
		printf("-m <path to beatmap.osu>\n");
		return EXIT_FAILURE;
	}
    
    /* ... */
}
```

Okay so now we have the process ID we need for reading the gametime, and a path to the beatmap from which to parse the actions from.

I mentioned that I wouldn’t go over the beatmap parsing in more detail here, but in order to properly understand the following code you will need to know how their interfaces look:

```c
/**
 * Parses a beatmap file (*.osu) into an array of hitpoint structs pointed to by 
 * **points.
 * Returns the number of points parsed and stored.
 */
int parse_beatmap(char *file, hitpoint **points);

/**
 * Parses a total of `count` hitpoints from **points into **actions.
 * Returns the number of actions parsed and stored, which should be `count * 2`.
 */
int parse_hitpoints(int count, hitpoint **points, action **actions);

/**
 * Sort the array of actions given through **actions by time.
 * Returns nonzero on failure.
 */
int sort_actions(int count, action **actions);
```

None of these functions are particularly exciting and using them will net us the following, rather repetitive, code:

```c
/* ... */

int main(int argc, char **argv)
{
	/* ... */

	hitpoint *points;
	int num_points = 0;
	if ((num_points = parse_beatmap(map, &points)) == 0 || !points) {
		printf("failed to parse beatmap (%s)\n", map);
		return EXIT_FAILURE;
	}

	printf("parsed %d hitpoints\n", num_points);

	action *actions;
	int num_actions = 0;
	if ((num_actions = parse_hitpoints(num_points, &points, &actions)) == 0
		|| !actions) {
		printf("failed to parse hitpoints\n");
		return EXIT_FAILURE;
	}

	printf("parsed %d actions\n", num_actions);

	free(points);

	if (sort_actions(num_actions, &actions) != 0) {
		printf("failed sorting actions\n");
		return EXIT_FAILURE;
	}
    
    return 0;
}
```

So, now that we’ve parsed the beatmap into a sorted array of actions, all that’s left is the main playback loop. 

```c
int main()
{
    /* ... */
    
    int32_t time;
	int cur_i = 0;
	action *cur_a;

    // While there's still actions left.
	while (cur_i < num_actions) {
		time = get_maptime();

        // For all actions that are (over)due.
		while ((cur_a = actions + cur_i)->time <= time) {
			cur_i++;

			send_keypress(cur_a->key, cur_a->down);		
		}

		nanosleep((struct timespec[]){{0, 1000000L}}, NULL);
	}

	return 0;
}
```
The full code of this project can be found on [github.com/lw2904/maniac](https://github.com/lw2904/maniac), note that the code is not a one on one match to the examples in this post since parts were refactored in order to reach Windows portability.



>Edit history
>
>__7/17/2018__: Rewrote and restructured parts for better readability, fixed minor error in code sample, added bottom note. Changes in commit [`962fb1f`](https://github.com/LW2904/blog/commit/962fb1f584a3c3d1c85ca063f92dc75c1725961e).