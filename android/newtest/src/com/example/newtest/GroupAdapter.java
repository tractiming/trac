package com.example.newtest;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class GroupAdapter extends BaseAdapter{

	private Workout parsedJson; 
	private Context context;
	
	public GroupAdapter(Workout workout, Context context) {
	 this.parsedJson = workout;
	 this.context = context;
	}
	
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return this.parsedJson.runners.size();
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return this.parsedJson.runners.get(position);
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
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_group, null);
		}
		
		
		
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJson.runners.get(position).name);
		
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text2);
		
		
		
		List<String[]> intervals = parsedJson.runners.get(position).interval;
		int ii = parsedJson.runners.get(position).interval.get(intervals.size() - 1).length - 1;
		
		textView2.setText(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[ii]);
		
		
		
		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	
}
