<?php

//set_error_handler('error_reporter');
const LOCK_WRITE = false; // Preview file names; don't write
require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Parsing bank asm...".PHP_EOL;

$course = "";
$repl = [];
$ignore = false;
$nowrite = false;
$src = fopen("tempconv.txt", 'r');
$out = fopen("tempconv.asm", 'w');

$groupname = "";
$codeptr = $gfxptr = "";
$last = $line = "";
while (true) {
	$last = $line;
	$line = fgets($src);
	$nowrite = false;
	if ($line === false) {
		print_r($repl);
		if (!LOCK_WRITE) {
			fwrite($out, strtr($last, $repl));
		}
		fclose($src);
		fclose($out);
		break;
	}
	
	// Group Switch
	if (startswith($line, "ActGroup_")) {
		$ep = strpos($line, ":");
		$len = strlen("ActGroup_");
		$groupname = substr($line, $len, $ep - $len);
		$codeptr = $gfxptr = "";
		$ignore = $groupname[0] !== "C";
	}
	if (!$ignore) {
	// Low byte code ptr
	if (startswith($line, "\tld   [sActGroupCodePtrTable], a")) {
		$ep = strpos($last, "\$");
		$codeptr = substr($last, $ep + 1, 2);
		$nowrite = true;
		$last = $line = "";
		//$last = "\tld   a, LOW(ActGroupCodeDef_{$groupname})\r\n";
	}
	// High byte code ptr
	if (startswith($line, "\tld   [sActGroupCodePtrTable+1], a")) {
		$ep = strpos($last, "\$");
		$codeptr = substr($last, $ep + 1, 2).$codeptr;
		
		// Add to list
		if (!isset($repl["L07{$codeptr}"])) {
			$repl["L07{$codeptr}"] = "ActGroupCodeDef_{$groupname}";
		} else {
			$groupname = substr($repl["L07{$codeptr}"], strlen("ActGroupCodeDef_"));
		}
		
		$last = "\tld   a, LOW(ActGroupCodeDef_{$groupname})\r\n".
		"\tld   [sActGroupCodePtrTable], a\r\n".
		"\tld   a, HIGH(ActGroupCodeDef_{$groupname})\r\n";
		
	}
	// GFX ptr
	if (startswith($line, "\tcall ActS_InitGroup")) {
		if (!startswith($last, "\tld   bc, \$"))
			die("fuck");
		
		$ep = strpos($last, "\$");
		$gfxptr = substr($last, $ep + 1, 4);
		
		if (!isset($repl["L07{$gfxptr}"])) {
			$repl["L07{$gfxptr}"] = "ActGroupGFXDef_{$groupname}";
		} else {
			$groupname =  substr($repl["L07{$gfxptr}"], strlen("ActGroupGFXDef_"));
		}
		
		$last = "\tld   bc, ActGroupGFXDef_{$groupname}\r\n";
		$line .= ";\tmActGroup {$groupname}\r\n";
	}
	}
	if (!$nowrite && !LOCK_WRITE) {
		fwrite($out, strtr($last, $repl));
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