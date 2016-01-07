package com.example.newtest;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

import com.squareup.okhttp.FormEncodingBuilder;
import com.squareup.okhttp.MediaType;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.RequestBody;
import com.squareup.okhttp.Response;

public class SplitAsyncCall extends AsyncTask<Void, Void, Boolean> {
	//public BooleanAsyncResponse delegate = null; 
	
    String url;
    ArrayList<String> checkArray;
	private String idPosition;
	
    @Override
    protected void onCancelled() {
        Log.d("Canceled", "canceld");
    }

    SplitAsyncCall(ArrayList<String> checkArray, String url, String idPosition) {
        this.url = url;
        this.checkArray = checkArray;
        this.idPosition = idPosition;

    }
	
	@Override
	protected Boolean doInBackground(Void... params) {
		// Attempt authentication against a network service.
		final String DEBUG_TAG = "Token Check";
		final MediaType MEDIA_TYPE_MARKDOWN
	      = MediaType.parse("application/json; charset=utf-8");
		
		//String pre_json = "id=1";
		Log.d(DEBUG_TAG, "data in here??? "+ checkArray);
		SimpleDateFormat dateFormatGmt = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
		dateFormatGmt.setTimeZone(TimeZone.getTimeZone("GMT"));
		final String utcTime = dateFormatGmt.format(new Date());
		
		String[] sessionID = new String[] {idPosition};
		
		JSONObject parent = new JSONObject();
		JSONArray masterArray = new JSONArray();
		for (int i=0; i< checkArray.size();i++){
			JSONArray jsonArray = new JSONArray();
			jsonArray.put(idPosition);
			JSONObject athleteJSON = new JSONObject();
			try {
				athleteJSON.put("athlete", checkArray.get(i));
				athleteJSON.put("sessions", jsonArray);
				athleteJSON.put("tag",JSONObject.NULL);
				athleteJSON.put("reader", JSONObject.NULL);
				athleteJSON.put("time", utcTime);
				
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			//jsonArray.put(athleteJSON);

			masterArray.put(athleteJSON);
		}
		try {
			parent.put("s",masterArray);
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		
		RequestBody body = RequestBody.create(MEDIA_TYPE_MARKDOWN, masterArray.toString());
		Log.d(DEBUG_TAG, "Request Body "+ body);
		String tempArray = masterArray.toString();
		tempArray = tempArray.replace("\\/", "/");
		Log.d("JSON",tempArray);
		
		OkHttpClient client = new OkHttpClient();
		
		 RequestBody formBody = new FormEncodingBuilder()
	        .add("s", tempArray)
	        .build();
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
		//delegate.processFinish(success);

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

