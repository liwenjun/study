# -*- coding: utf-8 -*-

import logging

from cleo.commands.command import Command
from cleo.helpers import argument, option

from sd_core import (
    update_etf_list,
    update_etf_daily,
    update_fund_daily,
    update_fund_list,
    update_stock_daily,
    update_stock_list,
)

logger = logging.getLogger(__name__)


class UpdateCommand(Command):
    name = "update"
    description = "抓取股票数据"
    arguments = [
        argument("target", description="指定需要抓取的数据, 可用值：etf/stock/all", optional=False)
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
        target = self.argument("target")

        if self.option("log"):
            self.line("记录日志")

        match target.lower():
            case "etf":
                update_etf_list()
                update_etf_daily()
            case "stock":
                update_fund_list()
                update_fund_daily()
                update_stock_list()
                update_stock_daily()
            case "all":
                update_etf_list()
                update_etf_daily()
                update_fund_list()
                update_fund_daily()
                update_stock_list()
                update_stock_daily()
            case _:
                self.line("记录日志")
