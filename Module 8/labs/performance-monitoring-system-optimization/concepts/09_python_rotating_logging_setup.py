"""
Python Rotating Logging Setup.

Use this when a production script needs log files that do not grow forever.
"""

import logging
from logging.handlers import RotatingFileHandler
from pathlib import Path


# Create the log folder before writing the log file.
Path("logs").mkdir(exist_ok=True)

logger = logging.getLogger("etl_monitor")
logger.setLevel(logging.INFO)

# RotatingFileHandler limits file size and keeps backups.
handler = RotatingFileHandler(
    "logs/etl_monitor.log",
    # maxBytes is the largest size of the active log file.
    maxBytes=5_000_000,
    # backupCount is how many older log files to keep.
    backupCount=5
)

formatter = logging.Formatter(
    "%(asctime)s - %(levelname)s - %(message)s"
)

# Attach the format and handler to the logger.
handler.setFormatter(formatter)
logger.addHandler(handler)

# Write one test event.
logger.info("Logging with rotation enabled")
