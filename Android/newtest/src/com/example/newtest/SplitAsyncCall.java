package com.example.newtest;

import java.io.IOException;
import java.util.ArrayList;

import android.os.AsyncTask;
import android.util.Log;

import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

public class SplitAsyncCall extends AsyncTask<Void, Void, Boolean> {
	public BooleanAsyncResponse delegate = null; 
	
    String url;
    ArrayList<String> checkArray;


    SplitAsyncCall(ArrayList<String> checkArray, String url) {
        this.url = url;
        this.checkArray = checkArray;

    }
	
	@Override
	protected Boolean doInBackground(Void... params) {
		// Attempt authentication against a network service.
		final String DEBUG_TAG = "Token Check";
		//String pre_json = "id=1";
		Log.d(DEBUG_TAG, "data in here??? "+ checkArray);
		
		RequestBody body = RequestBody.create(null, url);
		Log.d(DEBUG_TAG, "Request Body "+ body);
			
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

