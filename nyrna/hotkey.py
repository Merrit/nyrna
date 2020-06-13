# Third Party Libraries
from pynput import keyboard

# Nyrna Modules
import suspend


class HotKey:

    """ Global hotkey support for Nyrna """

    def __init__(self):
        super().__init__()
        listener = keyboard.Listener(on_press=self.on_press, on_release=self.on_release)
        listener.start()

    def on_press(self, key):
        """ Capture keystroke presses """
        try:
            print("alphanumeric key {0} pressed".format(key.char))
        except AttributeError:
            print("special key {0} pressed".format(key))

    def on_release(self, key):
        """
        Capture keystroke release.
        If it finds the configured key,
        call the suspend function.
        """
        print("{0} released".format(key))
        # TODO: Make hotkey user configurable
        if key == keyboard.Key.pause:
            # Toggle suspend for the foreground application
            suspend.toggle_suspend()
