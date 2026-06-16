package com.example.taller04

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.snapshare/intent"
    private var methodChannel: MethodChannel? = null
    
    private var pendingText: String? = null
    private var pendingImagePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialIntent") {
                val response = mapOf(
                    "text" to pendingText,
                    "imagePath" to pendingImagePath
                )
                pendingText = null
                pendingImagePath = null
                result.success(response)
            } else {
                result.notImplemented()
            }
        }
        
        // Procesar el intent inicial si existe
        intent?.let { handleIntent(it) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_SEND) {
            val type = intent.type ?: return
            
            if ("text/plain" == type) {
                intent.getStringExtra(Intent.EXTRA_TEXT)?.let {
                    pendingText = it
                    methodChannel?.invokeMethod("sharedText", it)
                }
            } else if (type.startsWith("image/")) {
                val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(Intent.EXTRA_STREAM)
                }
                
                uri?.let {
                    val path = copyUriToCache(it)
                    pendingImagePath = path
                    methodChannel?.invokeMethod("sharedImage", path)
                }
            }
        }
    }

    private fun copyUriToCache(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val file = File(cacheDir, "shared_image_${System.currentTimeMillis()}.jpg")
            FileOutputStream(file).use { output ->
                inputStream.copyTo(output)
            }
            file.absolutePath
        } catch (e: Exception) {
            null
        }
    }
}
