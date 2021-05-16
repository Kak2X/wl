<?php

// Purpose: Convert inline db to inline dw
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

const DELIM = "L";
const DELIMN = 0;

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');
//strlen("L0D7870: db $") = 13
//strlen("L0D7870: d") = 10
$lowByte = "";
$t = "";
foreach (file("tempconv.txt") as $line) {
	$sep = strpos($line, ":");
	$x = substr($line, $sep + strlen(": db \$"), 2);
	if ($x !== false && $x !== "") {
		if (DELIM && $line[DELIMN] != DELIM) {
			//$sep = strpos($line, ":");
			if ($lowByte) {
				fwrite($h, "\tdb \${$lowByte}\r\n");
			}
			fwrite($h, substr($line, 0, $sep + 1)."\r\n");
			$t       = $line;
			$lowByte = substr($line, $sep + strlen(": db \$"), 2);
		} else if ($lowByte) {
			$extra = rtrim(substr($line, 15));
			// If both bytes are $00, this is a null pointer.
			// Instead of pointing to "L00000", write directly "$0000".
			if ($lowByte == "00" && $x == "00") {
				$tgPtr = "\$0000";
			} else {
				$ADDR_PREFIX = "L".((int)$x[0] > 3 ? substr($line, 1, 2) : "00");
				$tgPtr = $ADDR_PREFIX.$x.$lowByte;
			}
			
			if (DELIM) {
				fwrite($h, "\tdw {$tgPtr}{$extra}\r\n"); // little endian
			} else {
				fwrite($h, substr($t, 0, 10)."w {$tgPtr}{$extra}\r\n"); // little endian
			}
			$lowByte = "";
		} else {
			$t       = $line;
			$lowByte = $x;
			//$b = substr($line, 0, 10)."w $".$x;
		}
	} else {
		fwrite($h, $line);
	}
}
fclose($h);