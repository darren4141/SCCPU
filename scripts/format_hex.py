#!/usr/bin/env python3
import sys

def format_hex(input_file, output_file):
    """Convert Intel hex format to Verilog hex format (32-bit words)"""
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    output_lines = []
    address = 0
    bytes_buffer = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        if line.startswith('@'):
            # Address line
            address = int(line[1:], 16)
            # Flush any pending bytes
            if bytes_buffer:
                # Convert little-endian bytes to 32-bit word
                if len(bytes_buffer) == 4:
                    word = (bytes_buffer[3] << 24) | (bytes_buffer[2] << 16) | (bytes_buffer[1] << 8) | bytes_buffer[0]
                    output_lines.append(f"{word:08x}")
                bytes_buffer = []
            output_lines.append(line)
        else:
            # Data line with space-separated bytes
            bytes_list = line.split()
            for byte_str in bytes_list:
                bytes_buffer.append(int(byte_str, 16))
                
                # When we have 4 bytes, output as a 32-bit word
                if len(bytes_buffer) == 4:
                    word = (bytes_buffer[3] << 24) | (bytes_buffer[2] << 16) | (bytes_buffer[1] << 8) | bytes_buffer[0]
                    output_lines.append(f"{word:08x}")
                    bytes_buffer = []
    
    # Flush remaining bytes
    if bytes_buffer:
        if len(bytes_buffer) == 4:
            word = (bytes_buffer[3] << 24) | (bytes_buffer[2] << 16) | (bytes_buffer[1] << 8) | bytes_buffer[0]
            output_lines.append(f"{word:08x}")
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(output_lines))
        if output_lines:
            f.write('\n')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: format_hex.py <input_file> <output_file>")
        sys.exit(1)
    
    format_hex(sys.argv[1], sys.argv[2])
