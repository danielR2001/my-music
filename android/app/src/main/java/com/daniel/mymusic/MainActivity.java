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
  private static final String CHANNEL = "flutter.native/helper";
  private final String CHANNEL_ID = "channel";
  public static MethodChannel channel;
  private static LoadImageFromUrl loadImageFromUrl;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    channel = new MethodChannel(getFlutterView(), CHANNEL);
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
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
          loadImageFromUrl = new LoadImageFromUrl(title, artist, imageUrl, getApplicationContext(), isPlaying,localPath);
          loadImageFromUrl.execute();
          result.success(true);
        } else if (call.method.equals("removeNotification")) {
          NotificationManager mNotificationManager = (NotificationManager) getSystemService(
              Context.NOTIFICATION_SERVICE);
          mNotificationManager.cancel(0);
        } else if (call.method.equals("unaccent")) {
          String str = call.argument("string");
          result.success(unaccent(str));
        } else if (call.method.equals("internetConnectioActivateReceive")) {
          BroadcastReceiver mNetworkReceiver = new InternetConnectionBroadcastReceiver();
          registerReceiver(mNetworkReceiver, new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION));
        } else if (call.method.equals("internetConnectioCheck")) {
          if (InternetConnectionBroadcastReceiver.networkAvailable) {
            result.success(true);
          } else {
            result.success(false);
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
}
