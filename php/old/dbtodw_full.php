<?php

// Purpose: Converts rst $28 jump tables from "db declarations" to "dw labels" for all bank*.asm files
// ==============================
die("YOU CAN NOT USE THIS TOOL");
require "lib/common.php";

if (!is_dir("temp")) {
	mkdir("temp");
}

const DELIM = "L";
const DELIMN = 0;



foreach (glob("src/bank*.asm") as $file){
	
	print "Reading ".basename($file)."...".PHP_EOL;
	$h = fopen("temp/".basename($file), 'w');
	
	$inJumpTable = false;
	$lowByte = "";
	$t = "";
	foreach (file($file) as $line) {
		if (!$inJumpTable) {
			if (trim($line) === "rst  $28") {
				$inJumpTable = true;
			}
			fwrite($h, $line);
			continue;
		}
			
		// Detect when to stop parsing db's
		$sep = strpos($line, ":");
		
		//L0F5D91: db $97
		// Verify we're parsing exactly something like that
		if ($sep !== 7 || strlen($line) < 15 || substr($line, $sep, 6) !== ": db \$") {
			// Otherwise fall back
			$inJumpTable = false;
			if ($lowByte) {
				fwrite($h, $t);
			}
			fwrite($h, $line);
			$lowByte = "";
			continue;
		}
		$x = substr($line, $sep + 6, 2);
/*
		if (DELIM && $line[DELIMN] != DELIM) {
			//$sep = strpos($line, ":");
			if ($lowByte) {
				fwrite($h, "\tdb \${$lowByte}\r\n");
			}
			fwrite($h, substr($line, 0, $sep + 1)."\r\n");
			$t       = $line;
			$lowByte = substr($line, $sep + strlen(": db \$"), 2);
		} else */
		if ($lowByte) {
			
			$numvar = hexdec($x);
			if ($numvar > 0x7F) { // Invalid jump target?
				fwrite($h, $t);
				fwrite($h, $line);
				$inJumpTable = false;
				$lowByte = "";
				continue;
			}
			
			$extra = rtrim(substr($line, 15));
			$ADDR_PREFIX = "L".((int)$x[0] > 3 ? substr($line, 1, 2) : "00");
			if (DELIM) {
				fwrite($h, "\tdw {$ADDR_PREFIX}{$x}{$lowByte}{$extra}\r\n"); // little endian
			} else {
				fwrite($h, substr($t, 0, 10)."w {$ADDR_PREFIX}{$x}{$lowByte}{$extra}\r\n"); // little endian
			}
			$lowByte = "";
		} else {
			$t       = $line;
			$lowByte = $x;
			//$b = substr($line, 0, 10)."w $".$x;
		}
	}
	fclose($h);
}	

