#!/usr/bin/env python3
# coding=utf-8
"""
Get readmes

Usage:
  get_readmes.py [options] [--] <target_dir>

Options:
  -h --help     Show this screen.

Description:
target_dir   Folder to check

Active8 (18-05-15)
author: erik@a8.nl
license
"""
import os
import arguments


def main():
    """
    main
    """
    arg = arguments.Arguments(__doc__)
    targetdir = os.path.expanduser(arg.target_dir)
    os.makedirs(os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/"), exist_ok=True)
    os.chdir(os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme"))

    os.system("rm -Rf ~/workspace/markdown-to-ebook/bookcvwait/githubreadme/*")
    bs = os.path.expanduser(targetdir)
    check_folder(bs)


def check_folder(bs):
    """
    @type bs: list
    @return: None
    """
    for d in os.listdir(bs):

        fp = os.path.join(bs, d)
        rm = os.path.join(fp, "readme.md")
        np = os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/") + d + "/readme.md"

        if not os.path.exists(rm):
            rm = os.path.join(fp, "readme.rst")
            np = os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/") + d + "/readme.rst"

        if os.path.exists(rm):
            c = open(rm).read()
            print("\033[94m>", rm ,"\033[0m")

            os.makedirs(os.path.dirname(np), exist_ok=True)
            open(np, "w").write(c)
            pass

        if os.path.exists(np) and np.endswith("rst"):
            os.system("python3 ~/workspace/devenv/rst2md.py -cf " + np)


        if os.path.isdir(fp):
            print("\033[95m>", d ,"\033[0m")
            check_folder(fp)

if __name__ == "__main__":
    main()
