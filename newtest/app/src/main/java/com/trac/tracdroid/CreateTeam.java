package com.trac.tracdroid;

import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.Gson;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Created by griffinkelly on 1/14/16.
 */
public class CreateTeam extends AsyncTask<Void, Void, Boolean> {
    public CreateTeamCallback delegate = null;

    private static final String DEBUG_TAG = "Token Check";
    public static final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
    OkHttpClient client = new OkHttpClient();
    Gson gson = new Gson();
    private String url;

    private String team;

    public CreateTeam(String url, String team) {

        this.url = url;
        this.team = team;
    }

    @Override
    protected Boolean doInBackground(Void... params) {
        // Attempt authentication against a network service.
        final MediaType MEDIA_TYPE_MARKDOWN
                = MediaType.parse("application/json; charset=utf-8");
        boolean trueTeam = true;
        JSONObject athleteJSON = new JSONObject();
        try {
            athleteJSON.put("name", team);
            athleteJSON.put("primary_team", trueTeam);

        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        RequestBody body = RequestBody.create(MEDIA_TYPE_MARKDOWN,athleteJSON.toString());


        Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();

        Log.d(DEBUG_TAG, "Request Data: " + request);
        try {
            Response response = client.newCall(request).execute();
            Log.d(DEBUG_TAG, "Response Data: "+ response);

            int codevar = response.code();
            Log.d(DEBUG_TAG, "Response Code: "+ codevar);

            Log.d(DEBUG_TAG, "Request Data: "+ request);
            String var = response.body().string();

            Log.d(DEBUG_TAG, "VAR: "+ var);

            if (codevar == 201) {
                return true;
            }
            else {
                return false;
            }

        } catch (IOException e) {
            Log.d(DEBUG_TAG, "IoException" + e.getMessage());
            return null;
        }

    }

    @Override
    protected void onPostExecute(final Boolean success) {
        delegate.teamFinish(success);

        if (success == null){
            Log.d("NULL","WORK");
        }
        else if (success) {
            //go to calendar page
            Log.d("HE","WORK");

        } else {
            //It it doesnt work segue to login page
            Log.d("NOPE","NO WORK");


        }
    }


}