import serial
import sys
import time

COM_PORT = 'COM6'     
BAUD_RATE = 9600       
HEX_FILE = 'demo.hex'  

def main():
    print(f"*** AVR Softcore Programmer ***\n")
    print(f"Opening port: {COM_PORT} |baud rate: {BAUD_RATE} \n")

    try:
        with serial.Serial(COM_PORT, BAUD_RATE, timeout=2.0) as ser:
            print("Succesfully opened port.")

            # Wait for port to stabilize after opening
            time.sleep(0.5)
            ser.reset_input_buffer()

            with open(HEX_FILE, 'r') as file:
                lines = file.readlines()
                total_lines = len(lines)-2
                
                print(f"Succesfully read file: '{HEX_FILE}'.")
                print(f"Total lines in HEX file: {total_lines}")
                print("Starting flash sequence...\n")

                bytes_sent_total = 0
                errors = 0

                for i, line in enumerate(lines):
                    clean_line = line.strip()
                    
                    # Skip empty lines
                    if len(clean_line) == 0:
                        continue
                    
                    # Check if line starts with ':'
                    if clean_line[0] != ':':    
                        print(f"\n[ERROR] Line {i+1}: Invalid format.")
                        continue
                    
                    hex_count = clean_line[1:3]       # Byte count
                    hex_address = clean_line[3:7]     # Address
                    record_type = clean_line[7:9]     # Record type
                    
                    # Reading only lines with data
                    if record_type != '00':
                        continue
                    
                    # Hex -> Int 
                    byte_count = int(hex_count, 16)
                    
                    # Extracting only data part
                    data_hex_string = clean_line[9 : 9 + (byte_count * 2)]
                    
                    # Hex string -> Bytes
                    raw_bytes = bytes.fromhex(data_hex_string)
                    
                    # ==========================================
                    # Byte send and Echo verify
                    # ==========================================
                    for byte_val in raw_bytes:
                        byte_to_send = bytes([byte_val])
                        
                        # Sending byte
                        ser.write(byte_to_send)
                        
                        # Reading echoed byte from UART_Tx
                        echoed_byte = ser.read(1)
                        
                        if not echoed_byte:
                            print(f"\n\nTimeout! FPGA did not send echo back.")
                            print(f"Last sent byte: 0x{byte_to_send.hex().upper()}")
                            sys.exit(1)
                            
                        if echoed_byte != byte_to_send:
                            print(f"\n\nData corruption detected!")
                            print(f"Sent: 0x{byte_to_send.hex().upper()} | Echo: 0x{echoed_byte.hex().upper()}")
                            print(f"Byte position: {bytes_sent_total}")
                            errors += 1
                            sys.exit(1)

                        bytes_sent_total += 1

                    # Progress bar
                    sys.stdout.write(f"  Line [{i}/{total_lines}] | Address: 0x{hex_address} | Bytes in line: {byte_count} | Total sent: {bytes_sent_total}\r")
                    sys.stdout.flush()

            print(f"\n\n[HURRAY] Successfully flashed! Total of {bytes_sent_total} bytes sent!")

    except serial.SerialException as e:
        print(f"\n Can't connect to  {COM_PORT}.")
        print(f" Details: {e}")


if __name__ == '__main__':
    main()