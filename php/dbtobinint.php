<?php

// Purpose: Convert inline db to binary data ("interleaved")
// ==============================

const BLOCK = 6;
const OUTPUT_NAME = "tempconv";
require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Interleaving data...".PHP_EOL;


//strlen("L0D7870: db $") = 13
$out = array_fill(0, BLOCK, "");
$i = 0;

foreach (file("tempconv.txt") as $line) {
	$x = substr($line, 13, 2);
	if ($x !== false && $x !== "") {
		$out[$i] .= chr(hexdec($x));
		$i = ($i+1)%BLOCK;
	}
}
print "Writing data...".PHP_EOL;

$h = fopen(OUTPUT_NAME.".bin", 'wb');
for ($i = 0; $i < BLOCK; $i++) {
	fwrite($h, $out[$i]);
}
fclose($h);
/*
for ($i = 0; $i < BLOCK; $i++) {
	$h = fopen(OUTPUT_NAME.$i.".bin", 'wb');
	fwrite($h, $out[$i]);
	fclose($h);
}
*/
die("OK");
