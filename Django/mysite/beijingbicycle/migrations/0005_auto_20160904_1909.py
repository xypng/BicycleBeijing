# -*- coding: utf-8 -*-
# Generated by Django 1.10 on 2016-09-04 11:09
from __future__ import unicode_literals

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('beijingbicycle', '0004_auto_20160904_1854'),
    ]

    operations = [
        migrations.AlterField(
            model_name='logs',
            name='updatetime',
            field=models.DateTimeField(blank=True, default=datetime.datetime.now, null=True, verbose_name='\u4fee\u6539\u65f6\u95f4'),
        ),
    ]
