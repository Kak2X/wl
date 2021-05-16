<?php

// CHAIN ORDER 2

// Purpose: Converts the rest of jumps (JP, CALL)


// ==============================

require "lib/common.php";

if (!is_dir("src")){
	die("Cannot find src folder");
}

foreach (glob("src/bank*.asm") as $path) {
	$txt = "";
	$bankno = strtoupper(substr($path, -6, 2));
	if ($bankno == "00")
		continue;
	
	foreach (file($path) as $row) {
		if (substr($row, 1, 2) == "jp" || substr($row, 1, 4) == "call") {
			$pos = strpos($row, "$");
			if ($pos === false) {
				$txt .= $row; // no address found; copy row
			} else {
				$row_right = substr($row, $pos + 1); // skip $
				$row_left = substr($row, 0, $pos);
				$txt .= $row_left."L{$bankno}".$row_right;
			}
		} else {
			$txt .= $row;
		}
	}
	file_put_contents($path, $txt);
}