# -*- coding: utf-8 -*-

import copy
import os
import sys
from pypdf import PdfReader, PdfWriter

def tran(src, dest):
    print (src)
    reader = PdfReader(src)
    writer = PdfWriter()

    for p in reader.pages:
        p1 = copy.copy(p)
        p1.mediabox.upper_right = (
            p1.mediabox.right / 2,
            p1.mediabox.top,
        )
        writer.add_page(p1)

        p2 = copy.copy(p)
        p2.mediabox.upper_left = (
            p2.mediabox.right / 2,
            p2.mediabox.top,
        )
        writer.add_page(p2)

    with open(dest, "wb") as fp:
        writer.write(fp)

    return 0

def mulu():
    path = r"D:\en\Английский Клуб_Айрис-пресс.pdf"

    for root, _, files in os.walk(path):
        dest = root.replace("Английский Клуб_Айрис-пресс.pdf", "out-pdf") 
        print (root)
        if not os.path.exists(path):
            os.makedirs(path)
        for f  in files:
            tran(os.path.join(root, f), os.path.join(dest, f))

def main():
    mulu()
    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
