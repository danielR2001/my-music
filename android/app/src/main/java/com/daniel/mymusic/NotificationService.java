package com.daniel.mymusic;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.content.ComponentName;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.os.Build;
import android.os.IBinder;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.support.v4.media.session.MediaSessionCompat;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import android.graphics.BitmapFactory;
import java.util.concurrent.TimeUnit;

public class NotificationService extends Service {
    private static Intent playIntent;
    private static Intent prevIntent;
    private static Intent nextIntent;
    private static Intent notificationIntent;
    private static PendingIntent pplayIntent;
    private static PendingIntent pprevIntent;
    private static PendingIntent pnextIntent;
    private static PendingIntent pendingIntent;
    private static final String CHANNEL_ID = "Playback";
    private static NotificationManager notificationManager;
    private static Notification notification;
    private static NotificationManagerCompat notificationManagerForOreo;
    private static int notificationId = 0;
    private static int[] iconInts = { R.drawable.ic_pause, R.drawable.ic_play };
    private static int index = 0;
    private static String title;
    private static String artist;
    private static boolean isPlaying;
    public static Bitmap imageBitmap;
    private static String imageUrl;
    private static MediaSessionCompat mediaSession;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent.getAction().equals(Constants.STARTFOREGROUND_ACTION)) {
            initIntents();
            isPlaying = true;
        } else if (intent.getAction().equals(Constants.PREV_ACTION)) {
            MainActivity.channel1.invokeMethod("prevSong", null, new Result() {
                @Override
                public void success(Object o) {
                }

                @Override
                public void error(String s, String s1, Object o) {
                }

                @Override
                public void notImplemented() {
                }
            });
        } else if (intent.getAction().equals(Constants.PLAY_ACTION)) {
            isPlaying = !isPlaying;
            MainActivity.channel1.invokeMethod("playOrPause", null, new Result() {
                @Override
                public void success(Object o) {
                }

                @Override
                public void error(String s, String s1, Object o) {
                }

                @Override
                public void notImplemented() {
                }
            });
        } else if (intent.getAction().equals(Constants.NEXT_ACTION)) {
            MainActivity.channel1.invokeMethod("nextSong", null, new Result() {
                @Override
                public void success(Object o) {
                }

                @Override
                public void error(String s, String s1, Object o) {
                }

                @Override
                public void notImplemented() {
                }
            });
        }
        return START_NOT_STICKY;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancel(0);
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    public static void makeNotification(String t, String a, Bitmap b, Context context, boolean iP, String iU) {
        title = t;
        artist = a;
        imageBitmap = b;
        isPlaying = iP;
        imageUrl = iU;
        if (isPlaying) {
            index = 0;
        } else {
            index = 1;
        }
        if (imageBitmap == null && imageUrl.equals("")) {
            imageBitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.app_logo_square);
        } else if (imageBitmap == null && !imageUrl.equals("")) {
            imageBitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.app_logo_square);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CreateNotificationChannel(context);
            notificationManagerForOreo = NotificationManagerCompat.from(context);
            notification = new NotificationCompat.Builder(context, CHANNEL_ID)
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(imageBitmap)
                    .setShowWhen(false)
                    .addAction(R.drawable.ic_previous, "", pprevIntent)
                    .addAction(iconInts[index], "", pplayIntent)
                    .addAction(R.drawable.ic_next, "", pnextIntent)
                    .setStyle(new androidx.media.app.NotificationCompat.DecoratedMediaCustomViewStyle()
                            .setShowActionsInCompactView(0, 1, 2)
                            .setMediaSession(mediaSession.getSessionToken()))
                    .setContentIntent(pendingIntent)
                    .setTimeoutAfter(1800000)
                    .setColorized(true)
                    .setCategory(Notification.CATEGORY_TRANSPORT)
                    .setWhen(System.currentTimeMillis())
                    .build();

        } else {
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notification = new NotificationCompat.Builder(context)
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(imageBitmap)
                    .setSound(null)
                    .setShowWhen(false)
                    .setColor(context.getResources()
                    .getColor(R.color.pink))
                    .addAction(R.drawable.ic_previous, "Previous", pprevIntent)
                    .addAction(iconInts[index], index ==0?"Pause":"Play", pplayIntent)
                    .addAction(R.drawable.ic_next, "Next", pnextIntent)
                    .setContentIntent(pendingIntent)
                    .setTimeoutAfter(1800000)
                    .setCategory(Notification.CATEGORY_TRANSPORT)
                    .setWhen(System.currentTimeMillis())
                    .setPriority(notificationManager.IMPORTANCE_MAX)
                    .build();
        }
        if (iP) {
            notification.flags |= Notification.FLAG_ONGOING_EVENT;
        }
        notificationManager.notify(notificationId, notification);

    }

    private static void CreateNotificationChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel(CHANNEL_ID, "Playback",
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationChannel.setSound(null, null);
            notificationChannel.setShowBadge(false);
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(notificationChannel);

        }
    }

    private void initIntents() {
        notificationIntent = new Intent(this, MainActivity.class);
        pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0);

        playIntent = new Intent(this, NotificationService.class);
        playIntent.setAction(Constants.PLAY_ACTION);
        pplayIntent = PendingIntent.getService(this, 0, playIntent, 0);

        prevIntent = new Intent(this, NotificationService.class);
        prevIntent.setAction(Constants.PREV_ACTION);
        pprevIntent = PendingIntent.getService(this, 0, prevIntent, 0);

        nextIntent = new Intent(this, NotificationService.class);
        nextIntent.setAction(Constants.NEXT_ACTION);
        pnextIntent = PendingIntent.getService(this, 0, nextIntent, 0);

        //ComponentName mediaButtonReceiver = new ComponentName(this ,RemoteControlReceiver.class);
        mediaSession = new MediaSessionCompat(this, "playback", null, null);// mediaButtonReceiver, null);
        //mediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS | 
        //                    MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS);
       // mediaSession.setCallback(this);
       // mediaSession.setActive(true);

    }

    private static Bitmap getBitmapfromUrl(String imageUrl) {
        try {
            URL url = new URL(imageUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap bitmap = BitmapFactory.decodeStream(input);
            return bitmap;

        } catch (Exception e) {
            e.printStackTrace();
            return null;

        }
    }

}