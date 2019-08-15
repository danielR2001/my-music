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
  private static final String CHANNEL = "com.daniel/myMusic";
  public static MethodChannel channel;
  private MediaNotificationManager mediaNotificationManager;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    channel = new MethodChannel(getFlutterView(), CHANNEL);
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
        case "startService": {
          startService(new Intent(getApplicationContext(), AppCloseDetectorService.class));
          mediaNotificationManager = new MediaNotificationManager(getApplicationContext());
          break;
        }
        case "makeNotification": {
          String title = call.argument("title");
          String artist = call.argument("artist");
          String imageUrl = call.argument("imageUrl");
          boolean isPlaying = call.argument("isPlaying");
          boolean isLocal = call.argument("isLocal");
          boolean loadImage = call.argument("loadImage");
          if (loadImage) {
            try {
              new LoadImageFromUrl(imageUrl, isLocal, new AsyncResponse() {
                @Override
                public void processFinish(Bitmap bitmap) {
                  if (bitmap != null) {
                    mediaNotificationManager.makeNotification(title, artist, bitmap, isPlaying, imageUrl, true);
                    Log.d("load Image Thread", "image loading success");
                  } else {
                    mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, true);
                    Log.d("load Image Thread", "image loading failed");
                  }
                }
              }).execute();
            } catch (Exception e) {
              mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, true);
            }
          } else {
            mediaNotificationManager.makeNotification(title, artist, null, isPlaying, imageUrl, false);
          }
          break;
        }
        case "removeNotification": {
          NotificationManager mNotificationManager = (NotificationManager) getSystemService(
              Context.NOTIFICATION_SERVICE);
          mNotificationManager.cancel(0);
          break;
        }
        case "getDominantColor": {
          String imagePath = call.argument("imagePath");
          boolean isLocal = call.argument("isLocal");
          try {
            new LoadImageFromUrl(imagePath, isLocal, new AsyncResponse() {
              @Override
              public void processFinish(Bitmap bitmap) {
                if (bitmap != null) {
                  result.success(getImageDominantColor(bitmap));
                  Log.d("load Image Thread", "image loading success");
                } else {
                  result.success(null);
                  Log.d("load Image Thread", "image loading failed");
                }
              }
            }).execute();
          } catch (Exception e) {
            result.success(null);
          }

          break;
        }
        }
      }
    });
  }

  private String getImageDominantColor(Bitmap bitmap) {
    int paletteDominantColor;
    String hex = "";
    Palette palette = Palette.from(bitmap).generate();
    paletteDominantColor = palette.getLightVibrantColor(0);
    if (paletteDominantColor == 0) {
      paletteDominantColor = palette.getLightMutedColor(0);
    }
    if (paletteDominantColor == 0) {
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
