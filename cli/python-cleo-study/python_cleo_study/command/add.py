# -*- coding: utf-8 -*-

import logging


import sys
import os
from cleo.commands.command import Command
from cleo.helpers import argument, option

logger = logging.getLogger(__name__)


class AddCommand(Command):
    name = "add"
    description = "克隆一个源码仓库至本地"
    arguments = [
        argument("url", description="远程源码url", optional=False),
        argument("local", description="本地存放路径", optional=False),
    ]
    options = [
        option(
            "log",
            "l",
            description="记录日志",
            flag=True,
        )
    ]

    def handle(self):
        url = self.argument("url")
        local = self.argument("local")

        if self.option("log"):
            logger.info("%s => %s" % (url, local))
