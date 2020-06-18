# Standard Library
import logging
import logging.handlers
import os

# Nyrna Modules
import constant


# Since this runs via hotkey there is no terminal to
# print to, we need a logger for debugging.
# LOG_FILENAME = os.path.join(sys.path[0], "nyrna.log")
os.makedirs(constant.directories.user_cache_dir, exist_ok=True)
LOG_FILENAME = os.path.join(constant.directories.user_cache_dir, "nyrna.log")
logger = logging.getLogger("Logger")
logger.setLevel(logging.DEBUG)
handler = logging.handlers.RotatingFileHandler(
    filename=LOG_FILENAME, maxBytes=1000000, backupCount=2, encoding="utf-8"
)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


def log(logMessage):
    # Easier way to call the debug logger:
    # log("message")
    return logger.debug(logMessage)
