package com.example.newtest;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class CalendarAdapter extends BaseAdapter {
	//Adapter specifically for CalendarActivity.class
	private ArrayList<Results> parsedJson; 
	private List<Results> parsedJsonList = null;
	private Context context;
	
	public CalendarAdapter(List<Results> parsedJsonList, Context context) {
	this.parsedJsonList = parsedJsonList;
	 this.parsedJson = new ArrayList<Results>();
	 this.parsedJson.addAll(parsedJsonList);
	 this.context = context;
	}
	
	
	@Override
	public int getCount() {
		// dynamically find size of array
		return parsedJsonList.size();
	}

	@Override
	public Object getItem(int position) {
		// when clicked determine which position was clicked
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
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_calendar, null);
		}
		
		
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJsonList.get(position).name);
		//find date adn display it, only show first 10 characters of the date--avoiding the timestamp
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text3);
		textView2.setText(parsedJsonList.get(position).startTime.substring(0,10));
		

		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	public void getFilter(String charText) {
		charText = charText.toLowerCase(Locale.getDefault());
		parsedJsonList.clear();
				if (charText.length() == 0) {
					parsedJsonList.addAll(parsedJson);
		} 
		else 
		{
			for (Results wp : parsedJson) 
			{
				if (wp.name.toLowerCase(Locale.getDefault()).contains(charText)) 
				{
					parsedJsonList.add(wp);
				}
			}
		}
		notifyDataSetChanged();
	}

	
	
}
