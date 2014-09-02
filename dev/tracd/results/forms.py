from django.contrib.auth.models import User
#from results.models import WorkoutLog
from common.models import Workout
from django import forms

class WorkoutForm(forms.ModelForm):
    name = forms.CharField()

    class Meta:
        model = Workout
        fields = ('name', 'start_time', 'stop_time')
        widgets = {'start_time': forms.widgets.DateTimeInput(), 
                   'stop_time': forms.widgets.DateTimeInput()}
