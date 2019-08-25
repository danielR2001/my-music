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

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    channel = new MethodChannel(getFlutterView(), CHANNEL);
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
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
