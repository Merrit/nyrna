// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get filterWindows => '过滤窗口';

  @override
  String get favoriteButtonTooltipAdd => '添加至收藏';

  @override
  String get favoriteButtonTooltipRemove => '从收藏中移除';

  @override
  String get suspendAllInstances => '挂起所有实例';

  @override
  String get resumeAllInstances => '恢复所有实例';

  @override
  String get close => '关闭';

  @override
  String get detailsDialogTitle => '详情';

  @override
  String get detailsDialogWindowTitle => '窗口名称';

  @override
  String get detailsDialogExecutableName => '进程名';

  @override
  String get detailsDialogPID => 'PID';

  @override
  String get detailsDialogCurrentStatus => '当前状态';

  @override
  String get statusNormal => '正常';

  @override
  String get statusSuspended => '已挂起';

  @override
  String get statusUnknown => '未知';

  @override
  String get copyLogs => '复制日志';

  @override
  String get logsCopiedNotification => '日志已复制到剪切板';

  @override
  String get donate => '捐赠';

  @override
  String get donateMessage => '如果您喜欢这个应用程序，请考虑捐赠以支持其开发。';

  @override
  String get madeBy => '用 💙 制作，来自： ';

  @override
  String get settingsTitle => '设置';

  @override
  String get behaviourTitle => '行为';

  @override
  String get autoRefresh => '自动刷新';

  @override
  String get autoRefreshDescription => '自动更新窗口和进程信息';

  @override
  String get autoRefreshInterval => '自动刷新间隔';

  @override
  String autoRefreshIntervalAmount(int interval) {
    return '$interval 秒';
  }

  @override
  String get closeToTray => '最小化到托盘';

  @override
  String get minimizeAndRestoreWindows => '最小化 / 还原窗口';

  @override
  String get pinSuspendedWindows => '固定已挂起的窗口';

  @override
  String get pinSuspendedWindowsTooltip => '如果启用，已挂起的窗口将始终显示在窗口列表的顶部。';

  @override
  String get showHiddenWindows => '显示隐藏窗口';

  @override
  String get showHiddenWindowsTooltip => '包括来自其他虚拟桌面的窗口以及通常无法检测到的特殊窗口。';

  @override
  String get themeTitle => '主题';

  @override
  String get dark => '暗色';

  @override
  String get light => '亮色';

  @override
  String get pitchBlack => '纯黑';

  @override
  String get systemIntegrationTitle => '系统集成';

  @override
  String get startAutomatically => '开机自启';

  @override
  String get startInTray => '开机后隐藏到系统托盘';

  @override
  String get troubleshootingTitle => '故障排除';

  @override
  String get logs => '日志';

  @override
  String get verboseLogging => '详细日志';

  @override
  String get aboutTitle => '关于';

  @override
  String get version => 'Nyrna 版本';

  @override
  String get homepage => 'Nyrna 主页';

  @override
  String get repository => 'GitHub 仓库';

  @override
  String get hotkey => '快捷键';

  @override
  String get recordNewHotkey => '录制新快捷键';

  @override
  String get appSpecificHotkeys => '应用专属快捷键';

  @override
  String get appSpecificHotkeysTooltip => '为选择的应用设置挂起/恢复状态的快捷键，即使应用未处于焦点状态也可使用。';

  @override
  String get addAppSpecificHotkey => '添加应用专属快捷键';

  @override
  String get selectApp => '选择应用';

  @override
  String get show => '显示';

  @override
  String get hide => '隐藏';

  @override
  String get resetWindow => '重置窗口';

  @override
  String get exit => '退出';
}
