# -*- coding: utf-8 -*-

import logging

from cleo.commands.command import Command
from cleo.helpers import argument, option

from sd_core import fetch_stock

logger = logging.getLogger(__name__)


class FetchCommand(Command):
    name = "fetch"
    description = "抓取股票数据"
    arguments = []
    options = []

    def handle(self):
        fetch_stock()
