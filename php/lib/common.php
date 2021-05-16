<?php

chdir("..");

function bg_decomp($data) {
	$out = "";
	$i   = 0;
	$max = strlen($data);
	while ($i < $max) {
		// Read byte
		$b = ord($data[$i]);
		++$i;
		// Check command
		if ($b == 0x00)
			return $out;
		if ($b & 0x80) { // with MSB: direct copy
			for ($j = 0, $toCopy = $b & 0x7F; $j < $toCopy && $i < $max; $j++, $i++) {
				$out .= $data[$i];
			}
		} else { // no MSB: repeat copy
			$source = $data[$i];
			++$i;
			for ($j = 0, $toCopy = $b; $j < $toCopy; $j++) {
				$out .= $source;
			}
		}
	}
	return $out;
}

const GFX_BUFFER_SIZE = 0x1800;

function gfx_decomp($data) {
	// "Allocate" buffer for an entire GB GFX area
	$out = str_repeat("", GFX_BUFFER_SIZE);
	
	$i = $p = 0;
	$max = strlen($data);
	while ($i < $max) {
		// Read byte
		$b = ord($data[$i]);
		++$i;
		// Check command
		if ($b == 0x00)	 // nul byte: terminator
			return $out;
			
		// To yield an higher compression rate, the compressed data is interleaved.
		// All even bytes come first, then all odd bytes.
		// Therefore, when decompressing, we must *always* increase the writing pointer ($p) by 2.
		//
		// The logic to end the decompression is when either:
		// - Hitting a null terminator (as seen above)
		// - Reaching the end of the 0x1800 buffer.
		
		if ($b & 0x80) { // with MSB: direct copy
			// Copy the next (B&0x7F) bytes directly, as-is.
			for ($j = 0, $toCopy = $b & 0x7F; $j < $toCopy && $i < $max; $j++, $i++, $p+=2) {
				// If we're trying to go past the buffer, we've finished writing a pass.
				// Either start the second pass, or we're done.
				if ($p >= GFX_BUFFER_SIZE) {
					if ($p == GFX_BUFFER_SIZE+1) return $out; // phase 2 (odd bytes) done?
					$p = 1;
				}
				$out[$p] = $data[$i];
			}
		} else { // no MSB: repeat copy
			// Copy the next byte B times.
			
			$source = $data[$i];	// Byte to repeat
			++$i;
			
			for ($j = 0, $toCopy = $b; $j < $toCopy; $j++, $p+=2) {
				if ($p >= GFX_BUFFER_SIZE) {
					if ($p == GFX_BUFFER_SIZE+1) return $out; // phase 2 (odd bytes) done?
					$p = 1;
				}
				$out[$p] = $source;
			}
		}
	}
	return $out;
}