# Standard Library
import os

# Third Party Libraries
from appdirs import AppDirs


DIRECTORIES = AppDirs("Nyrna")
USER_CACHE_DIR = DIRECTORIES.user_cache_dir
USER_DATA_DIR = DIRECTORIES.user_data_dir
