package com.example.newtest;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class CalendarAdapter extends BaseAdapter {

	private ArrayList<Results> parsedJson; 
	private Context context;
	
	public CalendarAdapter(ArrayList<Results> workout, Context context) {
	 this.parsedJson = workout;
	 this.context = context;
	}
	
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return this.parsedJson.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return this.parsedJson.get(position);
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
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
		textView.setText(parsedJson.get(position).name);
		
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text3);
		textView2.setText(parsedJson.get(position).startTime.substring(0,10));
		

		
		//Fill that view with data
		//Return that view
		return convertView;
	}

	
	
}
