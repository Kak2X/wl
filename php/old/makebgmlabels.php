<?php

// Purpose: Places the correct labels for the BGMChunks
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Generating asm file...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');

$bgm_name = "";
$chan_num = 0;

$all_lines = file("tempconv.txt");
$out_lines = file("tempconv.txt");

for ($i = 0; $i < count($all_lines); $i++) {
	$line = $all_lines[$i];
	
	// Detect if this line contains ": dw L04"
	// If it does, it means we have an incomplete
	// (it must be L04 since that's the sound driver bank)
	// (this also ignores lines with "dw $0000")
	$sep = strpos($line, ":");
	$line_ok = strpos($line, ": dw L04") !== false;
	//$x = substr($line, $sep + strlen(": dw L04"), 2);
	
	if ($line_ok) {
		// If that's true, read out the complete address
		$target_address = substr($line, $sep + 5, 7);
		print "T:{$target_address} C:{$chan_num}\r\n";
		// Loop through all of the *output* file and add the extra lines
		
		$repl_done = false;
		for ($j = 0; $j < count($out_lines); $j++) {
			
			// Search for the BGMHeader we want, and replace the definition for its sound channel
			// ...only the first one though, since the same chunk can be used for multiple channels
			//    in the same song.
			if (!$repl_done && strpos($out_lines[$j], "BGMHeader_{$bgm_name}:") === 0) {
				$j += 2+$chan_num;
				$out_lines[$j] = "\tdw BGMChunk_{$bgm_name}_Ch{$chan_num}\r\n";
				$repl_done = true;
			}
			
			// If the line starts with "$target_address", add our own label before it (read: current index)
			if (strpos($out_lines[$j], $target_address.": db") !== false) {
				// Found it.
				$out_lines[$j] = "BGMChunk_{$bgm_name}_Ch{$chan_num}:\r\n".$out_lines[$j];
				//array_insert($out_lines, $j, "BGMChunk_{$bgm_name}_Ch{$chan_num}:\r\n");
			}
		}		
	} else if ($chan_num == -1) {
		// If the line starts with "BGMHeader", we know the format it will take.
		if (strpos($line, "BGMHeader") === 0) {
			// Skip "BGMHeader_" and read the song name
			$bgm_name = substr($line, 10, $sep - 10);
			
			// Skip out to right before the first channel def.
			$i += 2; 
			$chan_num = 0;
		}
	} 
	if ($chan_num != -1) {
		// Increase channel number up to 4 if set
		$chan_num = $chan_num == 4 ? -1 : $chan_num + 1;
	}
}

// Write out $out_lines
foreach ($out_lines as $x) {
	fwrite($h, $x);
}



fclose($h);