package com.example.newtest;


import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;


public class WorkoutView extends Fragment{

	/**
	 * Returns a new instance of this fragment.
	 */
	
	public WorkoutView() {
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		View rootView = inflater.inflate(R.layout.fragment_workout_view, container,
				false);
		return rootView;
	}
}