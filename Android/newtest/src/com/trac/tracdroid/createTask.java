package com.trac.tracdroid;

import java.io.IOException;

import android.os.AsyncTask;
import android.util.Log;

import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

public class createTask extends AsyncTask<String, Void, Boolean> {
	public BooleanAsyncResponse delegate = null; 
	@Override
	protected Boolean doInBackground(String... params) {
		// Attempt authentication against a network service.
		final String DEBUG_TAG = "Token Check";
		//String pre_json = "id=1";
		Log.d(DEBUG_TAG, "Pre JSON Data: "+ params[0]);
		 final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
		
		RequestBody body = RequestBody.create(JSON, params[1]);
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



