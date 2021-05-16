<?php

// Purpose: Convert inline db to room struct
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
    die("can't find tempconv.txt");
}

print "Converting db to level struct...".PHP_EOL;


const TARGET = 0x18;

$i = TARGET -1;
$h = null;
$inputs = "";
$set = null;
foreach (file("tempconv.txt") as $line) {
    $ln = trim($line);
	
	if ($ln[0] !== "L") {
    //if ($ln[1] !== "0") {
        // New label reached
        $label = substr($ln, 0, strpos($ln, ":"));
        
		if ($set !== null) {
			$inputs .= makeinputs($set);
		}
		
		$set = [];
    
		$inputs .= "{$label}:\r\n";
    }
    
    // Substr the byte value regardless of its position
    $dp = strpos($ln, "db \$");
	if ($dp !== false) {
		$set[] = substr($ln, $dp + 4, 2);
	}
    
}

$inputs .= makeinputs($set);

file_put_contents("tempconv.asm", $inputs);



function makeinputs($set) {
	$out = "";
	for ($i = 0; $i < count($set); $i+=4) {
		if ($set[$i+3] == "FF") {
			$out .= "\tmActGFX_End\r\n";
		} else { 
			$out .= "\tmActGFXDef L{$set[$i+0]}{$set[$i+2]}{$set[$i+1]}, \${$set[$i+3]}\r\n";
		}
	}
	
    return $out;
}