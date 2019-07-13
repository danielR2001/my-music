package com.daniel.mymusic;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel.Result;

public class InternetConnectionBroadcastReceiver extends BroadcastReceiver {

    public static boolean networkAvailable;

    @Override
    public void onReceive(final Context context, final Intent intent) {
        try {
            if (isOnline(context) && !networkAvailable) {
                networkAvailable = true;
                MainActivity.channel2.invokeMethod("comebackToOnlineMode", null, new Result() {
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
                Log.e("Connection status", "Online");
            } else {
                if (!networkAvailable) {
                    networkAvailable = false;
                    Log.e("Connection status", "Offline ");
                }
            }
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    private boolean isOnline(Context context) {
        try {
            ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo netInfo = cm.getActiveNetworkInfo();
            // should check null because in airplane mode it will be null
            return (netInfo != null && netInfo.isConnected());
        } catch (NullPointerException e) {
            return false;
        }
    }
}
