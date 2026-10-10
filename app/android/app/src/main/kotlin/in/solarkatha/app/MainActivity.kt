package `in`.solarkatha.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createUpdatesChannel()
    }

    /**
     * High-importance channel for project updates (signed proposals, stages
     * done): sound, vibration and a heads-up pop-up. Push messages name it
     * ("updates"); the manifest makes it FCM's default too.
     */
    private fun createUpdatesChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "updates",
            "Project updates",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Signed proposals and finished project stages"
            enableVibration(true)
            setSound(
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build(),
            )
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }
}
