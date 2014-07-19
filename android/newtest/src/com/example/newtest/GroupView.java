package com.example.newtest;

import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.IOException;

import android.support.v4.app.Fragment;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;



public class GroupView extends Fragment{

	private static final String DEBUG_TAG = "griffinSucks";
	//this field holds a reference to text field
	private TextView mTextView;
	/**
	 * Returns a new instance of this fragment.
	 */
	
	public GroupView() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_group_view, container,
				false);
		mTextView = (TextView) rootView.findViewById(R.id.group_text_view);
		new AsyncServiceCall().execute("http://76.12.155.219/trac/json/test.json");
		
		Log.d(DEBUG_TAG, "onCreateView CALLED");
		return rootView;
	}

	  OkHttpClient client = new OkHttpClient();

	 
	  
	  private class AsyncServiceCall extends AsyncTask<String, Void, String> {

		@Override
		protected String doInBackground(String... params) {
			Request request = new Request.Builder()
	        .url(params[0])
	        .build();
			try {
			    Response response = client.newCall(request).execute();
			    return response.body().string();
			} catch (IOException e) {
				Log.d(DEBUG_TAG, "this is griffins fault now " + e.getMessage());
				return "";
			}
		}
		
		@Override
		protected void onPostExecute(String result) {
			Log.d(DEBUG_TAG, result);
			//set result to show on screen
			mTextView.setText(result);
		}
		  
	  }

	 
	}