from django.conf.urls import url
from views import bicycleStationInfo, bicycleStationsInfo, version, areaStations

urlpatterns = [
    url(r'^station/(?P<stationcode>\w+)/$', bicycleStationInfo),
    url(r'^stations/$', bicycleStationsInfo),
    url(r'version/(?P<version>\d+)/$', version),
    url(r'areastations/(?P<area>\w+)/$', areaStations)
]