#!/usr/bin/env python3
"""
log_error_summary.py

Parses a log file and prints a summary of lines containing the word 'ERROR'.
Usage: python3 log_error_summary.py /path/to/logfile
"""

import sys
import re
from collections import Counter


def summarize_errors(log_path: str) -> dict:
    pattern = re.compile(r"ERROR.*", re.IGNORECASE)
    matches = []
    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if pattern.search(line):
                    matches.append(line.strip())
    except FileNotFoundError:
        print(f"Error: file not found: {log_path}")
        sys.exit(1)

    counter = Counter(matches)
    return {
        "total": len(matches),
        "unique": len(counter),
        "top": counter.most_common(10),
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} /path/to/logfile")
        sys.exit(1)

    result = summarize_errors(sys.argv[1])
    print(f"Total ERROR lines: {result['total']}")
    print(f"Unique ERROR lines: {result['unique']}")
    print("Top recurring ERROR lines:")
    for line, count in result["top"]:
        print(f"  {count}x | {line[:120]}")
