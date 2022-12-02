import 'dart:io';

/// Tests that require a display & windows to work with will
/// check for [runningInCI], and skip runs in GitHub Workflows.
final bool runningInCI = (Platform.environment['GITHUB_ACTIONS'] == 'true');
