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
	
	++$i;
	if (TARGET == $i) {
		$i = 0;
    //if ($ln[1] !== "0") {
        // New label reached
        $label = substr($ln, 0, strpos($ln, ":"));
        
		if ($set !== null) {
			$inputs .= makeinputs($set);
		}
		
		$set = [];
    
		$inputs .= "{$label}:";
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
    return "
	dc \$0{$set[0][0]}{$set[1]},\$0{$set[0][1]}{$set[2]}	; Player pos (Y / X)
	db \${$set[3]}			; Scroll lock
	dc \$0{$set[4][0]}{$set[5]},\$0{$set[4][1]}{$set[6]}	; Scroll pos (Y / X)
	db \${$set[7]}			; Scroll mode
	db \${$set[8]}			; BG Priority
	db \${$set[9]}			; Tile animation speed
	db \${$set[10]}			; Palette
	dp L{$set[11]}{$set[13]}{$set[12]}		; Main GFX
	dw GFX_LevelShared_L11{$set[15]}{$set[14]}		; Shared Block GFX
	dw GFX_StatusBar_L11{$set[17]}{$set[16]}		; Status Bar GFX
	dw GFX_LevelAnim_L11{$set[19]}{$set[18]}		; Animated tiles GFX
	dw L0B{$set[21]}{$set[20]}		; 16x16 Blocks
	dw L07{$set[23]}{$set[22]}		; Actor Setup code
";
}