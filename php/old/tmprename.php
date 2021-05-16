<?php

//set_error_handler('error_reporter');
const LOCK_WRITE = false; // Preview file names; don't write
require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Converting data...".PHP_EOL;

$course = "";
$repl = [];
$replmode = false;
$src = fopen("tempconv.txt", 'r');
$out = fopen("tempconv.asm", 'w');
while (true) {
	$line = fgets($src);
	if ($line === false) {
		fclose($src);
		fclose($out);
		break;
	}
	//$ln = trim($line);
	
	if (strlen($line) > 0 && $line[0] === "L") {
		$replmode = true;
	}
	
	do {
		
		if (!$replmode) {
			// Course switch
			if (strpos($line, "DoorHeaderPtrs_") === 0) {
				$ep = strpos($line, ":");
				$len = strlen("DoorHeaderPtrs_");
				$course = substr($line, $len, $ep - $len);
			}
			
			// No unused or default entries
			if (strpos($line, ";X") !== false)
				break;
			if (strpos($line, "Room_") !== false)
				break;
			
			// ID value
			$idp = strpos($line, "; \$");
			if ($idp === false)
				break;
			$id = substr($line, strpos($line, "; \$") + 3, 2);
			
			// Name value
			$name = trim(substr($line, 4, strpos($line, " ", 5)));
			
			// Add to list
			$repl[$name] = "Door_{$course}_{$id}";
		}
		
	} while (false);
	
	if (!LOCK_WRITE) {
		fwrite($out, strtr($line, $repl));
	}
}

function startswith($str, $check) {
	return strpos($str, $check) === 0;
}
/*
function error_reporter($type, $msg, $file, $line) {
	global $ln;
	die("Fatal:\r\n{$ln}");
}
*/