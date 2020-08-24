#!/usr/bin/env python
# -*- encoding: utf-8 -*-
##
# Copyright 2019 FIWARE Foundation, e.V.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
##
from configparser import ConfigParser
from os.path import join, exists, dirname, abspath
from os import environ

__author__ = 'fla'

__version__ = '1.0.0'


"""
Default configuration.

The configuration `cfg_defaults` are loaded from `cfg_filename`, if file exists in
/etc/fiware.d/management.ini

Optionally, user can specify the file location manually using an Environment variable called CONFIG_FILE.
"""

name = 'management'

cfg_dir = "/etc/fiware.d"

if environ.get("CONFIG_FILE"):
    cfg_filename = environ.get("CONFIG_FILE")

else:
    cfg_filename = join(cfg_dir, '%s.ini' % name)

Config = ConfigParser()

Config.read(cfg_filename)


def config_section_map(section):
    dict1 = {}
    options = Config.options(section)

    for option in options:
        try:
            dict1[option] = Config.get(section, option)
            if dict1[option] == -1:
                print("skip: %s" % option)
        except Exception as e:
            print("exception on %s!" % option)
            print(e)
            dict1[option] = None

    return dict1


if Config.sections():
    # Data from openstack section
    openstack = config_section_map("openstack")
    USERNAME = openstack['openstack_user_name']
    TENANT_NAME = openstack['openstack_tenant_name']
    PASSWORD = openstack['openstack_password']
    AUTH_URL = openstack['openstack_auth_url']
    REGION = openstack['openstack_region']
    DOMAIN_NAME = openstack['openstack_domain_name']
    FLAVOR = openstack['openstack_flavor']
else:
    msg = '\nERROR: There is not defined CONFIG_FILE environment variable ' \
            '\n       pointing to configuration file or there is no management.ini file' \
            '\n       in the /etd/init.d directory.' \
            '\n\n       Please correct at least one of them to execute the program.\n\n\n'

    exit(msg)
