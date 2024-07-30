## FILE: cpu_bust.py
##
## DESCRIPTION: Increases CPU load slowly by doing nominal mathematical work.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: python3 cpu_bust.py
##

import math
import time

# Initial number of iterations
num_iterations = 100

# Growth rate for the number of iterations
iterations_growth_rate = 1.02

while True:
    # Perform CPU-intensive calculations to increase the load
    for _ in range(num_iterations):
        for _ in range(100):
            # Nominal calculation representing CPU work
            max(0.0001, math.log(1))

    # Increase the number of iterations for the next iteration
    num_iterations = int(num_iterations * iterations_growth_rate)

    # Add a small sleep to control the speed of the loop
    time.sleep(0.2)
