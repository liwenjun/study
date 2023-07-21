# -*- coding: utf-8 -*-

import logging


import sys
import os
from cleo.commands.command import Command
from cleo.helpers import argument, option

logger = logging.getLogger(__name__)


class UpCommand(Command):
    name = "up"
    description = "更新本地源码"
    arguments = [
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
        local = self.argument("local")

        if self.option("log"):
            logger.info("%s" % (local))
