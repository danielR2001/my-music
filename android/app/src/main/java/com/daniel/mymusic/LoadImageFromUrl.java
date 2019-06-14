package com.daniel.mymusic;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import android.util.Log;
public class LoadImageFromUrl extends AsyncTask<String, Void, Bitmap> {

    private Context context;
    private String title;
    private String artist;
    private String imageUrl;
    private boolean isPlaying;

    public LoadImageFromUrl(final String title, final String artist, String imageUrl, final Context context,
            boolean isPlaying) {
        super();
        this.context = context;
        this.title = title;
        this.artist = artist;
        this.imageUrl = imageUrl;
        this.isPlaying = isPlaying;
    }

    @Override
    protected Bitmap doInBackground(String... strings) {
        Log.d("load Image Thread","loading image...");
        if (!this.imageUrl.equals("")) {
            try {
                URL url = new URL(this.imageUrl);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                InputStream in = connection.getInputStream();
                Bitmap myBitmap = BitmapFactory.decodeStream(in);
                return myBitmap;
            } catch (MalformedURLException e) {
                e.printStackTrace();

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    @Override
    protected void onPostExecute(Bitmap result) {
        super.onPostExecute(result);
        if (result != null) {
            NotificationService.makeNotification(title, artist, result, context, isPlaying,imageUrl);
        } else {
            NotificationService.makeNotification(title, artist, null, context, isPlaying,imageUrl);
        }
    }
}
