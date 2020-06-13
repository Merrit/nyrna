# Standard Library
import os

# Third Party Libraries
import PySimpleGUIQt as sg


class SysTray:

    """ Create the system tray icon for Nyrna """

    def __init__(self):
        super().__init__()
        # Path to the Nyrna icon
        run_directory = os.path.dirname(__file__)
        nyrna_icon = os.path.join(run_directory, "../icons/nyrna.png")
        # Menu entries
        menu_def = ["BLANK", ["!Configure", "---", "Exit"]]
        tray = sg.SystemTray(menu=menu_def, filename=nyrna_icon)
        # Add if statements to take action based on menu input
        while True:
            event = tray.read()
            if event == "Exit":
                break
            elif event == "Menu": # Template for future functionality
                tray.show_message("Title", "Hey, you clicked Menu!")
