<?php

// CHAIN ORDER 1

// Purpose: Converting the JR instructions to use the label directly
//          JR NZ,$16; $01CA -> JR NZ,$01CA


// ==============================

require "lib/common.php";

if (!is_dir("src")){
	die("Cannot find src folder");
}

foreach (glob("src/bank*.asm") as $path) {
	$txt = "";
	foreach (file($path) as $row) {
		if (substr($row, 1, 2) == "JR") {
			$pos = strpos($row, ";");
			if ($pos === -1)
				die("this shouldn't happen");
			$row_right = substr($row, $pos + 2); // skip ; and ' '
			$row_left = substr($row, 0, $pos - 3); // skip $vv
			$txt .= $row_left.$row_right;
		} else {
			$txt .= $row;
		}
	}
	file_put_contents($path, $txt);
}