# -*- coding: utf-8 -*-

from __future__ import unicode_literals

from django.db import models
from datetime import datetime

class Zone(models.Model):
    """区域字典表"""
    zonecode = models.CharField(u'zonecode', max_length=100, primary_key=True)
    name = models.CharField(u'名字', max_length=100)

    def __unicode__(self):
        return self.name

    class Meta:
        verbose_name = '区域'
        verbose_name_plural = '区域'

class StationStatus(models.Model):
    """网点状态字典表"""
    statuscode = models.CharField(u'statuscode', max_length=100, primary_key=True)
    status = models.CharField(u'状态', max_length=50)

    def __unicode__(self):
        return self.status

    class Meta:
        verbose_name = '网点状态'
        verbose_name_plural = '网点状态'

class ManageLog(models.Model):
    """日志字典表"""
    code = models.IntegerField(u'code', primary_key=True)
    name = models.CharField(u'名称', max_length=50)

    def __unicode__(self):
        return self.name

    class Meta:
        verbose_name = '日志字典表'
        verbose_name_plural = '日志字典表'

class BicycleStation(models.Model):
    """自行车网点表"""
    name = models.CharField(u'名字', max_length=100)
    address = models.CharField(u'地址', max_length=500, default=None, blank=True, null=True)
    lon = models.CharField(u'火星座标系-经度', max_length=20, default=None, blank=True, null=True)
    lat = models.CharField(u'火星座标系-纬度', max_length=20, default=None, blank=True, null=True)
    bdlon = models.CharField(u'百度座标系-经度', max_length=20, default=None, blank=True, null=True)
    bdlat = models.CharField(u'百度座标系-纬度', max_length=20, default=None, blank=True, null=True)
    num = models.IntegerField(u'锁车器数', default=None, blank=True, null=True)
    code = models.CharField(u'code', max_length=100, primary_key=True)
    localcode = models.CharField(u'localcode', max_length=100, default=None, blank=True, null=True)
    zone = models.ForeignKey(Zone, verbose_name = u'区域', default=None, blank=True, null=True)
    bikenum = models.IntegerField(u'可借车数', default=None, blank=True, null=True)
    emptynum = models.IntegerField(u'可还车数', default=None, blank=True, null=True)
    updatetime = models.CharField(u'最后更新时间', max_length=20, default=None, blank=True, null=True)
    status = models.ForeignKey(StationStatus, verbose_name=u'状态', default=None, blank=True, null=True)

    def __unicode__(self):
        return self.name

    class Meta:
        verbose_name = '自行车网点'
        verbose_name_plural = '自行车网点'

class Logs(models.Model):
    """日志表"""
    name = models.CharField(u'名字', max_length=100)
    address = models.CharField(u'地址', max_length=500, default=None, blank=True, null=True)
    lon = models.CharField(u'火星座标系-经度', max_length=20, default=None, blank=True, null=True)
    lat = models.CharField(u'火星座标系-纬度', max_length=20, default=None, blank=True, null=True)
    bdlon = models.CharField(u'百度座标系-经度', max_length=20, default=None, blank=True, null=True)
    bdlat = models.CharField(u'百度座标系-纬度', max_length=20, default=None, blank=True, null=True)
    num = models.IntegerField(u'锁车器数', default=None, blank=True, null=True)
    code = models.CharField(u'code', max_length=100)
    localcode = models.CharField(u'localcode', max_length=100, default=None, blank=True, null=True)
    zone = models.ForeignKey(Zone, verbose_name = u'区域', default=None, blank=True, null=True)
    updatetime = models.DateTimeField(u'修改时间', default=datetime.now, blank=True, null=True)
    version = models.IntegerField(u'版本号')
    manage = models.ForeignKey(ManageLog, verbose_name=u'管理')

    def __unicode__(self):
        return self.name

    class Meta:
        verbose_name = '官网修改日志表'
        verbose_name_plural = '官网修改日志表'
        