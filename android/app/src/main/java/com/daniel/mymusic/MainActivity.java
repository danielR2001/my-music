package com.daniel.mymusic;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Intent;
import android.app.PendingIntent;
import android.util.Log;

import android.app.ActivityManager;
import android.content.Context;
import java.text.Normalizer;

import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.net.ConnectivityManager;

import android.app.NotificationManager;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL1 = "flutter.native/notifications";
  private static final String CHANNEL2 = "flutter.native/internet";
  private static final String CHANNEL3 = "flutter.native/unaccent";
  public static MethodChannel channel1;
  public static MethodChannel channel2;
  public static MethodChannel channel3;

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
          boolean dontLoadImage = call.argument("dontLoadImage");
          if (dontLoadImage) {
            NotificationService.makeNotification(title, artist, NotificationService.imageBitmap,
                getApplicationContext(), isPlaying, imageUrl);
          } else {
            new LoadImageFromUrl(title, artist, imageUrl, getApplicationContext(), isPlaying, localPath).execute();
          }
          result.success(true);
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
  }

  private String unaccent(String src) {
    return Normalizer.normalize(src, Normalizer.Form.NFD).replaceAll("[^\\p{ASCII}]", "");
  }

  private void StartService() {
    Intent serviceIntent = new Intent(getApplicationContext(), NotificationService.class);
    serviceIntent.setAction(Constants.STARTFOREGROUND_ACTION);
    startService(serviceIntent);
  }
}
