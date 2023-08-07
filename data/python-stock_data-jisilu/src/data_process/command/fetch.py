# -*- coding: utf-8 -*-

import logging

from cleo.commands.command import Command
from cleo.helpers import argument, option

from data_process import fetch_etf, fetch_qdii, fetch_lof

logger = logging.getLogger(__name__)


class FetchCommand(Command):
    name = "fetch"
    description = "抓取股票数据"
    arguments = []
    options = []

    def handle(self):
        fetch_etf()
        fetch_qdii()

        if self.option("show"):
            """显示"""
            # logger.info("%s" % (data,))
            # print(ids)
