from django.conf.urls import url
from views import bicycleStationInfo, bicycleStationsInfo, version

urlpatterns = [
    url(r'^station/(?P<stationcode>\w+)/$', bicycleStationInfo),
    url(r'^stations/$', bicycleStationsInfo),
    url(r'version/(?P<version>\d+)/$', version)
]