<?php

// CHAIN ORDER 2

// Purpose: Fixes an oops in the conversion.
//          JR NZ,$01CA -> JR NZ,<bank number in hex>01CA


// ==============================

require "lib/common.php";

if (!is_dir("src")){
	die("Cannot find src folder");
}

foreach (glob("src/bank*.asm") as $path) {
	$txt = "";
	$bankno = strtoupper(substr($path, -6, 2));
	//die($bankno);
	foreach (file($path) as $row) {
		if (substr($row, 1, 2) == "JR") {
			$pos = strpos($row, "$");
			if ($pos === -1)
				die("this shouldn't happen");
			$row_right = substr($row, $pos + 1); // skip $
			$row_left = substr($row, 0, $pos);
			$txt .= $row_left."L{$bankno}".$row_right;
		} else {
			$txt .= $row;
		}
	}
	file_put_contents($path, $txt);
}