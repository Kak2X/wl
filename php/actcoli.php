<?php

// Purpose: Gets the actor collision type definition
// ==============================

require "lib/common.php";
const COLI_SPEC = ["ERROR", "ACTCOLI_NORM", "ACTCOLI_BUMP", "ACTCOLI_DAMAGE"];
const COLI_TYPES_10 = [
	"ACTCOLI_TOPSOLID",
	"ACTCOLI_UNUSED_TYPE11 ",
	"ACTCOLI_TOPSOLIDHIT   ",
	"ACTCOLI_BIGBLOCK      ",
	"ACTCOLI_LOCK          ",
];
const COLI_TYPES_20 = [
	"ACTCOLI_KEY           ",
	"ACTCOLI_10HEART       ",
	"ACTCOLI_STAR          ",
	"ACTCOLI_COIN          ",
	"ACTCOLI_10COIN        ",
	"ACTCOLI_BIGCOIN       ",
	"ACTCOLI_BIGHEART      ",
];
const COLI_TYPES_30 = [	
	"ACTCOLI_POW_GARLIC 	",
	"ACTCOLI_POW_BULL 		",
	"ACTCOLI_POW_JET		",
	"ACTCOLI_POW_DRAGON		",
];

$act = hexdec($argv[1]);

if (!$act) die ("ACTCOLI_NONE");
if ($act < 0x10) die ("THIS IS A TREASURE");
if ($act < 0x20) die (COLI_TYPES_10[$act-0x10]);
if ($act < 0x30) die (COLI_TYPES_20[$act-0x20]);
if ($act < 0x40) die (COLI_TYPES_30[$act-0x30]);

$r = COLI_SPEC[$act & 0b11];
$l = COLI_SPEC[($act & 0b1100) >> 2];
$u = COLI_SPEC[($act & 0b110000) >> 4];
$d = COLI_SPEC[($act & 0b11000000) >> 6];

die ("mActColiMask $r, $l, $u, $d\nld   a, COLI");