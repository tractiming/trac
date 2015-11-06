package com.example.newtest;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class RosterAdapter extends BaseAdapter {
	//Adapter specifically for CalendarActivity.class
	private ArrayList<RosterJson> parsedJson; 
	private List<RosterJson> parsedJsonList = null;
	private Context context;


	
	public RosterAdapter(List<RosterJson> parsedJsonList, Context context) {
	 this.parsedJsonList = parsedJsonList;
	 this.parsedJson = new ArrayList<RosterJson>();
	 this.parsedJson.addAll(parsedJsonList);
	 this.context = context;
	}
	
	
	public void add(List<RosterJson> result){
        if (result.size() > 0) {
        	this.parsedJsonList.addAll(result);
        	//Log.d("Size of Array",Integer.toString(result.size()));
		
        	this.getCount();
		
        	notifyDataSetChanged();
			this.parsedJson = new ArrayList<RosterJson>();
			this.parsedJson.addAll(parsedJsonList);
			//Log.d("Enters","Add SubClass");
        }
        else{
        	
        	//Log.d("Enters","DO Nothing");
        }
		
		
		//return parsedJsonList;
	}
	
	@Override
	public int getCount() {
		// dynamically find size of array
		//Log.d("GetCount",Integer.toString(parsedJsonList.size()));
		return parsedJsonList.size();
	}

	@Override
	public Object getItem(int position) {
		// when clicked determine which position was clicked
		//Log.d("getItem","Fired");
		return parsedJsonList.get(position);
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return position;
	}


	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		//Inflate a view to show peoples names
		if (convertView == null) {
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_roster, null);
		}
		
		
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJsonList.get(position).first +" "+  parsedJsonList.get(position).last);
		//find date adn display it, only show first 10 characters of the date--avoiding the timestamp
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text3);
		textView2.setText(parsedJsonList.get(position).id_str);
		

		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	public void getFilter(String charText) {
		charText = charText.toLowerCase(Locale.getDefault());
		Log.d("Hello","");
		parsedJsonList.clear();
		if (charText.length() == 0) {
			Log.d("Hello","");
			parsedJsonList.addAll(parsedJson);
		} 
		else 
		{
			Log.d("Hello","");
			for (RosterJson wp : parsedJson) 
			{
				if (wp.first.toLowerCase(Locale.getDefault()).contains(charText)) 
				{
					parsedJsonList.add(wp);
				}
			}
		}
		notifyDataSetChanged();
	}

	
	
	
}

