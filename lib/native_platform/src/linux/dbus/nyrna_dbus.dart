// This file was generated using the following command and may be overwritten.
// dart-dbus generate-object lib/native_platform/src/linux/codes.merritt.Nyrna.xml

import 'dart:async';

import 'package:dbus/dbus.dart';

import '../../../../logs/logs.dart';

class NyrnaDbus extends DBusObject {
  /// Creates a new object to expose on [path].
  NyrnaDbus._({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  static Future<NyrnaDbus> initialize() async {
    final nyrnaDbus = NyrnaDbus._();
    await nyrnaDbus._registerNyrnaDbusObject();
    return nyrnaDbus;
  }

  /// Register Nyrna's service on DBus.
  Future<void> _registerNyrnaDbusObject() async {
    final client = DBusClient.session();

    DBusRequestNameReply result;

    try {
      result = await client.requestName(
        'codes.merritt.Nyrna',
        flags: {
          DBusRequestNameFlag.allowReplacement,
          DBusRequestNameFlag.doNotQueue,
          DBusRequestNameFlag.replaceExisting,
        },
      );
    } catch (e) {
      log.e('Failed to request name: $e');
      rethrow;
    }

    if (result != DBusRequestNameReply.primaryOwner) {
      log.e('Failed to request name: $result');
      throw Exception('Failed to request name: $result');
    }

    await client.registerObject(this);
  }

  /// The JSON of windows found by the companion KDE KWin script.
  ///
  /// This will be updated by the `updateWindows` method, and read externally by the
  /// `Linux` class.
  String windowsJson = '';

  /// Called by the companion KDE KWin script to update the JSON of windows.
  Future<DBusMethodResponse> updateWindows(String windows) async {
    windowsJson = windows;

    return DBusMethodSuccessResponse([
      const DBusBoolean(true),
    ]);
  }

  final _activeWindowController = StreamController<String>.broadcast();
  Stream<String> get activeWindowUpdates => _activeWindowController.stream;

  /// Called by the companion KDE KWin script to update the active window.
  Future<DBusMethodResponse> updateActiveWindow(String windowId) async {
    log.t('Received active window update on DBus: $windowId');
    _activeWindowController.add(windowId);
    return DBusMethodSuccessResponse([const DBusBoolean(true)]);
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        'codes.merritt.Nyrna',
        methods: [
          DBusIntrospectMethod('updateCurrentDesktop'),
          DBusIntrospectMethod('updateWindows'),
          DBusIntrospectMethod('updateActiveWindow'),
        ],
      )
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    log.t(
        'Received method call: ${methodCall.interface}.${methodCall.name}, signature: ${methodCall.signature}, values: ${methodCall.values}');

    if (methodCall.interface != 'codes.merritt.Nyrna') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'updateCurrentDesktop':
        return DBusMethodErrorResponse.unknownMethod();
      case 'updateWindows':
        if (methodCall.signature != DBusSignature('s')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return await updateWindows(methodCall.values[0].asString());
      case 'updateActiveWindow':
        if (methodCall.signature != DBusSignature('s')) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return await updateActiveWindow(methodCall.values[0].asString());
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'codes.merritt.Nyrna') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface == 'codes.merritt.Nyrna') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  Future<void> dispose() async {
    await _activeWindowController.close();
    final client = DBusClient.session();
    await client.releaseName('codes.merritt.Nyrna');
    await client.close();
  }
}
