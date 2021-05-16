<?php

// Purpose: Gets the hardware lcdc type definition
// ==============================

require "lib/common.php";
const LCDC_FLAGS = [
"LCDC_PRIORITY" ,
"LCDC_OBJENABLE",
"LCDC_OBJSIZE"  ,
"LCDC_BGTILEMAP",
"LCDC_TILEDATA" ,
"LCDC_WENABLE"  ,
"LCDC_WTILEMAP" ,
"LCDC_ENABLE"   ,
 ];
 

$act = hexdec($argv[1]);

if (!$act) die ("nothing");

$f = [];
for ($i = 0; $i < 8; ++$i) {
	if ($act & (1 << $i))
		$f[] = LCDC_FLAGS[$i];
}

die ("ld   a, ".implode("|", $f));