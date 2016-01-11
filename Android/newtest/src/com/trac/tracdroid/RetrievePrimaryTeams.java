package com.trac.tracdroid;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import android.os.AsyncTask;
import android.util.Log;
import android.view.View;

import com.google.gson.Gson;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

class RetrievePrimaryTeams extends AsyncTask<String, Void, ArrayList<Teams>> {
	public StringAsyncResponse delegate = null; 
	
	  OkHttpClient client = new OkHttpClient();
	  Gson gson = new Gson();
	  private static final String DEBUG_TAG = "Debug";

		@Override
		protected ArrayList<Teams> doInBackground(String... params) {
			Request request = new Request.Builder()
	        .url(params[0])
	        .build();
			try {
				   Response response = client.newCall(request).execute();
				   Log.d("Reponse", response.body().toString());
				   Teams[] preFullyParsed = gson.fromJson(response.body().charStream(), Teams[].class);
				   System.out.println(preFullyParsed);
				   
				   ArrayList<Teams> dataList = new ArrayList<Teams>(Arrays.asList(preFullyParsed));

			    return dataList;
			    
			} catch (IOException e) {
				//Log.d(DEBUG_TAG, "this is griffins fault now" + e.getMessage());
				return null;
			}
		}
		
		@Override
		protected void onPostExecute(ArrayList<Teams> result) {
			Log.d("Team Async #:", result.get(0).id);
			delegate.processComplete(result.get(0).id);

		}
  }
