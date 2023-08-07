# -*- coding: utf-8 -*-

import logging
import sys
from cleo.application import Application
from .command import FetchCommand, DemoCommand


logger = logging.getLogger(__name__)


def main():
    logging.basicConfig(
        # filename="run.log",
        # filemode="w",
        format="%(asctime)s %(name)s:%(levelname)s:%(message)s",
        datefmt="%Y-%M-%d %H:%M:%S",
        #　level=logging.DEBUG,
        level=logging.INFO,
    )

    cmds = [FetchCommand(), DemoCommand()]

    name = "Stock_Data_Jisilu-cli"
    version = "1.0"
    app = Application(name=name, version=version)

    for cmd in cmds:
        app.add(cmd)

    app.run()
    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
