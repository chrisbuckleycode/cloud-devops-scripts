## FILE: monitor_endpoint_cdm.py
##
## DESCRIPTION: Monitors in realtime, CPU, Disk and Memory.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: python3 monitor_endpoint_cdm.py
##

import psutil
import time
import os
# time, os in standard library

def main():
    while True:
        os.system('clear')

        cpu_percent = psutil.cpu_percent()
        getloadavg = psutil.getloadavg()
        # >>20 refers to format (MB)
        virtual_memory_total = psutil.virtual_memory().total >> 20
        virtual_memory_used = psutil.virtual_memory().used >> 20
        virtual_memory_percent = psutil.virtual_memory().percent
        disk_usage_total = psutil.disk_usage('/').total >> 20
        disk_usage_used = psutil.disk_usage('/').used >> 20
        disk_usage_free = psutil.disk_usage('/').free >> 20
        disk_usage_percent = psutil.disk_usage('/').percent


        print(f"cpu_percent: {cpu_percent}")
        print(f"getloadavg: {getloadavg}")
        print("\n")
        print(f"virtual_memory_total: {virtual_memory_total}")
        print(f"virtual_memory_used: {virtual_memory_used}")
        print(f"virtual_memory_percent: {virtual_memory_percent}")
        print("\n")
        print(f"disk_usage_total: {disk_usage_total}")
        print(f"disk_usage_used: {disk_usage_used}")
        print(f"disk_usage_free: {disk_usage_free}")
        print(f"disk_usage_percent: {disk_usage_percent}")


        time.sleep(0.5)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        exit()
