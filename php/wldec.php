<?php
	
	$IN_FILE = "test.rlc";
	$OUT_FILE = "test.bin";
	
	require "lib/common.php";
	
	$data = file_get_contents($IN_FILE);
	if ($data === false)
		die("Failed to read '{$IN_FILE}'. ");
	
	print "Attempting to decompress '{$IN_FILE}'.".PHP_EOL;
	
	$decomp = gfx_decomp($data);
	
	$o = fopen("test.bin", 'wb');
	fwrite($o, $decomp);
	fclose($o);
	
	die("OK");