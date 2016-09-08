# -*- coding: utf-8 -*-

from django.shortcuts import render
from django.http import HttpResponse, Http404, HttpResponseRedirect
from models import BicycleStation, Logs
import json
from django.db.models import Sum

#根据一个code返回网点信息
def bicycleStationInfo(request, stationcode):
    bicycleStations = BicycleStation.objects.filter(code=stationcode)
    return HttpResponse(jsonstations(bicycleStations))

#根据code列表返回这些网点信息
def bicycleStationsInfo(request):
    if request.method == 'POST' and 'codes' in request.POST and request.POST['codes']:
        codesStr = request.POST['codes']
        codes = json.loads(str(codesStr))
        bicycleStations = BicycleStation.objects.filter(code__in=codes)
        return HttpResponse(jsonstations(bicycleStations))
    else:
        raise Http404()

#根据一个version返回数据库变更信息
def version(request, version):
    logs = Logs.objects.filter(version__gt=version).values('code').annotate(manage=Sum('manage_id')) 
    addlist = []
    modifylist = []
    deletelist = []
    for log in logs:
        if log["manage"] == -1:
            deletelist.append(log["code"])
        elif log["manage"] == 0:
            modifylist.append(log["code"])
        elif log["manage"] == 1:
            addlist.append(log["code"])
    modifys = BicycleStation.objects.filter(code__in=modifylist)
    adds = BicycleStation.objects.filter(code__in=addlist)
    result = {"delete":deletelist, "add":liststations(adds), "modify":liststations(modifys)}
    return HttpResponse(json.dumps(result))

#查询区域所有的网点信息
def areaStations(request, area):
    bicycleStations = BicycleStation.objects.filter(zone=area)
    return HttpResponse(jsonstations(bicycleStations))

def jsonstations(bicycleStations):
    data = {}
    for bicycleStation in bicycleStations:
        if bicycleStation.updatetime:
            data[bicycleStation.code] = [ bicycleStation.bikenum, bicycleStation.emptynum, bicycleStation.num, bicycleStation.updatetime ]
    return json.dumps(data)

def liststations(bicycleStations):
    returnlist = []
    for bicycle in bicycleStations:
        returnlist.append({"code": bicycle.code, 
                            "name": bicycle.name, 
                            "address": bicycle.address, 
                            "lon": bicycle.lon, 
                            "lat": bicycle.lat, 
                            "bdlon": bicycle.bdlon,
                            "bdlat": bicycle.bdlat,
                            "zone": bicycle.zone_id})
    return returnlist

    