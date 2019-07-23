package com.daniel.mymusic;

import android.content.Intent;
import android.content.Context;
import android.content.BroadcastReceiver;

import android.util.Log;

public class ActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        switch(intent.getAction()){
            case Constants.PREVIOUS_ACTION:{
                MainActivity.channel.invokeMethod("prevSong", null);
                break;
            }
            case Constants.PLAY_OR_PAUSE_ACTION:{
                MainActivity.channel.invokeMethod("playOrPause", null);
                break;
            }
            case Constants.NEXT_ACTION:{
                MainActivity.channel.invokeMethod("nextSong", null);
                break;
            }
        }
    }
}