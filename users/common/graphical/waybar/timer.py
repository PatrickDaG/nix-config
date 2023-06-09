#!python

import time
import math
import os
import argparse
import subprocess
from typing import Optional

# TODO mypy and pylint type checker

state_file: str = "/tmp/timer_end"

def get_timer() -> Optional[float]:
    try:
        with open(state_file, "r") as f:
            return float(f.read())
    except:
        return None

def timer_print_remain() -> None:
    end = get_timer()
    if end is None:
        print("Timer ")
    else:
        remain = end - time.time()
        if remain > 60:
            print(f"{math.ceil(remain/60)} min")
        else:
            print(f"{math.ceil(remain)} sec")


def timer_start(minutes: int = 20):
    # If a timer exists already this function does nothing
    if get_timer() is not None:
        return
    end: float = time.time() + minutes * 60
    timer_save(end)

def timer_save(end: float):
    with open(state_file, "w") as f:
        f.write(f"{end}")

def timer_delete():
    os.remove(state_file)

def timer_increase(minutes: int = 5):
    end = get_timer()
    if end is None:
        return
    end += minutes *60
    timer_save(end)

def timer_decrease(minutes: int = 5):
    end = get_timer()
    if end is None:
        return
    end -= minutes *60
    timer_save(end)

def timer_maybe_end():
    end = get_timer()
    if end is not None and end - time.time() < 0:
        timer_delete()
        subprocess.run(["dunstify", "-u", "critical", "Timer ended"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Timer")
    parser.add_argument("-s", "--start", action = "store_true")
    parser.add_argument("-m", "--minutes", action = "store", type = int)
    parser.add_argument("-i", "--increase", action = "store_true")
    parser.add_argument("-d", "--decrease", action = "store_true")
    parser.add_argument("-x", "--delete", action = "store_true")
    args = parser.parse_args()
    if args.start:
        if args.minutes is None:
            timer_start()
        else:
            timer_start(args.minutes)
    if args.increase:
        if args.minutes is None:
            timer_increase()
        else:
            timer_increase(args.minutes)
    if args.decrease:
        if args.minutes is None:
            timer_decrease()
        else:
            timer_decrease(args.minutes)
    if args.delete:
        timer_delete()
    timer_maybe_end()
    timer_print_remain()
