from django.shortcuts import render
from django.template import RequestContext
from results.forms import WorkoutForm
from django.contrib.auth.decorators import login_required, permission_required
from django.http import HttpResponseRedirect, HttpResponse
from django.contrib.auth.models import User
from common.models import Workout

@login_required
def results_home(request):
    """The user's home page for viewing all of his past workout results."""
    user = User.objects.get(username=request.user) 
    workout_list = [w.num for w in Workout.objects.all() if user in w.all_users()]
    return render(request, 'results/results.html', {'workout_list':
        workout_list})

@permission_required('auth.can_create_workout', login_url='/users/login/')
def create_workout(request):
    """The form page that allows a coach to create a new workout."""
    context = RequestContext(request)

    if request.method == 'POST':
        workout_form = WorkoutForm(data=request.POST)

        if workout_form.is_valid():
            workout = workout_form.save()
            workout.save()

        else:
            print workout_form.errors

    else:
        workout_form = WorkoutForm()

    return render(request, 'results/createworkout.html', {'workout_form': workout_form})    

@login_required
def workout_results(request, *args, **kwargs):
    """Displays the results of one workout for one athlete or coach."""
    workout = Workouts.objects.all()[kwargs['wnum']]
    return HttpResponse(200)


