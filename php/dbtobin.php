<?php

// Purpose: Convert inline db to binary data
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.bin", 'wb');
//strlen("L0D7870: db $") = 13
foreach (file("tempconv.txt") as $line) {
	$x = substr($line, strpos($line, ":") + 6, 2);
	if ($x !== false && $x !== "") {
		//print ."\r\n";
		fwrite($h, chr(hexdec($x)));
	}
}
fclose($h);