package com.example.movswgr22026a.taller04

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Debe coincidir exactamente con el canal declarado en Dart
    private val CHANNEL = "com.taller04/toast"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "showToast") {
                    val message = call.argument<String>("message") ?: "Acción completada"
                    // Toast.makeText nativo de Android
                    Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}