package com.daniel.mymusic;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.io.File;

public class LoadImageFromUrl extends AsyncTask<String, Void, Bitmap> {

    private Context context;
    private String title;
    private String artist;
    private String imageUrl;
    private boolean isPlaying;
    private String localPath;
    private AsyncResponse delegate = null;// Call back interface

    public LoadImageFromUrl(final String title, final String artist, String imageUrl, final Context context,
            boolean isPlaying, String localPath, AsyncResponse asyncResponse) {
        super();
        this.context = context;
        this.title = title;
        this.artist = artist;
        this.imageUrl = imageUrl;
        this.isPlaying = isPlaying;
        this.localPath = localPath;
        this.delegate = asyncResponse;
    }

    public LoadImageFromUrl(String imageUrl, String localPath, AsyncResponse asyncResponse) {
        super();
        this.imageUrl = imageUrl;
        this.localPath = localPath;
        this.delegate = asyncResponse;
    }

    @Override
    protected Bitmap doInBackground(String... strings) {
        Log.d("load Image Thread", "loading image...");
        if (this.localPath != null) {
            if (new File(localPath).exists()) {
                return BitmapFactory.decodeFile(this.localPath);
            } else {
                if (this.imageUrl != null && !this.imageUrl.equals("")) {
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

    @Override
    protected void onPostExecute(Bitmap bitmap) {
        super.onPostExecute(bitmap);
        delegate.processFinish(bitmap);
    }
}
