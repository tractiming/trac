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
		
		
		//this finds the name and displays it
		TextView textView =(TextView) convertView.findViewById(R.id.list_text);
		textView.setText(parsedJson.runners.get(position).name);
		
		
		
		
		//This determines the what is the most recent split, and display it
		TextView textView2 = (TextView) convertView.findViewById(R.id.list_text2);
		List<String[]> intervals = parsedJson.runners.get(position).interval;
		int ii = parsedJson.runners.get(position).interval.get(intervals.size() - 1).length - 1;
		textView2.setText(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[ii]);
		
		
		//Add times together and display elapsed time for split
				TextView textView4 =(TextView) convertView.findViewById(R.id.list_text3);
			    float temp_var = 0; 
				for (int i = 0; i < parsedJson.runners.get(position).interval.get(intervals.size() - 1).length; i++)			
				{
					
					float foo = Float.parseFloat(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[i]);
					temp_var=temp_var + foo;
				}
				StringBuilder sb = new StringBuilder();
				int min = (int) Math.floor(temp_var/60);
				int sec = (int) (((temp_var*60)-Math.floor(temp_var/60)*3600)/60);
				int mili = (int) (temp_var*100-Math.floor(temp_var)*100);
				if (sec < 10)
				{
					sb.append(min + ":0" + sec +"." + mili );
				}
				else
				{
					sb.append(min + ":" +sec +"."+ mili);
				}
				
				String strI = sb.toString();
				
				textView4.setText(strI);
			    
		
		//This is for the popup window
		StringBuilder builder_group = new StringBuilder();
		//List<String[]> interval = parsedJson.runners.get(position).interval;
		TextView textView3 = (TextView) convertView.findViewById(R.id.dropdown);
		
				builder_group.append("Session Splits: ");
			for (int i = 0; i < parsedJson.runners.get(position).interval.get(intervals.size() - 1).length; i++)			
			{
				builder_group.append(parsedJson.runners.get(position).interval.get(intervals.size() - 1)[i] + " ");
				
			}
		textView3.setText(builder_group.toString());
		
	
		
		//Fill that view with data
		//Return that view
		return convertView;
	}


	private Object Integer(float temp_var) {
		// TODO Auto-generated method stub
		return null;
	}


	
}
