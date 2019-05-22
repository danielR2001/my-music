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
import android.widget.Toast;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class NotificationService extends Service {
  Intent playIntent;
  Intent prevIntent;
  Intent nextIntent;
  Intent notificationIntent;
  Intent deleteIntent;
  PendingIntent pplayIntent;
  PendingIntent pprevIntent;
  PendingIntent pnextIntent;
  PendingIntent pendingIntent;
  PendingIntent pdeleteIntent;
  final String CHANNEL_ID = "channel";
  NotificationManager notificationManager;
  Notification notification;
  NotificationManagerCompat notificationManagerForOreo;
  int notificationId = 0;
  boolean isPlaying;
  int[] iconInts = {R.drawable.ic_pause,R.drawable.ic_play};
  int index = 0;
  String title;
  String artist;
  String imageUrl;
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent.getAction().equals(Constants.STARTFOREGROUND_ACTION)) {
            initIntents();
            title = intent.getStringExtra("title");
            artist = intent.getStringExtra("artist");
            imageUrl = intent.getStringExtra("imageUrl");
            isPlaying = intent.getBooleanExtra("isPlaying",true);
            if(isPlaying){
              index = 0;
            }else{
              index = 1;
            }
            makeNotification(title,artist,imageUrl);
        } else if (intent.getAction().equals(Constants.PREV_ACTION)) {
            index = 0;
            isPlaying = true;
            makeNotification(title,artist,imageUrl);
            MainActivity.channel.invokeMethod("prevSong", null, new Result() {
            @Override
            public void success(Object o) {
            }
            @Override
            public void error(String s, String s1, Object o) {}
            @Override
            public void notImplemented() {}
        });
        } else if (intent.getAction().equals(Constants.PLAY_ACTION)) {
          isPlaying = !isPlaying;
            if(isPlaying){
              index = 0;
            }else{
              index = 1;
            }
            makeNotification(title,artist,imageUrl);
            MainActivity.channel.invokeMethod("playOrPause", null, new Result() {
            @Override
            public void success(Object o) {
            }
            @Override
            public void error(String s, String s1, Object o) {}
            @Override
            public void notImplemented() {}
        });
        } else if (intent.getAction().equals(Constants.NEXT_ACTION)) {
            index = 0;
            isPlaying = true;
            makeNotification(title,artist,imageUrl);
            MainActivity.channel.invokeMethod("nextSong", null, new Result() {
            @Override
            public void success(Object o) {
            }
            @Override
            public void error(String s, String s1, Object o) {}
            @Override
            public void notImplemented() {}
        });
        } else if(intent.getAction().equals(Constants.STOPFOREGROUND_ACTION)){
            stopSelf();
        }
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        Toast.makeText(getApplicationContext(),"service has been destroyed",Toast.LENGTH_SHORT).show();
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    private void makeNotification(String title,String artist,String imageUrl) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            CreateNotificationChannel();
            notificationManagerForOreo = NotificationManagerCompat.from(this);
            notification = new NotificationCompat.Builder(getApplicationContext(),CHANNEL_ID)
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(BitmapFactory.decodeResource(getApplicationContext().getResources(),R.drawable.app_logo_square))
                    .setAutoCancel(true)
                    .setSound(null)
                    .setShowWhen(false)
                    .setColor(getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous,"previous",pprevIntent)
                    .addAction(iconInts[index],"pause",pplayIntent)
                    .addAction(R.drawable.ic_skip_next,"next",pnextIntent)
                    .setStyle(new androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0,1,2))
                    .setDeleteIntent(pdeleteIntent)
                    .build();
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
            notificationManagerForOreo.notify(notificationId, notification);
        }else {
            notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            notification = new NotificationCompat.Builder(getApplicationContext())
                    .setContentTitle(title)
                    .setContentText(artist)
                    .setSmallIcon(R.drawable.app_logo_no_background)
                    .setLargeIcon(BitmapFactory.decodeResource(getApplicationContext().getResources(),R.drawable.app_logo_square))
                    .setAutoCancel(true)
                    .setSound(null)
                    .setShowWhen(false)
                    .setColor(getResources().getColor(R.color.pink))
                    .addAction(R.drawable.ic_skip_previous,"previous",pprevIntent)
                    .addAction(iconInts[index],"pause",pplayIntent)
                    .addAction(R.drawable.ic_skip_next,"next",pnextIntent)
                    .setDeleteIntent(pdeleteIntent)
                    .build();
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
            notificationManager.notify(notificationId, notification);
        }
        notification.contentIntent = pendingIntent;
    }
    private void CreateNotificationChannel(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "channel", NotificationManager.IMPORTANCE_HIGH);
            channel.setDescription("this is my channel");
            notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(channel);
        }
    }
    private void initIntents(){
        notificationIntent = new Intent(this, MainActivity.class);
        notificationIntent.setAction(Constants.MAIN_ACTION);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK
        | Intent.FLAG_ACTIVITY_CLEAR_TASK);
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