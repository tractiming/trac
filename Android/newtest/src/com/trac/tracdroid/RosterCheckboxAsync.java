package com.trac.tracdroid;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.squareup.okhttp.FormEncodingBuilder;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

public class RosterCheckboxAsync extends AsyncTask<Void, Void, Boolean> {
	public BooleanAsyncResponse delegate = null; 
	
    String url;
    ArrayList<String> checkArray;
	
    @Override
    protected void onCancelled() {
        Log.d("Canceled", "canceld");
    }

    RosterCheckboxAsync(ArrayList<String> checkArray, String url) {
        this.url = url;
        this.checkArray = checkArray;
        
    }
	
	@Override
	protected Boolean doInBackground(Void... params) {
		// Attempt authentication against a network service.
		final String DEBUG_TAG = "Token Check";
		final MediaType MEDIA_TYPE_MARKDOWN
	      = MediaType.parse("application/json; charset=utf-8");
		
			Gson gson = new GsonBuilder().create();
			JSONArray jsArray = new JSONArray(checkArray);
			JSONObject athleteJSON = new JSONObject();
			try {
				athleteJSON.put("athletes", jsArray);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		
		RequestBody body = RequestBody.create(MEDIA_TYPE_MARKDOWN, athleteJSON.toString());	
		Log.d("JSON",athleteJSON.toString());
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
		    String var = response.body().string();
		    
		    Log.d(DEBUG_TAG, "VAR: "+ var);
		    
		    if (codevar == 200) {
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
		delegate.processFinish(success);

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
