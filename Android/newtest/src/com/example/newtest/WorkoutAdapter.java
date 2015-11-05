package com.example.newtest;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class WorkoutAdapter extends BaseAdapter{

	private List<Runners> parsedJson; 
	private Context context;
	private ArrayList<Runners> runnersList;
	
	
	public WorkoutAdapter(List<Runners> workout, Context context) {
	 runnersList = new ArrayList<Runners>();
	 this.parsedJson = workout;
	 this.context = context;
	 runnersList.addAll(parsedJson);
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
			convertView = LayoutInflater.from(context).inflate(R.layout.list_item_workout, null);
		}
		
		
		//Show the athletes name
		//TextView textView =(TextView) convertView.findViewById(R.id.list_text_workout);
		//textView.setText(parsedJson.get(position).name);
		//Log.d("Debug",parsedJson.get(position).name);
		
		//TextView textView3 = (TextView) convertView.findViewById(R.id.dropdown);
		//List<String[]> intervals = parsedJson.runners.get(position).interval;
		//textView3.setText("Interval: " + parsedJson.runners.get(position).counter[1] + "; Split Time: " + parsedJson.runners.get(position).interval.get(intervals.size() - 1)[1]);
		
		
		//Build a string for each athlete adn interate over every one of their splits and display all of them
		StringBuilder builder = new StringBuilder();
		List<String[]> intervals = parsedJson.get(position).interval;
		TextView textView3 = (TextView) convertView.findViewById(R.id.dropdown);
		
		int jj;
		for (int i = 0; i < intervals.size(); i++)
		{	
			jj = i+1;
				builder.append(jj);
				builder.append("                                          ");
				
			for (String splits: parsedJson.get(position).interval.get(i))
			{
				float temp = Float.parseFloat(splits);
				if (temp>90){
					int min = (int) Math.floor(temp/60);
					int sec = (int) (((temp*60)-Math.floor(temp/60)*3600)/60);
					int mili = (int) (temp*100-Math.floor(temp)*100);
					if (sec < 10)
					{
						StringBuilder sb = new StringBuilder();
						sb.append(min + ":0" + sec +"." + mili );
						builder.append(sb + " ");
					}
					else
					{
						StringBuilder sb = new StringBuilder();
						sb.append(min + ":" +sec +"."+ mili);
						builder.append(sb + " ");
					}
				}
				else{
				builder.append(splits + " ");
				}
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

	public void getFilter(String charText) {
		charText = charText.toLowerCase(Locale.getDefault());
		parsedJson.clear();
				if (charText.length() == 0) {
					parsedJson.addAll(runnersList);
		} 
		else 
		{
			for (Runners wp : runnersList) 
			{
				if (wp.name.toLowerCase(Locale.getDefault()).contains(charText)) 
				{
					parsedJson.add(wp);
				}
			}
		}
		notifyDataSetChanged();
	}
	
}
