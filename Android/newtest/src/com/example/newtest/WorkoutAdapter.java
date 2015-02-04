package com.example.newtest;

import java.util.List;

import android.content.Context;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class WorkoutAdapter extends BaseAdapter{

	private Workout parsedJson; 
	private Context context;
	
	
	public WorkoutAdapter(Workout workout, Context context) {
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
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_workout, null);
		}
		
		
		//Show the athletes name
		TextView textView =(TextView) convertView.findViewById(R.id.list_text_workout);
		textView.setText(parsedJson.runners.get(position).name);
		Log.d("Debug",parsedJson.runners.get(position).name);
		
		//TextView textView3 = (TextView) convertView.findViewById(R.id.dropdown);
		//List<String[]> intervals = parsedJson.runners.get(position).interval;
		//textView3.setText("Interval: " + parsedJson.runners.get(position).counter[1] + "; Split Time: " + parsedJson.runners.get(position).interval.get(intervals.size() - 1)[1]);
		
		
		//Build a string for each athlete adn interate over every one of their splits and display all of them
		StringBuilder builder = new StringBuilder();
		List<String[]> intervals = parsedJson.runners.get(position).interval;
		TextView textView3 = (TextView) convertView.findViewById(R.id.dropdown);
		
		
		for (int i = 0; i < parsedJson.runners.get(position).counter.length;i++)
		{	
				builder.append("Interval: " +  parsedJson.runners.get(position).counter[i] +";  ");
				builder.append("Splits:" );
				
			for (String splits: parsedJson.runners.get(position).interval.get(i))
			{
				builder.append(splits + " ");
				
			}
				
			builder.append("\n");
				
		}
		textView3.setText(builder.toString());
		
		
		//TextView textView2 = (TextView) convertView.findViewById(R.id.list_text2);
		
		
		
		//List<String[]> intervals = parsedJson.runners.get(position).interval;
		//int ii = parsedJson.runners.get(position).interval.get(intervals.size() - 1).length - 1;
		
		//textView2.setText(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[ii]);
		
		
		
		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	
}
