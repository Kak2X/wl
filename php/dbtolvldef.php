<?php

// Purpose: Convert inline db to level struct
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
    die("can't find tempconv.txt");
}

print "Converting db to level struct...".PHP_EOL;

$h = null;
$inputs = "";
$set = null;
foreach (file("tempconv.txt") as $line) {
    $ln = trim($line);
    
    if ($ln[1] !== "0") {
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
	dp L{$set[0]}{$set[2]}{$set[1]}	; Main GFX
	dw GFX_LevelShared_L11{$set[4]}{$set[3]}	; Block GFX
	dw GFX_StatusBar_L11{$set[6]}{$set[5]}	; Status Bar GFX
	dw GFX_LevelAnim_L11{$set[8]}{$set[7]}	; Animated tiles GFX
	db \${$set[9]},\${$set[10]}	; Level Layout ID	
	dw L0B{$set[12]}{$set[11]}	; 16x16 Blocks 
	db \${$set[13]},\${$set[14]}	; Player X
	db \${$set[15]},\${$set[16]}	; Player Y
	db \${$set[17]}		; OBJLst Frame
	db \${$set[18]}		; OBJLst Flags
	db \${$set[19]},\${$set[20]}	; Scroll Y
	db \${$set[21]},\${$set[22]}	; Scroll X
	db \${$set[23]}		; Screen Lock Flags
	db \${$set[24]}		; Screen Scroll Mode
	db \${$set[25]}		; Spawn in swim action
	db \${$set[26]}		; Tile animation speed
	db \${$set[27]}		; BG Palette
	dw L07{$set[29]}{$set[28]}	; Actor Setup code

";
}