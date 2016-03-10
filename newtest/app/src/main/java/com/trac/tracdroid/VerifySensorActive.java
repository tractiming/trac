package com.trac.tracdroid;

import android.os.AsyncTask;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.IOException;

/**
 * Created by griffinkelly on 3/10/16.
 */
public class VerifySensorActive extends AsyncTask<String, Void, Results> {
    public StartDateInterface delegate = null;
    OkHttpClient client = new OkHttpClient();
    Gson gson = new Gson();
    @Override
    protected Results doInBackground(String... params) {
        // Attempt authentication against a network service.
        final String DEBUG_TAG = "Token Check";


        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(params[0])
                .get()
                .build();

        try {
            Response response = client.newCall(request).execute();
            Results resultsJSON = gson.fromJson(response.body().charStream(), Results.class);

            return resultsJSON;

        } catch (IOException e) {
            //Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
            return null;
        }

    }

    @Override
    protected void onPostExecute(Results success) {
        delegate.processFinish(success);


    }


}
