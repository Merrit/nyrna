# Standard Library
import os

# Third Party Libraries
from appdirs import AppDirs


directories = AppDirs("Nyrna")
user_cache_dir = directories.user_cache_dir
user_data_dir = directories.user_data_dir
