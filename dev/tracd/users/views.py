from django.shortcuts import render, render_to_response
from django.template import RequestContext
from users.forms import UserForm
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseRedirect, HttpResponse

def register(request):
    context = RequestContext(request)

    registered = False

    if request.method == 'POST':
        user_form = UserForm(data=request.POST)

        if user_form.is_valid():
            user = user_form.save()

            user.set_password(user.password)
            user.save()

            registered = True
        else:
            print user_form.errors

    else:
        user_form = UserForm()

    return render_to_response('users/register.html', {'user_form': user_form,
        'registered': registered}, context)    


def user_login(request):
    context = RequestContext(request)

    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']

        user = authenticate(username=username, password=password)

        if user:
            if user.is_active:
                auth_login(request, user)
                return HttpResponseRedirect('/users/home/')
            else:
                return HttpResponse("Your trac account is disabled")

        else:
            print "Invalid login details: {0}, {1}".format(username, password)
            return HttpResponse("Invalid login credentials.")

    else:
        return render(request, 'users/login.html')

@login_required
def user_logout(request):
    logout(request)
    return HttpResponseRedirect('/users/')

@login_required
def user_home(request):
    context = RequestContext(request)
    return render(request, 'users/home.html')

