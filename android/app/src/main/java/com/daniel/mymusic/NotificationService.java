package com.daniel.mymusic;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.IBinder;


import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;

public class NotificationService extends Service {
    public static Intent playIntent;
    public static Intent prevIntent;
    public static Intent nextIntent;
    public static Intent notificationIntent;
    public static Intent deleteIntent;
    public static PendingIntent pplayIntent;
    public static PendingIntent pprevIntent;
    public static PendingIntent pnextIntent;
    public static PendingIntent pendingIntent;
    public static PendingIntent pdeleteIntent;
    public static final String CHANNEL_ID = "Playback";
    public static NotificationManager notificationManager;
    public static Notification notification;
    public static NotificationManagerCompat notificationManagerForOreo;
    public static int notificationId = 0;
    public static int[] iconInts = { R.drawable.ic_pause, R.drawable.ic_play };
    public static int index = 0;
    public static String title;
    public static String artist;
    public static String imageUrl;
    public static boolean isPlaying;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent.getAction().equals(Constants.STARTFOREGROUND_ACTION)) {
            initIntents();
            isPlaying = true;
        } else if (intent.getAction().equals(Constants.MAIN_ACTION)) {

        } else if (intent.getAction().equals(Constants.PREV_ACTION)) {
            MainActivity.channel.invokeMethod("prevSong", null, new Result() {
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
            loadImageUrl(title, artist, imageUrl, getApplicationContext(), isPlaying);
            MainActivity.channel.invokeMethod("playOrPause", null, new Result() {
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
            MainActivity.channel.invokeMethod("nextSong", null, new Result() {
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
        return START_STICKY;
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancel(0);
    }

    @Override
    public void onDestroy() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    public static void loadImageUrl(final String t, final String a, String i, final Context context, boolean iP) {
        isPlaying = iP;
        if (isPlaying) {
            index = 0;
        } else {
            index = 1;
        }
        title = t;
        artist = a;
        imageUrl = i;
        if (!imageUrl.equals("")) {
            Picasso.get().load(imageUrl).into(new Target() {
                @Override
                public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from) {
                    makeNotification(title, artist, bitmap, context);
                }

                @Override
                public void onBitmapFailed(Exception e, Drawable errorDrawable) {
                    makeNotification(title, artist, null, context);
                }

                @Override
                public void onPrepareLoad(Drawable placeHolderDrawable) {
                }
            });
        } else {
            makeNotification(title, artist, null, context);
        }
    }

    private static void makeNotification(String title, String artist, Bitmap imageBitmap, Context context) {
        if (imageBitmap == null) {
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
                    .setAutoCancel(true)
                    .setShowWhen(false)
                    .setColor(context.getResources()
                    .getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous, "", pprevIntent)
                    .addAction(iconInts[index], "", pplayIntent)
                    .addAction(R.drawable.ic_skip_next, "", pnextIntent)
                    .setTimeoutAfter(1800000)
                    .setStyle(
                            new androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1, 2))
                    .setDeleteIntent(pdeleteIntent).build();
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
            notificationManagerForOreo.notify(notificationId, notification);
        } else {
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notification = new NotificationCompat.Builder(context).setContentTitle(title).setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background).setLargeIcon(imageBitmap).setAutoCancel(true)
                    .setSound(null).setShowWhen(false).setColor(context.getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous, "", pprevIntent).addAction(iconInts[index], "", pplayIntent)
                    .addAction(R.drawable.ic_skip_next, "", pnextIntent).setTimeoutAfter(1800000)
                    .setDeleteIntent(pdeleteIntent).build();
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
            notificationManager.notify(notificationId, notification);
        }
        notification.contentIntent = pendingIntent;
    }

    private static void CreateNotificationChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Playback",
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.setSound(null, null);
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(channel);

        }
    }

    private void initIntents() {
        notificationIntent = new Intent(this, MainActivity.class);
        notificationIntent.setAction(Constants.MAIN_ACTION);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
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

        deleteIntent = new Intent(this, NotificationService.class);
        deleteIntent.setAction(Constants.STOPFOREGROUND_ACTION);
        pdeleteIntent = PendingIntent.getService(this, 0, deleteIntent, 0);
    }
}