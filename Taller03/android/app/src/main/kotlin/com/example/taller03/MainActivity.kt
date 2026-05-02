package com.example.taller03

import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.taller03.R

class MainActivity: FlutterActivity() {
    private val CHANNEL = "epn.edu.ec/recursos_nativos"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "obtenerRecursos") {
                try {
                    val textoResult = getString(R.string.text)

                    val colorTextoResult = ContextCompat.getColor(this, R.color.text_color)
                    val colorFondoResult = ContextCompat.getColor(this, R.color.bg_color)

                    val recursos = mapOf(
                        "text" to textoResult,
                        "text_color" to colorTextoResult,
                        "bg_color" to colorFondoResult
                    )

                    result.success(recursos)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Error al obtener recursos", e.localizedMessage)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}