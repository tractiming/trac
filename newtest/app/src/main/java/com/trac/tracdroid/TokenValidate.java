package com.trac.tracdroid;

/**
 * Created by griffinkelly on 2/25/16.
 */

import android.os.AsyncTask;

import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.IOException;



public class TokenValidate extends AsyncTask<String, Void, Boolean> {
    public BooleanAsyncResponse delegate = null;
    OkHttpClient client = new OkHttpClient();
    Gson gson = new Gson();

    private static final String DEBUG_TAG = "Token Check";
    public static final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
    @Override
    protected Boolean doInBackground(String... params) {
        // Attempt authentication against a network service.



        Request request = new Request.Builder()
                .url(params[0])
                .get()
                .build();

        //Log.d(DEBUG_TAG, "Request Data: "+ request);
        try {
            Response response = client.newCall(request).execute();
            // Log.d(DEBUG_TAG, "Response Data: "+ response);

            int codevar = response.code();
            // Log.d(DEBUG_TAG, "Response Code: "+ codevar);

            // Log.d(DEBUG_TAG, "Request Data: "+ request);
            //var = response.body().string();

            // Log.d(DEBUG_TAG, "VAR: "+ var);

            if (codevar == 200) {
                return true;
            }
            else {
                return false;
            }

        } catch (IOException e) {
            //Log.d(DEBUG_TAG, "IoException" + e.getMessage());
            return false;
        }

    }

    @Override
    protected void onPostExecute(final Boolean success) {
        delegate.processFinish(success);
    }

    @Override
    protected void onCancelled() {

    }
}