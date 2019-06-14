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
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import android.graphics.BitmapFactory;
import java.util.concurrent.TimeUnit;
import android.util.Log;

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
    public static boolean isPlaying;
    public static Bitmap imageBitmap;
    public static String imageUrl;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent.getAction().equals(Constants.STARTFOREGROUND_ACTION)) {
            initIntents();
            isPlaying = true;
        } else if (intent.getAction().equals(Constants.MAIN_ACTION)) {
            // MainActivity.channel.invokeMethod("openMusicplayerPage", null, new Result() {
            //     @Override
            //     public void success(Object o) {
            //     }

            //     @Override
            //     public void error(String s, String s1, Object o) {
            //     }

            //     @Override
            //     public void notImplemented() {
            //     }
            // });
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
            makeNotification(title, artist, imageBitmap, getApplicationContext(), isPlaying, imageUrl);
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
        makeNotification(title, artist, imageBitmap, getApplicationContext(), false, imageUrl);
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
            new Thread() {
                @Override
                public void run() {
                    try {
                        TimeUnit.SECONDS.sleep(5);
                        new LoadImageFromUrl(title, artist, imageUrl, context, isPlaying).execute();
                        this.interrupt();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }.start();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CreateNotificationChannel(context);
            notificationManagerForOreo = NotificationManagerCompat.from(context);
            notification = new NotificationCompat.Builder(context, CHANNEL_ID).setContentTitle(title)
                    .setContentText(artist).setSmallIcon(R.drawable.app_logo_no_background).setLargeIcon(imageBitmap)
                    .setShowWhen(false).setColor(context.getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous, "", pprevIntent).addAction(iconInts[index], "", pplayIntent)
                    .addAction(R.drawable.ic_skip_next, "", pnextIntent).setTimeoutAfter(1800000)
                    .setStyle(
                            new androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1, 2))
                    .setDeleteIntent(pdeleteIntent).setContentIntent(pendingIntent).build();

        } else {
            notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notification = new NotificationCompat.Builder(context).setContentTitle(title).setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background).setLargeIcon(imageBitmap).setSound(null)
                    .setShowWhen(false).setColor(context.getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous, "", pprevIntent).addAction(iconInts[index], "", pplayIntent)
                    .addAction(R.drawable.ic_skip_next, "", pnextIntent).setTimeoutAfter(1800000)
                    .setDeleteIntent(pdeleteIntent).setContentIntent(pendingIntent).build();
        }
        if (iP) {
            notification.flags |= Notification.FLAG_ONGOING_EVENT;
        } else {
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
        }
        notificationManager.notify(notificationId, notification);
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
        //notificationIntent.setAction(Constants.MAIN_ACTION);
        pendingIntent = PendingIntent.getActivity(this, 1, notificationIntent, 0);

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