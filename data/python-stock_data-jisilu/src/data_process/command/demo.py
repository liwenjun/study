# -*- coding: utf-8 -*-

import logging
import time

from cleo.commands.command import Command
from cleo.helpers import argument, option
from tqdm import tqdm


logger = logging.getLogger(__name__)


class DemoCommand(Command):
    name = "demo"
    description = "功能演示"
    arguments = []
    options = []

    def handle(self):
        """
        dat = get_etf_detail('588080')
        print(dat)
        """
        for i in tqdm(range(100)):
            time.sleep(0.01)
