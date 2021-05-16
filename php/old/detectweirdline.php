<?php

// Purpose: Detects badly formatted instructions


// ==============================

require "lib/common.php";

if (!is_dir("src")){
	die("Cannot find src folder");
}

foreach (glob("src/bank*.asm") as $path) {
	$txt = "";
	$bankno = strtoupper(substr($path, -6, 2));
	
	$i = 0;
	foreach (file($path) as $row) {
		++$i;
		if (substr($row, 0, 1) == "\t" && strlen(rtrim($row)) > 5 && substr($row, 5, 1) != " ") {
			print "{$bankno}:{$i} -> {$row}";
		}
	}
}