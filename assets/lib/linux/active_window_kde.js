function print(str) {
    console.info('Nyrna KDE Wayland: ' + str);
}

print('Setting up persistent active window listener');

function windowToJson(window) {
    return JSON.stringify({
        caption: window.caption,
        pid: window.pid,
        internalId: window.internalId,
    });
}

function sendActiveWindowUpdate(window) {
    if (!window) {
        print('No active window');
        return;
    }

    let windowJson = windowToJson(window);

    callDBus(
        'codes.merritt.Nyrna',
        '/',
        'codes.merritt.Nyrna',
        'updateActiveWindow',
        windowJson,
        (result) => {
            if (result) {
                print('Updated active window on DBus');
            } else {
                print('Failed to update active window on DBus');
            }
        }
    );
}

// Send the current active window immediately on load.
sendActiveWindowUpdate(workspace.activeWindow);

// Listen for every subsequent focus change.
workspace.windowActivated.connect(sendActiveWindowUpdate);
