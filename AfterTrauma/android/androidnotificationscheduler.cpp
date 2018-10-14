#include <QDebug>
#include <QtAndroid>
#include <QAndroidJniEnvironment>

void _requestNotificationPermision() {

}

void _scheduleNotification( int id, QString message, unsigned int delay, unsigned int frequency ) {
    QAndroidJniEnvironment env;
    qDebug() << "scheduling notification : " << message;
    QAndroidJniObject jni_message = QAndroidJniObject::fromString(message);

    QAndroidJniObject::callStaticMethod<void>("uk/co/soda/NotificationScheduler",
                                              "show",
                                              "(ILjava/lang/String;II)V",
                                              (jint) id,
                                              jni_message.object<jstring>(),
                                              (jint) delay,
                                              (jint) frequency);
}

void _scheduleNotificationByPattern( int id, QString message, int pattern ) {
    QAndroidJniEnvironment env;
    qDebug() << "scheduling notification : " << message;
    QAndroidJniObject jni_message = QAndroidJniObject::fromString(message);

    QAndroidJniObject::callStaticMethod<void>("uk/co/soda/NotificationScheduler",
                                              "show",
                                              "(ILjava/lang/String;II)V",
                                              (jint) id,
                                              jni_message.object<jstring>(),
                                              (jint) pattern);
}

void _cancelNotification( int id ) {
    QAndroidJniObject::callStaticMethod<void>("uk/co/soda/NotificationScheduler",
                                              "hide",
                                              "(I)V",
                                              (jint) id);
}

void _cancelAllNotifications() {
    QAndroidJniObject::callStaticMethod<void>("uk/co/soda/NotificationScheduler",
                                              "hideAll",
                                              "()V");
}

extern int _getActivationNotificationId() {
    return QAndroidJniObject::callStaticMethod<jint>("uk/co/soda/NotificationHandler",
                                                         "getNotificationId",
                                                         "()I");

}

/*
// Qt
import org.qtproject.qt5.android.QtNative;

// android
import android.content.Intent;
import android.content.Context;
import android.app.PendingIntent;
import android.app.Notification;
import android.app.NotificationManager;

// java
import java.lang.String;

class QtAndroidNotifications {

    public static void show(String title, String caption, int id) {
        System.out.println("show");

        Context context = QtNative.activity();

        NotificationManager notificationManager = getManager();
        Notification.Builder builder =
                new Notification.Builder(context)
                .setSmallIcon(android.R.drawable.ic_delete)
                .setContentTitle(title)
                .setContentText(caption)
                .setAutoCancel(true)
                ;

        String packageName = context.getApplicationContext().getPackageName();
        Intent resultIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        resultIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);

        PendingIntent resultPendingIntent =
            PendingIntent.getActivity(
            context, 0,
            resultIntent, PendingIntent.FLAG_UPDATE_CURRENT
        );

        builder.setContentIntent(resultPendingIntent);
        notificationManager.notify(id, builder.build());
    }

    public static void hide(int id) {
        getManager().cancel(id);
    }

    public static void hideAll() {
        getManager().cancelAll();
    }

    private static NotificationManager getManager() {
        Context context = QtNative.activity();
        return (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    }
}

*/
