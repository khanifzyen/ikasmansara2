package com.ikasmansara.ika_smansara

import android.content.Intent
import android.os.Bundle
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ikasmansara/in_app_update"
    private lateinit var appUpdateManager: AppUpdateManager
    private val APP_UPDATE_REQUEST_CODE = 9001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appUpdateManager = AppUpdateManagerFactory.create(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "checkForUpdate") {
                checkForUpdate(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun checkForUpdate(result: MethodChannel.Result) {
        val appUpdateInfoTask = appUpdateManager.appUpdateInfo

        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
                && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
            ) {
                try {
                    appUpdateManager.startUpdateFlowForResult(
                        appUpdateInfo,
                        this,
                        AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                        APP_UPDATE_REQUEST_CODE
                    )
                    result.success(true)
                } catch (e: Exception) {
                    result.error("UPDATE_FAILED", "Gagal memulai update: ${e.message}", null)
                }
            } else {
                result.success(false)
            }
        }.addOnFailureListener { e ->
            result.error("UPDATE_CHECK_FAILED", "Cek update gagal: ${e.message}", null)
        }
    }

    override fun onResume() {
        super.onResume()
        appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                // If an in-app update is already running, resume the update.
                try {
                    appUpdateManager.startUpdateFlowForResult(
                        appUpdateInfo,
                        this,
                        AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                        APP_UPDATE_REQUEST_CODE
                    )
                } catch (e: Exception) {
                    // Log error silently, UI stays responsive
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == APP_UPDATE_REQUEST_CODE) {
            if (resultCode != RESULT_OK) {
                // If the update is cancelled or fails, you can request to start the update again.
                // We're leaving it here gracefully so the user can continue using the app if it's optional
            }
        }
    }
}
