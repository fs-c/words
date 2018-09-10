#! /bin/bash

cd ..

DIRECTORY_TO_OBSERVE="./"

function block_for_change {
	inotifywait -r \
		-e modify,move,create,delete \
		$DIRECTORY_TO_OBSERVE 2> /dev/null
}

BUILD_SCRIPT="node words.js"

function build {
	eval $BUILD_SCRIPT
}

build
while block_for_change; do
	build
done