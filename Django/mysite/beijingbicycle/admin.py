# -*- coding: utf-8 -*-

from django.contrib import admin
from models import Zone, StationStatus, BicycleStation, ManageLog, Logs
from custom_model_admin import CustomModelAdmin

class ZoneAdmin(CustomModelAdmin):
    list_display = ('zonecode', 'name')
    ordering = ('zonecode',)

class StationStatusAdmin(CustomModelAdmin):
    list_display = ('statuscode', 'status')
    ordering = ('statuscode',)

class BicycleStationAdmin(CustomModelAdmin):
    list_display = ('name', 'address', 'zone', 'lon', 'lat', 'bdlon', 'bdlat', 'num', 'bikenum', 'emptynum', 'updatetime', 'status', 'code', )
    ordering = ('code',)
    search_fields = ('name', 'address', 'code')
    list_filter = ('status', 'zone')

class ManageLogAdmin(CustomModelAdmin):
    list_display = ('code', 'name')
    ordering = ('code',)

class LogsAdmin(CustomModelAdmin):
    list_display = ('name', 'address', 'zone', 'lon', 'lat', 'bdlon', 'bdlat', 'num', 'updatetime', 'manage', 'version', 'code', )
    ordering = ('-version',)
    search_fields = ('name', 'address', 'code')
    list_filter = ('manage', 'zone', 'version')
    # date_hierarchy = "updatetime"

admin.site.register(Zone, ZoneAdmin)
admin.site.register(StationStatus, StationStatusAdmin)
admin.site.register(BicycleStation, BicycleStationAdmin)
admin.site.register(ManageLog, ManageLogAdmin)
admin.site.register(Logs, LogsAdmin)
