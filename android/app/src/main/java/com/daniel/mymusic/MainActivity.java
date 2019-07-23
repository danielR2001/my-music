package com.daniel.mymusic;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.util.Log;

import androidx.palette.graphics.Palette;

import java.text.Normalizer;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL1 = "flutter.native/notifications";
  private static final String CHANNEL2 = "flutter.native/dominantColor";
  public static MethodChannel channel1;
  public static MethodChannel channel2;
  private MediaNotificationManager mediaNotificationManager ;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    channel1 = new MethodChannel(getFlutterView(), CHANNEL1);
    channel1.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startService")) {
          startService(new Intent(getApplicationContext(), AppCloseDetectorService.class));
          mediaNotificationManager = new MediaNotificationManager(getApplicationContext());
          result.success(true);
        } else if (call.method.equals("makeNotification")) {
          String title = call.argument("title");
          String artist = call.argument("artist");
          String imageUrl = call.argument("imageUrl");
          boolean isPlaying = call.argument("isPlaying");
          String localPath = call.argument("localPath");
          boolean loadImage = call.argument("loadImage");
          if (loadImage) {
            try {
              LoadImageFromUrl loadImageFromUrl = new LoadImageFromUrl(title, artist, imageUrl, getApplicationContext(), isPlaying, localPath, new AsyncResponse() { 
                @Override 
                public void processFinish(Bitmap bitmap) { 
                  if(bitmap !=null){
                    mediaNotificationManager.makeNotification(title, artist, bitmap, isPlaying, imageUrl, true);
                    Log.d("load Image Thread", "image loading success");
                  }else{
                    mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, true);
                    Log.d("load Image Thread", "image loading failed");
                  }
                } 
              }); 
              loadImageFromUrl.execute();
            } catch (Exception e) {
              mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, true);
            }
          } else {
            mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, false);
          }
        }else if (call.method.equals("removeNotification")) {
          NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
          mNotificationManager.cancel(0);
        }
      }
    });
    
    channel2 = new MethodChannel(getFlutterView(), CHANNEL2);
    channel2.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getDominantColor")) {
          String imagePath = call.argument("imagePath");
          boolean isLocal = call.argument("isLocal");
          if (isLocal) {
            try {
              new LoadImageFromUrl(null, imagePath, new AsyncResponse() { 
                @Override 
                public void processFinish(Bitmap bitmap) { 
                  if(bitmap !=null){
                    result.success(getImageDominantColor(bitmap));
                    Log.d("load Image Thread", "image loading success");
                  }else{
                    result.success(null);
                    Log.d("load Image Thread", "image loading failed");
                  }
                } 
              }).execute(); 
            } catch (Exception e) {
              result.success(null);
            }
          } else {
            try {
              new LoadImageFromUrl(imagePath, null, new AsyncResponse() { 
                @Override 
                public void processFinish(Bitmap bitmap) { 
                  if(bitmap !=null){
                    result.success(getImageDominantColor(bitmap));
                    Log.d("load Image Thread", "image loading success");
                  }else{
                    result.success(null);
                    Log.d("load Image Thread", "image loading failed");
                  }
                } 
              }).execute();
            } catch (Exception e) {
              result.success(null);
            }
          }
        }
      }
    });
  }

  public static String getImageDominantColor(Bitmap bitmap) {
    int paletteDominantColor;
    String hex = "";
    Palette palette = Palette.from(bitmap).generate();
    paletteDominantColor = palette.getLightVibrantColor(0);
    if(paletteDominantColor == 0){
      paletteDominantColor = palette.getLightMutedColor(0);
    }
    if(paletteDominantColor == 0){
      paletteDominantColor = palette.getVibrantColor(0);
    }
    if (paletteDominantColor == 0) {
      paletteDominantColor = palette.getDominantColor(0);
    }
    if (paletteDominantColor != 0 && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        Color color = Color.valueOf(paletteDominantColor);
        int red = (int) (color.red() * 255);
        int green = (int) (color.green() * 255);
        int blue = (int) (color.blue() * 255);
        hex = String.format("#%02x%02x%02x", red, green, blue);
        return hex;
    } else {
      return null;
    }
  }

}
