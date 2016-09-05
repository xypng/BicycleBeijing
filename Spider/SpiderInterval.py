#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'xiaoyipeng'

import time
from SpiderData import Spider
import logging
import urllib
import urllib2
import json
import traceback
 
interval=300
dic = {}
errorarea = []

url = "http://bjggzxc.btic.org.cn/Bicycle/BicycleServlet?action=GetBicycleStatus"
logging.basicConfig(filename='example.log',level=logging.DEBUG)
areaList = ["0101", "0102", "0105", "0106", "0107", "0108", "0111", "0112", "0113", "0114", "0115", "0117", "0228"]

def delayrun():
    global dic, errorarea
    dic = {}
    errorarea = []
    for areaid in areaList:
        print areaid
        netBicycles(areaid)
    print len(dic)
    print "errorarea:", errorarea
    spider = Spider(dic, errorarea)
    try:
        spider.start()
    except Exception, e:
        logError()

def netBicycles(areaid):
    '''爬到官网上的数据，list返回'''
    global dic
    values = {"currentPage": 1, "pageSize": 10000, "currentAreaid": areaid}
    data = urllib.urlencode(values)
    request = urllib2.Request(url, data)
    try:
        response = urllib2.urlopen(request, timeout=60)
        result = response.read()
        netbicycles = json.loads(result)
        print len(netbicycles)
        for bicycle in netbicycles:
            #只有name不为空,有座标的数据才有意义
            if bicycle['name'] and bicycle['bdLatitude'] and bicycle['bdLongitude']:
                dic[bicycle['stationCode']] = bicycle
    except Exception,e:
        #出错的区域接下来不处理
        errorarea.append(areaid)
        logError()

def logError():
    '''打印错误到日志'''
    logging.error(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())))
    logging.error(traceback.format_exc())

if __name__ == '__main__':
    while True:
        print "开始执行:", time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        delayrun()
        print "结束执行:", time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
        time_remaining = interval-time.time()%interval
        print "还要等：", time_remaining
        time.sleep(time_remaining)