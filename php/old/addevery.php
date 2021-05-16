<?php

// Adds a line every N lines
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
    die("can't find tempconv.txt");
}

const SEP = 0x20;
const MARKERS = [
 "ScrollLocks_C26: "
,"ScrollLocks_C33: "
,"ScrollLocks_C15: "
,"ScrollLocks_C20: "
,"ScrollLocks_C16: "
,"ScrollLocks_C10: "
,"ScrollLocks_C07: "
,"ScrollLocks_C01A:"
,"ScrollLocks_C17: "
,"ScrollLocks_C12: "
,"ScrollLocks_C13: "
,"ScrollLocks_C29: "
,"ScrollLocks_C04: "
,"ScrollLocks_C09: "
,"ScrollLocks_C03A:"
,"ScrollLocks_C02: "
,"ScrollLocks_C08: "
,"ScrollLocks_C11: "
,"ScrollLocks_C35: "
,"ScrollLocks_C34: "
,"ScrollLocks_C30: "
,"ScrollLocks_C21: "
,"ScrollLocks_C22: "
,"ScrollLocks_C01B:"
,"ScrollLocks_C19: "
,"ScrollLocks_C05: "
,"ScrollLocks_C36: "
,"ScrollLocks_C24: "
,"ScrollLocks_C25: "
,"ScrollLocks_C32: "
,"ScrollLocks_C27: "
,"ScrollLocks_C28: "
,"ScrollLocks_C18: "
,"ScrollLocks_C14: "
,"ScrollLocks_C38: "
,"ScrollLocks_C39: "
,"ScrollLocks_C03B:"
,"ScrollLocks_C37: "
,"ScrollLocks_C31A:"
,"ScrollLocks_C23: "
,"ScrollLocks_C40: "
,"ScrollLocks_C06: "
,"ScrollLocks_C31B:"
];

$i = SEP - 1;
$mi = 0;

print "Adding lines...".PHP_EOL;

$h = null;
$inputs = "";
$set = null;
foreach (file("tempconv.txt") as $line) {
	if (isset(MARKERS[$mi]))  {
		++$i;
		if ($i == SEP) {
			$inputs .= MARKERS[$mi].PHP_EOL;
			++$mi;
			$i = 0;
		}
	}
	$inputs .= $line;
}

file_put_contents("tempconv.asm", $inputs);