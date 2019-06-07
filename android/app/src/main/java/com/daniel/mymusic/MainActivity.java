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

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutter.native/helper";
  private final String CHANNEL_ID = "channel";
  public static MethodChannel channel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    channel = new MethodChannel(getFlutterView(), CHANNEL);
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("makeNotification")) {
          String title = call.argument("title");
          String artist = call.argument("artist");
          String imageUrl = call.argument("imageUrl");
          boolean isPlaying = call.argument("isPlaying");
          new LoadImageFromUrl(title,artist,imageUrl,getApplicationContext(),isPlaying).execute();
          result.success(true);
        } else if (call.method.equals("startService")) {
          StartService();
          result.success(true);
        }
      }
    });
  }

  private void StartService() {
    Intent serviceIntent = new Intent(getApplicationContext(), NotificationService.class);
    serviceIntent.setAction(Constants.STARTFOREGROUND_ACTION);
    startService(serviceIntent);
  }
}
