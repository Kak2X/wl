<?php

// Purpose: Convert "dw L04****" to BGMDataTable_****
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Converting data...".PHP_EOL;

$toReplace = [];
$lines = file("tempconv.txt");
// Build the array with all the "L04****" locations to replace
foreach ($lines as $line) {
	if (strpos($line, "\tdw L04") === 0) {
		$memAddr = substr($line, 4, 7);
		$toReplace[$memAddr] = "BGMDataTable_".substr($memAddr, 3);
	}
}

$f = file_get_contents("tempconv.txt");
$out = strtr($f, $toReplace);
file_put_contents("tempconv.asm", $out);
