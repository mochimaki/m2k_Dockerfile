"""
ADALM2000 Analog Input Test Program

This program implements the following features:

1. ADALM2000 initialization and connection verification
2. Analog input channel configuration
   - Sampling rate: 100kHz
   - Input range: ±10V
   - Channel 1 enabled
3. Data acquisition of 1000 samples

Usage:
    python3 analog_test.py
"""

import libm2k
import numpy as np

def main():
    # Initialize ADALM2000 (specify IP address)
    ctx = libm2k.m2kOpen("ip:192.168.2.1")  # Specify ADALM2000 IP address
    if ctx is None:
        print("ADALM2000 not found")
        return

    try:
        # Configure analog input
        ain = ctx.getAnalogIn()
        ain.setSampleRate(100000)
        ain.setRange(libm2k.ANALOG_IN_CHANNEL_1, -10, 10)
        
        # Enable channel
        ain.enableChannel(libm2k.ANALOG_IN_CHANNEL_1, True)

        # Get data
        data = ain.getSamples(1000)
        print("Acquired data:", data)
    except Exception as e:
        print(f"Error occurred: {e}")

if __name__ == "__main__":
    main()