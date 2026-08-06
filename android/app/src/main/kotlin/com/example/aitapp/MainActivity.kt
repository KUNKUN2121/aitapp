package com.yoheinishi.aitapp

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // 通知開封ロジックのテスト用チャンネル(Dart側は kDebugMode 時のみ購読)。
    // 本物のFCM配信は adb から注入できないため、targetUrl を渡して
    // 「認証済みWebViewで開く」経路だけを検証できるようにする。
    //   adb shell am start -n com.yoheinishi.aitapp/.MainActivity \
    //     --es test_target_url "portalv2/.../detail/330848"
    private val channelName = "aitapp/push_test"
    private var methodChannel: MethodChannel? = null

    // アプリ終了状態から起動intentで渡されたURL。Dartが getInitialTestUrl で引き取る。
    private var pendingTestUrl: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingTestUrl = intent?.getStringExtra("test_target_url")
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialTestUrl") {
                    result.success(pendingTestUrl)
                    pendingTestUrl = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // バックグラウンドから再開時: そのままDartへ push(ウォーム経路)。
        intent.getStringExtra("test_target_url")?.let { url ->
            methodChannel?.invokeMethod("openTest", url)
        }
    }
}
