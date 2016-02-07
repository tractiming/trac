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


  class CreateAthleteAsyncTask extends AsyncTask<Void, Void, Boolean> {
	  public BooleanAsyncResponse delegate = null; 
	  
	  private static final String DEBUG_TAG = "Token Check";
		 public static final MediaType JSON = MediaType.parse("application/x-www-form-urlencoded; charset=utf-8");
			OkHttpClient client = new OkHttpClient();
			Gson gson = new Gson();
			private String url;
			private String first_name;
			private String last_name;
			private String tagId;
			private String team;
			
		public CreateAthleteAsyncTask(String url, String first_name,
					String last_name, String tagId, String primaryTeam) {
			
		        this.url = url;
		        this.first_name = first_name;
		        this.last_name = last_name;
		        this.tagId = tagId;
		        this.team = primaryTeam;
			}

		@Override
		protected Boolean doInBackground(Void... params) {
			// Attempt authentication against a network service.
			final MediaType MEDIA_TYPE_MARKDOWN
		      = MediaType.parse("application/json; charset=utf-8");
			JSONObject athleteJSON = new JSONObject();
			if (tagId.isEmpty())
			{
				try {
					athleteJSON.put("first_name", first_name);
					athleteJSON.put("last_name", last_name);
					athleteJSON.put("team", team);

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			else {
				try {
					athleteJSON.put("first_name", first_name);
					athleteJSON.put("last_name", last_name);
					athleteJSON.put("tag", tagId);
					athleteJSON.put("team", team);

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			RequestBody body = RequestBody.create(MEDIA_TYPE_MARKDOWN,athleteJSON.toString());
			
			
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