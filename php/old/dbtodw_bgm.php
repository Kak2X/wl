<?php

// Purpose: Convert inline db to inline dw -- BGM Chunk variant
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

const DELIM = "L";
const DELIMN = 0;
const HARDCODE_LOOP_FIRST = true;

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');

$lowByte = "";
$t = "";
//-------------------------
$redir = 0;
//-------------------------
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
			//-------------------------
			
			// Detect special commands
			if ($lowByte == "00" && $x == "00") {
				$tgPtr = "BGMTBLCMD_END";
			} else if ($lowByte == "F0" && $x == "00") {
				$tgPtr = "BGMTBLCMD_REDIR";
				$redir = 1; // Handle line in redirect command
			} else {
			//-------------------------
				$ADDR_PREFIX = "L".((int)$x[0] > 3 ? substr($line, 1, 2) : "00");
				$tgPtr = $ADDR_PREFIX.$x.$lowByte;
			}
			
			if (DELIM) {
				//-------------------------
				if ($redir == 1) {
					// first line -- don't add newline
					fwrite($h, "\tdw {$tgPtr}{$extra}");
					$redir++;
				} else if ($redir == 2) {
					// second line -- add inline ,(ptr)
					if (HARDCODE_LOOP_FIRST)
						$tgPtr = ".loop";
					fwrite($h, ", {$tgPtr}{$extra}\r\n");
					$redir = 0;
				} else
				//-------------------------
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
		//-------------------------
		if (HARDCODE_LOOP_FIRST && strpos($line, "BGMChunk_") === 0){
			fwrite($h, ".loop:\r\n");
		}
		//-------------------------
	}
}
fclose($h);