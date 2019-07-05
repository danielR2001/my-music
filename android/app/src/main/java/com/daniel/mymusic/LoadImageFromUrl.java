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
import java.io.File;

public class LoadImageFromUrl extends AsyncTask<String, Void, Bitmap> {

    private Context context;
    private String title;
    private String artist;
    private String imageUrl;
    private boolean isPlaying;
    private String localPath;

    public LoadImageFromUrl(final String title, final String artist, String imageUrl, final Context context,
            boolean isPlaying, String localPath) {
        super();
        this.context = context;
        this.title = title;
        this.artist = artist;
        this.imageUrl = imageUrl;
        this.isPlaying = isPlaying;
        this.localPath = localPath;
    }

    public LoadImageFromUrl(String imageUrl) {
        super();
        this.imageUrl = imageUrl;
    }

    @Override
    protected Bitmap doInBackground(String... strings) {
        Log.d("load Image Thread", "loading image...");
        if (localPath != null) {
            if (new File(localPath).exists()) {
                return BitmapFactory.decodeFile(localPath);
            } else {
                if (!this.imageUrl.equals("")) {
                    try {
                        URL url = new URL(this.imageUrl);
                        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                        connection.setDoInput(true);
                        connection.connect();
                        InputStream in = connection.getInputStream();
                        return BitmapFactory.decodeStream(in);
                    } catch (MalformedURLException e) {
                        Log.d("load Image Thread", "Failed loading image!!!");

                    } catch (IOException e) {
                        Log.d("load Image Thread", "Failed loading image!!!");
                    }
                }
            }
        } else {
            try {
                URL url = new URL(this.imageUrl);
                HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                connection.setDoInput(true);
                connection.connect();
                InputStream in = connection.getInputStream();
                return BitmapFactory.decodeStream(in);
            } catch (MalformedURLException e) {
                Log.d("load Image Thread", "Failed loading image!!!");

            } catch (IOException e) {
                Log.d("load Image Thread", "Failed loading image!!!");
            }
        }
        return null;
    }
}
