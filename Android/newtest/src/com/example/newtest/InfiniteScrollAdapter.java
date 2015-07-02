package com.example.newtest;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.Collection;

public abstract class InfiniteScrollAdapter extends BaseAdapter {

    private boolean doneLoading = false;
    private LayoutInflater inflater;

    public InfiniteScrollAdapter(Context context) {
        inflater = LayoutInflater.from(context);
    }

    @Override
    public int getCount() {
        return getItems().size() + (!doneLoading ? 1 : 0);
    }

    @Override
    public Object getItem(int position) {
        if (!doneLoading && position == getCount()) {
            throw new IllegalArgumentException("Can not call getItem on loading placeholder.");
        } else {
            return getRealItem(position);
        }
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (!doneLoading && position >= getItems().size()) {
            return getLoadingView(inflater, parent);
        } else {
            return getRealView(inflater, position, convertView, parent);
        }
    }

    protected void setDoneLoading() {
        doneLoading = true;
    }

    public abstract Collection getItems();
    public abstract void addItems(Collection items);
    public abstract Object getRealItem(int position);
    public abstract View getRealView(LayoutInflater inflater, int position, View convertView, ViewGroup parent);
    public abstract View getLoadingView(LayoutInflater inflater, ViewGroup parent);
}
