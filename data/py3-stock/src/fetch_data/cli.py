# -*- coding: utf-8 -*-
import logging
import sys

from stock_utils import setting

logger = logging.getLogger(__name__)


def main():
    # 设置日志
    setting.set_logger("logger.conf")

    # 读取配置
    cfg = setting.load_setting("stock.conf")

    # 获取命令行参数
    args = getArgs()
    if args.minute:
        from .main import run_minute
        run_minute(cfg)
    elif args.kdata:
        from .main import run_kdata
        run_kdata(cfg)
    elif args.transaction:
        from .main import run_transaction
        run_transaction(cfg, args.force)
    else:
        from .main import run
        run(cfg)

    return 0


def getArgs():
    '''命令行参数处理函数
    '''
    import argparse

    p = argparse.ArgumentParser(prog="fetch_data", description="股票数据下载工具 build-20200919")
    p.add_argument("-f", "--force", help="强制执行，覆盖原有数据", action="store_true")
    p.add_argument("-v", "--version", action="version", version="1.0.0919")
    p.add_argument("-k", "--kdata", help="获取股票日k线行情数据", action="store_true")
    p.add_argument("-m", "--minute", help="获取股票1分钟行情数据", action="store_true")
    p.add_argument("-t",
                   "--transaction",
                   help="获取股票分笔成交数据",
                   action="store_true")

    return p.parse_args()


if __name__ == "__main__":
    #freeze_support()
    sys.exit(main())  # pragma: no cover
"""
parser.add_argument("square", type=int,
                    help="display a square of a given number")
parser.add_argument("-v", "--verbosity", type=int, choices=[0, 1, 2],
                    help="increase output verbosity")
"""