package com.daniel.mymusic;

import android.content.Intent;
import android.content.Context;
import android.content.BroadcastReceiver;

public class ActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Constants.PREV_ACTION)) {
            MainActivity.channel1.invokeMethod("prevSong", null);
        } else if (intent.getAction().equals(Constants.PLAY_ACTION)) {
            MainActivity.channel1.invokeMethod("playOrPause", null);
        } else if (intent.getAction().equals(Constants.NEXT_ACTION)) {
            MainActivity.channel1.invokeMethod("nextSong", null);
        }
    }
}