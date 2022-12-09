#!/usr/bin/env python3

import subprocess
import json
import os


def run_test():
    test=subprocess.run(["/usr/local/bin/speedtest-cli", "--json"], capture_output=True)
    
    if test.returncode == 0:
        result = json.loads(test.stdout.decode('utf-8'))
        return result
    else:
        raise RuntimeError("Error running speedtest!")


def convert_bits(size, target):
    sizes = {
            "b": 0, # bits
            "k": 1, # kbits
            "m": 2, # Mbits
            "g": 3, # Gbits
            "t": 4, # Tbits
            }
    
    power = 2**10
    n = 0

    if target not in sizes.keys():
        raise ValueError("Target " + target + " must be in " + str(sizes.keys()))
    else:
        while n < sizes[target]: 
            size /= power
            n += 1
        return size


if __name__ == "__main__":
    speedtest = run_test()

    speed_factor = "M"
    download_speed = round(convert_bits(speedtest["download"], speed_factor.lower()), 2)
    upload_speed = round(convert_bits(speedtest["upload"], speed_factor.lower()), 2)
    ping_speed = round(speedtest["ping"], 2)

    output = "Down: " + str(download_speed) + " " + speed_factor + "bps\n"
    output = output + "---\n"
    output = output + "Up: " + str(upload_speed) + " " + speed_factor + "bps\n"
    output = output + "Ping: " + str(ping_speed)

    print(output)

