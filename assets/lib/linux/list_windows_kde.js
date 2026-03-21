// https://unix.stackexchange.com/a/706478/379240

function print(str) {
    console.info('Nyrna: ' + str);
}

let windows = workspace.windowList();
print('Found ' + windows.length + ' windows');

function updateWindowsOnDBus(windows) {
    let windowsList = [];

    for (let window of windows) {
        windowsList.push({
            caption: window.caption,
            pid: window.pid,
            internalId: window.internalId,
            onCurrentDesktop: isWindowOnCurrentDesktop(window),
        });
    }

    callDBus(
        'codes.merritt.Nyrna',
        '/',
        'codes.merritt.Nyrna',
        'updateWindows',
        JSON.stringify(windowsList),
        (result) => {
            if (result) {
                print('Successfully updated windows on DBus');
            } else {
                print('Failed to update windows on DBus');
            }
        }
    );
}

function isWindowOnCurrentDesktop(window) {
    let windowDesktops = Object.values(window.desktops);
    let windowIsOnCurrentDesktop = window.onAllDesktops;

    if (!windowIsOnCurrentDesktop) {
        for (let windowDesktop of windowDesktops) {
            if (windowDesktop.id === workspace.currentDesktop.id) {
                windowIsOnCurrentDesktop = true;
                break;
            } else {
                windowIsOnCurrentDesktop = false;
            }
        }
    }

    return windowIsOnCurrentDesktop;
}

updateWindowsOnDBus(windows);

workspace.currentDesktopChanged.connect(() => {
    print('Current desktop changed');
    updateWindowsOnDBus(windows);
});

workspace.windowAdded.connect(window => {
    print('Window added: ' + window.caption);
    windows.push(window);
    updateWindowsOnDBus(windows);
});

workspace.windowRemoved.connect(window => {
    print('Window removed: ' + window.caption);
    windows = windows.filter(w => w.internalId !== window.internalId);
    updateWindowsOnDBus(windows);
});
