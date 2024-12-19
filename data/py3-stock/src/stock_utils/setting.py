# -*- coding: utf-8 -*-
"""加载配置
"""

import configparser
import logging
import logging.config
import os
import os.path
import sys

logger = logging.getLogger(__name__)


class SETTING(object):
    def __init__(self):
        self.config = None

    def load_from_config_file(self, cf, encoding='utf-8'):
        """从配置文件中加载
        """
        self.config = configparser.ConfigParser()
        self.config.read(cf, encoding=encoding)

    def sections(self):
        return self.config.sections()

    def get(self, section: str) -> dict:
        return dict(self.config[section])

    def get_list(self, section: str, item: str) -> list:
        result = dict(self.config[section]).get(item).split('\n')
        return [x for x in result if x != '']


def set_logger(cfg: str, search: list = []):
    """配置日志
    """
    cfile = _get_config_filepath(cfg, search)

    if cfile is None:
        print("No logger config 未配置日志")
    else:
        logging.config.fileConfig(cfile)


def load_setting(cfg: str, search: list = []) -> SETTING:
    """加载配置文件
    """
    cfile = _get_config_filepath(cfg, search)

    if cfile is None:
        print("No SETTING file 未找到配置文件")
        sys.exit(1)
    else:
        setting = SETTING()
        setting.load_from_config_file(cfile)
        return setting


def _get_config_filepath(cfg: str, search: list = []) -> str:
    """查找策略（按下列顺序查找）：
    1. .
    2. ./conf
    3. search
    4. /etc/zabbix/
    
    成功返回文件路径名， 失败返回 None。
    """
    searchs = [".", "./conf"] + search + ["/etc/zabbix"]
    cfile = None
    for path in searchs:
        cfile = os.path.join(path, cfg)
        if os.path.exists(cfile): break

    return cfile
