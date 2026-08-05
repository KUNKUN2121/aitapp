import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 取得の進捗状態。取得中は全画面オーバーレイで監視される。
class TimetableFetchState {
  const TimetableFetchState({
    this.isRunning = false,
    this.current = 0,
    this.total = 0,
    this.message,
    this.canCancel = false,
  });

  final bool isRunning;
  final int current;
  final int total;
  final String? message;
  final bool canCancel;

  double get progress => total == 0 ? 0 : (current / total).clamp(0.0, 1.0);

  TimetableFetchState copyWith({
    bool? isRunning,
    int? current,
    int? total,
    String? message,
    bool? canCancel,
  }) {
    return TimetableFetchState(
      isRunning: isRunning ?? this.isRunning,
      current: current ?? this.current,
      total: total ?? this.total,
      message: message ?? this.message,
      canCancel: canCancel ?? this.canCancel,
    );
  }
}

/// 時間割取得の進捗・キャンセル・スリープ抑止を司るNotifier。
///
/// 取得中はwakelockで画面のスリープを抑止し、開始から一定時間経過後に
/// キャンセルボタンを表示する。
class TimetableFetchNotifier extends StateNotifier<TimetableFetchState> {
  TimetableFetchNotifier() : super(const TimetableFetchState());

  /// キャンセルボタンを表示するまでの待機時間。
  static const cancelDelay = Duration(seconds: 15);

  bool _cancelRequested = false;
  Timer? _cancelTimer;

  bool get isCancelRequested => _cancelRequested;

  /// 取得を開始する。[total]は進捗バーの分母(概算ステップ数)。
  void start(int total) {
    _cancelRequested = false;
    _cancelTimer?.cancel();
    state = TimetableFetchState(isRunning: true, total: total);
    WakelockPlus.enable();
    _cancelTimer = Timer(cancelDelay, () {
      if (mounted && state.isRunning) {
        state = state.copyWith(canCancel: true);
      }
    });
  }

  /// 進捗を更新する。[current]は完了ステップ数、[message]は現在の状況。
  void report(int current, int total, String message) {
    if (state.isRunning) {
      state = state.copyWith(current: current, total: total, message: message);
    }
  }

  /// キャンセルを要求する。実際の中断は取得ループのチェックで行われる。
  void requestCancel() {
    _cancelRequested = true;
  }

  /// 取得を終了し、オーバーレイを閉じてスリープ抑止を解除する。
  void finish() {
    _cancelTimer?.cancel();
    _cancelRequested = false;
    WakelockPlus.disable();
    state = const TimetableFetchState();
  }

  @override
  void dispose() {
    _cancelTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}

final timetableFetchProvider =
    StateNotifierProvider<TimetableFetchNotifier, TimetableFetchState>(
  (ref) => TimetableFetchNotifier(),
);
