<?php

// Purpose: Split tempconv.bin into multiple files
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}
if (!file_exists("tempconv.bin")) {
	die("can't find tempconv.bin");
}

print "Splitting data...".PHP_EOL;

// Open the entire binary data to split
$source = file_get_contents("tempconv.bin");
$incbins = "";

// Prepare vars
$h = null;
$combo = 0;
$inpos = 0;

// For every line of tempconv.txt (which marks delimiterd)
foreach (file("tempconv.txt") as $line) {
	// Detecting the filename indicator?
	// "data/event/ricebeach_c07.evt": db $7F
	if ($line[0] === '"') {
		if ($h != null) {
			// Copy the portion of tempconv.bin in the range
			$data = substr($source, $inpos, $combo);
			fwrite($h, $data);
			fclose($h);
			$inpos += $combo;
		}
		// Detect where the filename ends
		$pos = strpos($line, '"', 1);
		// Open a handle to that
		$filename = substr($line, 1, $pos - 1);
		$incbins .= " INCBIN \"{$filename}\" ".PHP_EOL;
		print "Opening {$filename}...".PHP_EOL;
		$h = fopen($filename, 'wb');
		if ($h === false)
			die("Could not open for writing \"{$filename}\".");
		$combo = 1;
	} else {
		// keep going
		// L086AAF: db $6B
		++$combo;
	}
}
if ($h != null) {
	$data = substr($source, $inpos, $combo);
	fwrite($h, $data);
	fclose($h);
	$inpos += $combo;
}

file_put_contents("tempconv.asm", $incbins);
die("OK");