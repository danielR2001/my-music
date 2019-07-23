package com.daniel.mymusic;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
////import android.content.ComponentName;
import android.os.Build;
////import android.media.session.PlaybackState;
import android.support.v4.media.session.MediaSessionCompat;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;


public class MediaNotificationManager{
    private final int notificationId = 0;
    private final String CHANNEL_ID = "Playback";
    private final int[] iconInts = { R.drawable.ic_pause, R.drawable.ic_play };

    private Intent playIntent;
    private Intent prevIntent;
    private Intent nextIntent;
    private Intent notificationIntent;
    private PendingIntent pplayIntent;
    private PendingIntent pprevIntent;
    private PendingIntent pnextIntent;
    private PendingIntent pendingIntent;

    private NotificationManager notificationManager;
    private Notification notification;
    private NotificationManagerCompat notificationManagerForOreo;
    private MediaSessionCompat mediaSession;

    
    private int index;
    private Bitmap imageBitmap;
    private Context context;

    public MediaNotificationManager (Context context) {
        this.context = context;
        this.index = 0;

        notificationIntent = new Intent(this.context, MainActivity.class);
        pendingIntent = PendingIntent.getActivity(this.context, 0, notificationIntent, 0);


        playIntent = new Intent(this.context, ActionReceiver.class);
        playIntent.setAction(Constants.PLAY_ACTION);
        pplayIntent = PendingIntent.getBroadcast(this.context, 1, playIntent, 0);

        prevIntent = new Intent(this.context, ActionReceiver.class);
        prevIntent.setAction(Constants.PREV_ACTION);
        pprevIntent = PendingIntent.getBroadcast(this.context, 1, prevIntent, 0);

        nextIntent = new Intent(this.context, ActionReceiver.class);
        nextIntent.setAction(Constants.NEXT_ACTION);
        pnextIntent = PendingIntent.getBroadcast(this.context, 1, nextIntent, 0);

        mediaSession = new MediaSessionCompat(this.context, "playback", null, null);//// mediaButtonReceiver, null);
        ////ComponentName mediaButtonReceiver = new ComponentName(this ,RemoteControlReceiver.class);
        //// mediaSession.setCallback(new MediaSessionCompat.Callback() {
        ////     @Override
        ////     public void onPlay() {
        ////         super.onPlay();
        ////         Log.d("hiiii","play!");
        ////     }

        ////     @Override
        ////     public void onPause() {
        ////         super.onPause();
        ////         Log.d("hiiii","pause!");
        ////     }
        //// });
        //// mediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS | 
        ////                     MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS);
        //// mediaSession.setCallback(this);
        //// Set up what actions you support and the state of your player
        //// mediaSession.setState(
        ////     new PlaybackState.Builder()
        ////     .setActions(PlaybackState.ACTION_PLAY |
        ////                 PlaybackState.ACTION_PAUSE |
        ////                 PlaybackState.ACTION_PLAY_PAUSE)
        ////     .setState(PlaybackState.STATE_PLAYING,
        ////                 0, 
        ////                 1));
        //// mediaSession.setActive(true);

    }
    @SuppressWarnings( "deprecation" )
    public void makeNotification(String title, String artist, Bitmap imageBitmap, boolean isPlaying, String imageUrl, boolean loadImage) {
        if(loadImage){
            this.imageBitmap = imageBitmap;
        }
        if (isPlaying) {
            this.index = 0;
        } else {
            this.index = 1;
        }
        if (this.imageBitmap == null && imageUrl.equals("")) {
            this.imageBitmap = BitmapFactory.decodeResource(this.context.getResources(), R.drawable.app_logo_square);
        } else if (this.imageBitmap == null && !imageUrl.equals("")) {
            this.imageBitmap = BitmapFactory.decodeResource(this.context.getResources(), R.drawable.app_logo_square);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CreateNotificationChannel();
            notificationManagerForOreo = NotificationManagerCompat.from(this.context);
            notification = new NotificationCompat.Builder(this.context, CHANNEL_ID)
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(this.imageBitmap)
                    .setShowWhen(false)
                    .addAction(R.drawable.ic_previous, "", pprevIntent)
                    .addAction(iconInts[this.index], "", pplayIntent)
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
            notificationManager = (NotificationManager) this.context.getSystemService(Context.NOTIFICATION_SERVICE);
            notification = new NotificationCompat.Builder(context)
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(this.imageBitmap)
                    .setSound(null)
                    .setShowWhen(false)
                    .setColor(this.context.getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_previous, "Previous", pprevIntent)
                    .addAction(iconInts[index], index == 0 ? "Pause" : "Play", pplayIntent)
                    .addAction(R.drawable.ic_next, "Next", pnextIntent)
                    .setContentIntent(pendingIntent)
                    .setTimeoutAfter(1800000)
                    .setCategory(Notification.CATEGORY_TRANSPORT)
                    .setWhen(System.currentTimeMillis())
                    .setPriority(notificationManager.IMPORTANCE_MAX)
                    .build();
        }
        if (isPlaying) {
            notification.flags |= Notification.FLAG_ONGOING_EVENT;
        }
        //startForeground(0, notification);
        notificationManager.notify(notificationId, notification);

    }

    private void CreateNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel(CHANNEL_ID, "Playback",
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationChannel.setSound(null, null);
            notificationChannel.setShowBadge(false);
            notificationManager = (NotificationManager) this.context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(notificationChannel);

        }
    }
}