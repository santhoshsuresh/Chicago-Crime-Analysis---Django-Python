from django.db import models

class address(models.Model):
    ADDRESS_ID  = models.IntegerField(primary_key=True)
    BLOCK       = models.TextField(max_length=500)
    ZIPCODE     = models.IntegerField()
    AREA_CODE   = models.IntegerField()
    X_CORDINATE= models.IntegerField()
    Y_CORDINATE= models.IntegerField()
    class Meta:
        db_table = 'CCT_ADDRESS'
        
class beat(models.Model):
    BEAT_NUMBER  = models.IntegerField(primary_key=True)
    DISTRICT_NO  = models.IntegerField()
    SECTOR       = models.IntegerField()

    class Meta:
        db_table = 'CCT_BEATS'




