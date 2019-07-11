package com.daniel.mymusic;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.ActivityManager;
import android.content.Context;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.graphics.Bitmap;
import android.graphics.Color;

import androidx.palette.graphics.Palette;

import java.text.Normalizer;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL1 = "flutter.native/notifications";
  private static final String CHANNEL2 = "flutter.native/internet";
  private static final String CHANNEL3 = "flutter.native/unaccent";
  private static final String CHANNEL4 = "flutter.native/dominantColor";
  public static MethodChannel channel1;
  public static MethodChannel channel2;
  public static MethodChannel channel3;
  public static MethodChannel channel4;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    channel1 = new MethodChannel(getFlutterView(), CHANNEL1);
    channel1.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startService")) {
          StartService();
          result.success(true);
        } else if (call.method.equals("makeNotification")) {
          String title = call.argument("title");
          String artist = call.argument("artist");
          String imageUrl = call.argument("imageUrl");
          boolean isPlaying = call.argument("isPlaying");
          String localPath = call.argument("localPath");
          boolean loadImage = call.argument("loadImage");
          if (loadImage) {
            Bitmap bitmap;
            try {
              bitmap = new LoadImageFromUrl(title, artist, imageUrl, getApplicationContext(), isPlaying, localPath)
                  .execute().get();
            } catch (Exception e) {
              bitmap = null;
            }
            if (bitmap != null) {
              NotificationService.makeNotification(title, artist, bitmap, getApplicationContext(), isPlaying, imageUrl);
            } else {
              NotificationService.makeNotification(title, artist, null, getApplicationContext(), isPlaying, imageUrl);
            }
            result.success(true);
          } else {
            NotificationService.makeNotification(title, artist, NotificationService.imageBitmap,
                getApplicationContext(), isPlaying, imageUrl);
          }
        }
      }
    });
    channel2 = new MethodChannel(getFlutterView(), CHANNEL2);
    channel2.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("ActivateInternetConnectionReceiver")) {
          BroadcastReceiver mNetworkReceiver = new InternetConnectionBroadcastReceiver();
          registerReceiver(mNetworkReceiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
        } else if (call.method.equals("internetConnectionCheck")) {
          result.success(InternetConnectionBroadcastReceiver.networkAvailable);
        } else if (call.method.equals("DisposeInternetConnectionReceiver")) {
          BroadcastReceiver mNetworkReceiver = new InternetConnectionBroadcastReceiver();
          unregisterReceiver(mNetworkReceiver);
        }
      }
    });
    channel3 = new MethodChannel(getFlutterView(), CHANNEL3);
    channel3.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("unaccent")) {
          String str = call.argument("string");
          result.success(unaccent(str));
        }
      }
    });
    channel4 = new MethodChannel(getFlutterView(), CHANNEL4);
    channel4.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getDominantColor")) {
          String imagePath = call.argument("imagePath");
          boolean isLocal = call.argument("isLocal");
          Bitmap bitmap;
          if (isLocal) {
            try {
              bitmap = new LoadImageFromUrl(null, imagePath).execute().get();
            } catch (Exception e) {
              bitmap = null;
            }
          } else {
            try {
              bitmap = new LoadImageFromUrl(imagePath, null).execute().get();
            } catch (Exception e) {
              bitmap = null;
            }
          }
          if (bitmap != null) {;
            result.success(getImageDominantColor(bitmap));
          } else {
            result.success(null);
          }
        }
      }
    });
  }

  private String unaccent(String src) {
    return Normalizer.normalize(src, Normalizer.Form.NFD).replaceAll("[^\\p{ASCII}]", "");
  }

  private void StartService() {
    Intent serviceIntent = new Intent(getApplicationContext(), NotificationService.class);
    serviceIntent.setAction(Constants.STARTFOREGROUND_ACTION);
    startService(serviceIntent);
  }

  public static String getImageDominantColor(Bitmap bitmap) {
    int paletteDominantColor;
    String hex = "";
    Palette palette = Palette.from(bitmap).generate();
    paletteDominantColor = palette.getVibrantColor(0);
    if (paletteDominantColor == 0) {
      paletteDominantColor = palette.getDominantColor(0);
    }
    if (paletteDominantColor != 0) {
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        Color color = Color.valueOf(paletteDominantColor);
        int red = (int) (color.red() * 255);
        int green = (int) (color.green() * 255);
        int blue = (int) (color.blue() * 255);
        hex = String.format("#%02x%02x%02x", red, green, blue);
      } else {
        return null;
      }
    } else {
      return null;
    }
    return hex;
  }

}
