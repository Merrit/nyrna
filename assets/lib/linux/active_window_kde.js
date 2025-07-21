function print(str) {
    console.info('Nyrna KDE Wayland: ' + str);
}

print('Updating active window on DBus');

function windowToJson(window) {
    return JSON.stringify({
        caption: window.caption,
        pid: window.pid,
        internalId: window.internalId,
    });
}

function updateActiveWindowOnDBus() {
    let activeWindow = workspace.activeWindow();

    if (!activeWindow) {
        print('No active window found');
        return;
    }
    
    let windowJson = windowToJson(activeWindow);

    callDBus(
        'codes.merritt.Nyrna',
        '/',
        'codes.merritt.Nyrna',
        'updateActiveWindow',
        windowJson,
        (result) => {
            if (result) {
                print('Successfully updated active window on DBus');
            } else {
                print('Failed to update active window on DBus');
            }
        }
    );
}

updateActiveWindowOnDBus();
