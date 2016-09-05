#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'xiaoyipeng'

import urllib
import urllib2
import json
import logging
import traceback
import time
from coordTransform_utils import bd09togcj02
import datetime
from Logs import *
from Stations import *
from sqlalchemy import create_engine, orm, MetaData, func

url = "http://bjggzxc.btic.org.cn/Bicycle/BicycleServlet?action=GetBicycleStatus"
logging.basicConfig(filename='example.log',level=logging.DEBUG)

engine = create_engine('mysql://xypng:123456@localhost/BicycleBeijing?charset=utf8', encoding = 'utf-8', convert_unicode=True, echo = False)
meta = MetaData(bind=engine, reflect=True)
session = orm.Session(bind=engine)
orm.Mapper(Stations, meta.tables['beijingbicycle_bicyclestation'])
orm.Mapper(Logs, meta.tables['beijingbicycle_logs'])

class Spider(object):
    def __init__(self, netBicycles, errorarea):
        self.netBicycles = netBicycles
        #在网络中获取数据时出错的区域不处理
        self.errorarea = errorarea

    def start(self):
        dbBicycles = self.dbBicycles()
        self.version = self.getVersion()
        print self.version
        #遍历数据库中的数据，和从官网上获取的数据比较
        for dbbicycle in dbBicycles:
            netbicycle = self.netBicycles.get(dbbicycle.code, "")
            if not netbicycle:
                #网络中没找到这个网点，说明删除了
                session.delete(dbbicycle)
                #添加Logs表,-1是删除
                self.addlog(dbbicycle, -1)
            else:
                modify = False
                if dbbicycle.name!=netbicycle["name"]:
                    print "deferent name %s,%s" % (dbbicycle.name, netbicycle["name"])
                    dbbicycle.name = netbicycle["name"]
                    modify = True
                if dbbicycle.address!=netbicycle["adress"]:
                    print "deferent address %s,%s" % (dbbicycle.address, netbicycle["adress"])
                    dbbicycle.address = netbicycle["adress"]
                    modify = True
                #官网的锁车器总数也总是在变的，所以当做实时更新的数据
                # if str(dbbicycle.num)!=(netbicycle["bikesNum"] if netbicycle["bikesNum"] else 0):
                #     print "deferent bikesNum %s,%s" % (dbbicycle.num, (netbicycle["bikesNum"] if netbicycle["bikesNum"] else 0))
                #     dbbicycle.num = netbicycle["bikesNum"] if netbicycle["bikesNum"] else 0
                #     modify = True
                #官网的longtitude,latitude不是火星座标系
                # if dbbicycle.lon!=str(netbicycle["longitude"]):
                #     print "deferent longitude %s,%s" % (dbbicycle.lon, netbicycle["longitude"])
                #     dbbicycle.lon = str(netbicycle["longitude"])
                #     modify = True
                # if dbbicycle.lat!=str(netbicycle["latitude"]):
                #     print "deferent latitude %s,%s" % (dbbicycle.lat, netbicycle["latitude"])
                #     dbbicycle.lat = str(netbicycle["latitude"])
                #     modify = True
                coord  = bd09togcj02(netbicycle["bdLongitude"], netbicycle["bdLatitude"])
                if dbbicycle.bdlon!=str(netbicycle["bdLongitude"]):
                    print "deferent bdLongitude %s,%s" % (dbbicycle.bdlon, netbicycle["bdLongitude"])
                    dbbicycle.bdlon = str(netbicycle["bdLongitude"])
                    dbbicycle.lon = coord[0]
                    modify = True
                if dbbicycle.bdlat!=str(netbicycle["bdLatitude"]):
                    print "deferent bdLatitude %s,%s" % (dbbicycle.bdlat, netbicycle["bdLatitude"])
                    dbbicycle.bdlat = str(netbicycle["bdLatitude"])
                    dbbicycle.lat = coord[1]
                    modify = True

                if netbicycle["maxReportTime"] and dbbicycle.updatetime!=netbicycle["maxReportTime"]:
                    dbbicycle.bikenum = netbicycle["bikes"] if netbicycle["bikes"] else 0
                    dbbicycle.emptynum = netbicycle["empty"] if netbicycle["empty"] else 0
                    dbbicycle.num = netbicycle["bikesNum"] if netbicycle["bikesNum"] else 0
                    dbbicycle.status = netbicycle["status"]
                    dbbicycle.updatetime = netbicycle["maxReportTime"]
                if modify:
                    #添加Logs表,0是修改
                    print 'aaa'
                    self.addlog(dbbicycle, 0)

                #从字典中删除
                del self.netBicycles[dbbicycle.code]
        #如果字典中还有剩下，那是添加的
        for dic in self.netBicycles.values():
            self.addStation(dic)
        session.commit()

    # def netBicycles(self):
    #     '''爬到官网上的数据，list返回'''
    #     values = {"currentPage": 1, "pageSize": 10000, "currentAreaid": self.areaid}
    #     data = urllib.urlencode(values)
    #     request = urllib2.Request(url, data)
    #     try:
    #         response = urllib2.urlopen(request, timeout=60)
    #         result = response.read()
    #         netbicycles = json.loads(result)
    #         return netbicycles
    #     except Exception,e:
    #         self.logError()
    #         return None

    def dbBicycles(self):
        '''数据库中的数据，list返回'''
        if self.errorarea:
            return session.query(Stations).filter(~Stations.zone_id.in_(self.errorarea))
        else:
            return session.query(Stations).all()

    def getVersion(self):
        '''版本号'''
        version = session.query(func.max(Logs.version)).all()
        print version
        if version[0][0] == None:
            version = 0
        else:
            version = version[0][0] + 1
        return version

    def addlog(self, bicycle, manage):
        log = Logs()
        log.name = bicycle.name
        log.address = bicycle.address
        log.lon = bicycle.lon
        log.lat = bicycle.lat
        log.bdlon = bicycle.bdlon
        log.bdlat = bicycle.bdlat
        log.num = bicycle.num
        log.code = bicycle.code
        log.localcode = bicycle.localcode
        log.zone_id = bicycle.zone_id
        log.version = self.version
        log.updatetime = datetime.datetime.utcnow()
        log.manage_id = manage
        session.add(log)

    def addStation(self, dic):
        station = Stations()
        station.name = dic["name"]
        station.address = dic["adress"]
        # station.lon = str(dic["longitude"])
        # station.lat = str(dic["latitude"])
        station.bdlon = str(dic["bdLongitude"])
        station.bdlat = str(dic["bdLatitude"])
        coord  = bd09togcj02(dic["bdLongitude"], dic["bdLatitude"])
        station.lon = coord[0]
        station.lat = coord[1]
        station.code = dic["stationCode"]
        station.zone_id = dic["countyCode"]
        station.num = dic["bikesNum"] if dic["bikesNum"] else 0
        station.bikenum = dic["bikes"] if dic["bikes"] else 0
        station.emptynum = dic["empty"] if dic["empty"] else 0
        station.updatetime = dic["maxReportTime"]
        station.status_id = dic["status"]
        session.add(station)
        #添加日志，1是添加
        self.addlog(station, 1)

    def logError(self):
        '''打印错误到日志'''
        logging.error(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())))
        logging.error(traceback.format_exc())

if __name__ == '__main__':
    spider = Spider("0101")
    spider.start()