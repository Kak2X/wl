<?php
	
$IN_FILE = "tempconv.txt";
$OUT_FILE = "tempconv.asm";
	
// Purpose: bgm command explainer because no way I'm writing it by hand
require "lib/common.php";
	
if (!file_exists($IN_FILE))
	die("Can't find {$IN_FILE}");

$asmfile = file($IN_FILE);
$h = fopen($OUT_FILE, 'w');

for ($i = 0; $i < count($asmfile); $i++) {
	$line = $asmfile[$i];

	// Detect lines which don't contain commands
	if ($line[0] != "L" && strpos($line, "BGMCmdTable_") !== 0) {
		out($line);
		continue;
	}
	
	// Read the command byte for this
	$sep = strpos($line, "db ");
	if ($sep === false)
		continue;
	$cmd = hexdec(substr($line, $sep + 4, 2));
	
	// No command?
	if ($cmd === false) 
		continue;
	
	// If this line had a real label, add it first
	if ($line[0] != "L") {
		out(substr($line, 0, $sep)."\r\n\t");
	} else {
		out("\t");
	}
	
	// Determine the command like the game would do
	// Can't be perfect since some commands change their meaning on CHANNEL 3
	if ($cmd == 0x00) {
		out("sndend");
	} else if ($cmd == 0xF1) {
		out( "sndregex \$".getdb($i+1).",\$".getdb($i+2).",\$".getdb($i+3)",\$".getdb($i+3).
		" ; sndregex3 L04".getdw($i+1).",\$".getdb($i+3));
		$i += 3;
	} else if ($cmd == 0xF2) {
		out( "sndlentbl \$".getdw($i+1));
		$i += 2;
	} else if ($cmd == 0xF3) {
		out( "sndpitchbase \$".getdb($i+1));
		$i += 1;
	} else if ($cmd == 0xF4) {
		out( "sndsetloop \$".getdb($i+1));
		$i += 1;
	} else if ($cmd == 0xF5) {
		out( "sndloop");
	} else if ($cmd >= 0xF6) {
		out( "sndstop \$".dechex($cmd - 0x9F));
	} else if ($cmd >= 0x9F && $cmd < 0xF1) {
		out( "sndlenid \$".dechex($cmd - 0x9F));
	} else if ($cmd == 0x01) {
		out( "sndmutech");
	} else if ($cmd == 0x03) {
		out( "sndhienv");
	} else if ($cmd == 0x05) {
		out( "sndloenv");
	} else if ($cmd % 2 == 0) {
		out("snddb \$".dechex($cmd));
	} else {
		die($line);
	}
	
	// EOL
	out("\r\n");
}

fclose($h);

function getdb($i) {
	global $asmfile;
	$line = $asmfile[$i];
	$sep = strpos($line, "db ");
	if ($sep === false)
		return;
	return substr($line, $sep + 4, 2);
}
function getdw($i) {
	return getdb($i+1).getdb($i);
}
function out($txt) {
	//print $txt;
	global $h;
	fwrite($h, $txt); 
}