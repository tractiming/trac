package com.trac.tracdroid;

/**
 * Created by griffinkelly on 1/12/16.
 */

import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.Gson;
import com.squareup.okhttp.FormEncodingBuilder;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.TimeZone;


class GoogleAuthAsync extends AsyncTask<Void, Void, AuthToken> {
    public StringAsyncResponse delegate = null;

    private String url;
    private String gMail;
    private String googleUserID;
    private String id_token;
    private String gClient;
    private String tClient;
    Gson gson = new Gson();

    @Override
    protected void onCancelled() {
        Log.d("Canceled", "canceld");
    }

    GoogleAuthAsync(String url, String gMail, String googleUserID, String id_token, String gClient, String tClient) {
        this.url = url;
        this.gMail = gMail;
        this.googleUserID = googleUserID;
        this.id_token = id_token;
        this.gClient = gClient;
        this.tClient = tClient;

    }

    @Override
    protected AuthToken doInBackground(Void... params) {
        // Attempt authentication against a network service.
        final String DEBUG_TAG = "Token Check";
        final MediaType MEDIA_TYPE_MARKDOWN
                = MediaType.parse("application/json; charset=utf-8");

        JSONObject requestJSON = new JSONObject();
        try {

            requestJSON.put("id_token", id_token);
            requestJSON.put("google_client_id", gClient);
            requestJSON.put("trac_client_id", tClient);
            requestJSON.put("google_id", googleUserID);
            requestJSON.put("email",gMail);

        } catch (JSONException e) {
            e.printStackTrace();
        }

        RequestBody body = RequestBody.create(MEDIA_TYPE_MARKDOWN, requestJSON.toString());
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();

        Log.d(DEBUG_TAG, "Request Data: "+ request);
        try {
            Response response = client.newCall(request).execute();
            Log.d(DEBUG_TAG, "Response Data: "+ response);

            int codevar = response.code();
            Log.d(DEBUG_TAG, "Response Code: "+ codevar);

            Log.d(DEBUG_TAG, "Request Data: "+ request);

            if (codevar == 201) {
                AuthToken result = gson.fromJson(response.body().charStream(), AuthToken.class);
                return result;
            }
            else {
                return null;
            }

        } catch (IOException e) {
            Log.d(DEBUG_TAG, "IoException" + e.getMessage());
            return null;
        }

    }

    @Override
    protected void onPostExecute(final AuthToken success) {
        //delegate.processFinish(success);

        if (success == null) {
            Log.d("NULL", "WORK");
        } else {


            String access_token = success.access_token;
            delegate.processComplete(access_token);

        }
    }

}

