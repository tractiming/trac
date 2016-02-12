package com.trac.tracdroid;

import android.os.AsyncTask;
import android.util.Log;

import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

import java.io.IOException;

public class RaceStart extends AsyncTask<String, Void, Boolean> {
	public BooleanStartRace delegate = null;
	@Override
	protected Boolean doInBackground(String... params) {
		// Attempt authentication against a network service.
		final String DEBUG_TAG = "Token Check";
		//String pre_json = "id=1";
		RequestBody body = RequestBody.create(null, new byte[0]);
		Log.d(DEBUG_TAG, "Request Body "+ body);
		
		OkHttpClient client = new OkHttpClient();
		
		Request request = new Request.Builder()
        .url(params[0])
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
		    
		    if (codevar == 202) {
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
		delegate.booleanstartRace(success);

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



