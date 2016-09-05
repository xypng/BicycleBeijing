#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'xiaoyipeng'

class Stations(object):
    """自行车网点表"""
    def __repr__(self):
        return "%s(%r,%r,%r)"%(self.__class__.__name__, self.name, self.address)