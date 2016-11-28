#!/usr/bin/env python3
# coding=utf-8
"""
convert rst file

Usage:
  rst2md.py [options] <rstfile>

Options:
  -h --help     Show this screen.
  -c --clean    Remove the rst file if conversion is successful
  -f --force    Overwrite existing md files.
  -v --verbose  Print arguments
  -s --silent   Folder from where to run the command [default: .].
"""
import os

from arguments import Arguments


def make_nice_md(codebuf):
    """
    @type codebuf: str
    @return: None
    """
    codebuf.append("")
    cnt = 0
    codebuf2 = ""
    inblock = False

    for l in codebuf:
        if "```" in l:
            inblock = not inblock
        try:
            checkword = codebuf[cnt + 1]
        except IndexError:
            checkword = ""

        if "sourceCode" in l:
            if "$" in checkword:
                l = l.replace("sourceCode", "bash")
            elif ">" in checkword:
                l = l.replace("sourceCode", "bash")
            elif "<" in checkword:
                l = l.replace("sourceCode", "html")
            else:
                l = l.replace("sourceCode", "python")

        l = l.replace("*[", "##").replace("]*", "")

        if "-- " in l:
            l = l.replace("-- a", "\n.. a").strip()
            l = l.replace("-- :", "\n   :").strip()
            l = l.replace("\\", "")

            if ":target:" in l:
                l = "\n"
            else:
                l = "```\n" + l + "\n```"

        if inblock and "```" in l:
            if not l.strip().endswith("```"):
                l = l.replace("```", "```\n\n")

        codebuf2 += l
        cnt += 1

    codebuf2 = codebuf2.replace("```\n```", "")
    codebuf2 = codebuf2.replace("``````", "")
    return codebuf2


def rst2md(rstfile, silent=False, clean=False):
    """
    @type arg: str
    @return: None
    """

    if os.path.exists(rstfile):
        if not silent:
            print("\033[34m" + rstfile.lower(), "->\033[0;96m", rstfile.lower().replace(".rst", ".md") + "\033[0m")
        open(rstfile + ".tmp", "w").write(open(rstfile).read().replace(".. auto", "-- auto").replace("   :", "-- :").replace(".. _", ""))
        try:
            os.system("pandoc -f rst -t markdown_github " + rstfile + ".tmp" + " -o " + rstfile.lower().replace(".rst", ".md") + " ")

            # noinspection PyBroadException
            try:
                codebuf = [x for x in open(rstfile.lower().replace(".rst", ".md"))]
                codebuf2 = make_nice_md(codebuf)
                open(rstfile.lower().replace(".rst", ".md"), "w").write(codebuf2)
            except:
                codebuf = open(rstfile.lower().replace(".rst", ".md")).read()
                codebuf = codebuf.replace("sourceCode", "python")
                open(rstfile.lower().replace(".rst", ".md"), "w").write(codebuf)

            if clean is True:
                os.remove(rstfile)
        finally:
            os.remove(rstfile + ".tmp")


def main():
    """
    main
    """
    arg = Arguments(doc=__doc__)

    if arg.verbose is True:
        print(arg)

    if not os.path.exists(arg.rstfile):
        print("file does not exist")
        return

    if arg.force is False:
        if os.path.exists(arg.rstfile.replace(".rst", ".md")):
            print("\033[91m" + arg.rstfile.replace(".rst", ".md") + " exists\033[0m")
            return

    silent = arg.silent
    rstfile = arg.rstfile
    clean = arg.clean
    rst2md(rstfile, silent, clean)


if __name__ == "__main__":
    main()
