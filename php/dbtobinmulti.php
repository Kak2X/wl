<?php

// Purpose: Convert inline db to binary data; with automatic naming
// ==============================
set_error_handler('error_reporter');
const REMOVE_FILE = "OBJLst_Ending_";	// Label part to remove when generating file name
const INCBIN_PATH = "data/objlst/ending/"; // folder of incbin files
const LOCK_WRITE = false; // Preview file names; don't write
const OPERATOR = "INCBIN";
const SKIP_FIRST = 0;
const SEPARATE_FILE = false; //"scroll_locks.bin"; // If set, the generated file name will be the path, with this fixed file name
require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}
if (!is_dir("temp")){
	print "Creating 'temp' directory".PHP_EOL;
	mkdir("temp");
}

print "Converting data...".PHP_EOL;

$h = null;
$inputs = "";

$src = fopen("tempconv.txt", 'r');
while (true) {
	$line = fgets($src);
	if ($line === false) {
		fclose($src);
		break;
	}
		
//foreach (file("tempconv.txt") as $line) {
	$ln = trim($line);
	
	if ($ln[0] !== "L") {
		$i = 0;
		// New label reached
		// Get new filename, close existing file and open new one
		$label = substr($ln, 0, strpos($ln, ":"));
		
		$basename = strtolower(str_replace(REMOVE_FILE, "", $label));
		if (SEPARATE_FILE) {
			if (!is_dir("temp/$basename")){
				print "Creating 'temp/$basename' directory".PHP_EOL;
				mkdir("temp/$basename");
			}
			$filename = $basename."/".SEPARATE_FILE;
		} else {
			$filename = $basename.".bin";
		}
		
		
		print "Opening {$filename}".PHP_EOL;
		if (!LOCK_WRITE) {
			if ($h !== null)
				fclose($h);
			$h = fopen("temp/".$filename, 'wb');
		}
		$inputs .= "{$label}: ".OPERATOR." \"".INCBIN_PATH."{$filename}\"".PHP_EOL;
	}
	
	if (SKIP_FIRST && $i < SKIP_FIRST) {
		++$i;
		continue;
	}
	
	// Substr the byte value regardless of its position
	$dp = strpos($ln, "db \$");
	if ($dp !== false) {
		$byteVal = chr(hexdec(substr($ln, $dp + 4, 2)));
		if (!LOCK_WRITE) {
			fwrite($h, $byteVal);
		}
	}
}

if (!LOCK_WRITE) {
	if ($h !== null)
		fclose($h);
	
	file_put_contents("tempconv.asm", $inputs);
}

function startswith($str, $check) {
	return strpos($str, $check) === 0;
}

function error_reporter($type, $msg, $file, $line) {
	global $ln;
	die("Fatal:\r\n{$ln}");
}