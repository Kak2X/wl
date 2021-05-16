<?php

// Purpose: Split asm files
// ==============================
set_error_handler('error_reporter');
const REMOVE_FILE = "ActGroup_";	// Label part to remove when generating file name
const INCBIN_PATH = "data/lvl/"; // folder of incbin files
const LOCK_WRITE = false; // Preview file names; don't write
const SKIP_FIRST = 0;
const SEPARATE_FILE = "actor_group_init_code.asm";
const ALT_HACK = false; // Filename hack for checkpoints (level header)
const DOOR_HACK = true; // Filename hack for door headers
const FOPEN_MODE = 'a';
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

if (DOOR_HACK) {
	$doorrefs = [];
	$basename_replacements = [
		"treasurec" => "c11",
		"treasurei" => "c26",
		"treasuref" => "c18",
		"treasureo" => "c39",
		"treasurea" => "c03b",
		"treasuren" => "c37",
		"treasureh" => "c24",
		"treasurem" => "c34",
		"treasurel" => "c31b",
		"treasurek" => "c30",
		"treasureb" => "c09",
		"treasured" => "c16",
		"treasureg" => "c20",
		"treasurej" => "c29",
		"treasuree" => "c17",
	];
}

$src = fopen("tempconv.txt", 'r');
while (true) {
	$line = fgets($src);
	if ($line === false) {
		if (!LOCK_WRITE) {
			if ($h !== null)
				fclose($h);
		}
		fclose($src);
		break;
	}
		
	$ln = trim($line);
	
	if (!$ln) continue;
	
	if ($ln[0] === REMOVE_FILE[0]) {
		$i = 0;
		// New label reached
		// Get new filename, close existing file and open new one
		$label = substr($ln, 0, strpos($ln, ":"));
		
		$basename = strtolower(str_replace(REMOVE_FILE, "", $label));
		
		if (ALT_HACK && strpos($basename, "alt")) {
			$basename = str_replace("alt", "", $basename);
			$sfile = "header_checkpoint.asm";
		} else {
			$sfile = SEPARATE_FILE;
		}
		
		if (DOOR_HACK) {
			$fpos = strpos($basename, "_");
			if (isset($basename_replacements[$basename])) {
				$lvlname = $basename_replacements[$basename];
			} else {
				$lvlname = substr($basename, 0, $fpos);
			}
			$basename = $lvlname;
		}
		
		
		if (!is_dir("temp/$basename")){
			print "Creating 'temp/$basename' directory".PHP_EOL;
			mkdir("temp/$basename");
		}
		
		if (DOOR_HACK) {
			$filename = $basename."/".$sfile;
		} else {
			$filename = $basename."/".$sfile;
		}
		
		
		
		print "Opening {$filename}".PHP_EOL;
		if (!LOCK_WRITE) {
			if ($h !== null)
				fclose($h);
			$h = fopen("temp/".$filename, FOPEN_MODE);
		}
		if (!DOOR_HACK || !isset($doorrefs[$lvlname]))
		$inputs .= "{$label}: INCLUDE \"".INCBIN_PATH."{$filename}\"".PHP_EOL;
		if (DOOR_HACK) {
			$doorrefs[$lvlname] = true;
		}
		
	}
	
	if (SKIP_FIRST && $i < SKIP_FIRST) {
		++$i;
		continue;
	}
	
	// Substr the byte value regardless of its position
	if (!LOCK_WRITE) {
		fwrite($h, $line);
	}
}

if (!LOCK_WRITE) {
	file_put_contents("tempconv.asm", $inputs);
}

function startswith($str, $check) {
	return strpos($str, $check) === 0;
}

function error_reporter($type, $msg, $file, $line) {
	global $ln;
	die("Fatal:\r\n{$ln}\r\n{$type}\r\n{$msg}\r\n{$file}\r\n{$line}");
}