package com.example.newtest;

import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

public class WorkoutListActivity extends ListActivity {

	 @Override
     
		 public void onCreate(Bundle icicle) {
			    super.onCreate(icicle);
			   
			    String[] values = new String[] { "Android", "iPhone", "WindowsMobile",
			        "Blackberry", "WebOS", "Ubuntu", "Windows7", "Max OS X",
			        "Linux", "OS/2", "Android", "iPhone", "WindowsMobile",
			        "Blackberry", "WebOS", "Ubuntu", "Windows7", "Max OS X",
			        "Linux", "OS/2" };
			    ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
			        android.R.layout.simple_list_item_1, values);
			    setListAdapter(adapter);
			  }

			  @Override
			  protected void onListItemClick(ListView l, View v, int position, long id) {
			    String item = (String) getListAdapter().getItem(position);
			    //Toast.makeText(this, item + " selected", Toast.LENGTH_LONG).show();
			    startActivity(new Intent(WorkoutListActivity.this, MainActivity.class));
			  }

	
}
