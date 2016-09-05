#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'xiaoyipeng'

class Logs(object):
    """日志表"""
    def __repr__(self):
        return "%s(%r,%r,%r)"%(self.__class__.__name__, self.name, self.version, self.manage)