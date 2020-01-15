from django import forms
import datetime

YEARS= [x for x in range(2011,2019)]
Primary_desc = (("INTIMIDATION","INTIMIDATION"), ("OBSCENITY","OBSCENITY"),("OBSCENITY","OBSCENITY"),("CRIMINAL DAMAGE","CRIMINAL DAMAGE")
    ,("ROBBERY","ROBBERY"))
location_desc = (("APARTMENT","APARTMENT"), ("SCHOOL","SCHOOL"),("PRIVATE","PRIVATE"),("BUILDING","BUILDING")
    ,("HOTEL/MOTEL","HOTEL/MOTEL"))

class Analysis1(forms.Form):
    start_date = forms.DateField(label='Start date', widget=forms.SelectDateWidget(years=YEARS))
    end_date = forms.DateField(label='End date',widget=forms.SelectDateWidget(years=YEARS), initial=datetime.date.today)

class Analysis2(forms.Form):
    start_date = forms.DateField(label='Start date', widget=forms.SelectDateWidget(years=YEARS))
    end_date = forms.DateField(label='End date',widget=forms.SelectDateWidget(years=YEARS), initial=datetime.date.today)
    
    prim_desc = forms.MultipleChoiceField(label="Location Description", choices=Primary_desc, widget=forms.CheckboxSelectMultiple(),)
    loc_desc = forms.MultipleChoiceField(label="Location Description", choices=location_desc, widget=forms.CheckboxSelectMultiple(),)
    
class Analysis3(forms.Form):
    start_date = forms.DateField(label='Start date', widget=forms.SelectDateWidget(years=YEARS))
    end_date = forms.DateField(label='End date',widget=forms.SelectDateWidget(years=YEARS), initial=datetime.date.today)