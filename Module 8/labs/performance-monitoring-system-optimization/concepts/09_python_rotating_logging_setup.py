"""
Python Rotating Logging Setup.
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
    maxBytes=5_000_000,
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
