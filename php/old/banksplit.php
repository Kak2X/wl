<?php

// CHAIN ORDER 0
// WLA-DX main.asm format

// Purpose: Splitting the single "rom.asm" file in different files. Each bank has its own file. 
//          Also generates a RBGDS-compliant main.asm (but does not convert the other files)

// The single file with the entire disassembly
const FILE_PATH = "rom.asm";
// The instruction which triggers the split
const BANK_CMD = ".bank ";

// ==============================

require "lib/common.php";

if (!file_exists(FILE_PATH)) {
	die("Cannot find file ".FILE_PATH.". Remember that the script needs to be run from the directory it's in.");
}
if (!is_dir("src")){
	print "Creating 'src' directory\n";
	mkdir("src");
}

// Perform the splitting
$cmdlen = strlen(BANK_CMD);
$bank = -1;
$b    = "";
$includes = "INCLUDE \"constants.asm\"".PHP_EOL;
foreach (file(FILE_PATH) as $row) {
	if (substr($row, 0, $cmdlen) == BANK_CMD) {
		writeCommand($b, $bank);
		++$bank;
		$b = ""; //$row;
	} else {
		$b .= $row;
	}
}
writeCommand($b, $bank);

// Add include lines to main.asm
print "Writing main.asm\n";
file_put_contents("src/main.asm", $includes);

die("Splitting done.\n");

function writeCommand($txt, $bank) {
	global $includes;
	if ($bank < 0) {
		// no longer valid
		//print "Writing main.asm\n";
		//file_put_contents("src/main.asm", $txt);
	} else {
		$file = "bank".str_pad(strtoupper(dechex($bank)), 2, "0", STR_PAD_LEFT).".asm";
		print "Writing {$file}\n";
		file_put_contents("src/{$file}", $txt);
		$includes .= PHP_EOL."SECTION \"bank{$bank}\", ROMX".PHP_EOL."INCLUDE \"{$file}\"".PHP_EOL;
	}
}