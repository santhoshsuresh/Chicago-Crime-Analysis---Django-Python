from django.urls import path

from . import views

app_name = 'trent'
urlpatterns = [
    path('', views.home, name='Home'),
    path('about', views.about, name='About'),
    #trends
    path('percentchange/', views.percentchange, name='percent'),
    path('discrime/', views.typecrime_analysis, name='typecrime'),
    path('stddev_time/', views.crime_time, name='crimerisk'),
    path('beattrend/', views.beat_trend, name="Beat"),
    path('violence_trend/', views.violence_trend, name="violence"),
    path('arrest_crime/', views.arrestcrime_trend, name="arrest"),

    path('api/get_data', views.get_data),
    
]