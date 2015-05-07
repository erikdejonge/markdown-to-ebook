#!/usr/bin/env python3
# coding=utf-8
"""
convert markdown to html
"""
from __future__ import absolute_import, division, unicode_literals
from future import standard_library

import multiprocessing
import os
import shutil
import subprocess
import uuid

from argparse import ArgumentParser
from threading import Lock
from subprocess import Popen
from consoleprinter import console, console_warning
from multiprocessing.dummy import Pool
standard_library.install_aliases()

g_lock = Lock()


def convert(folder, ppool, convertlist):
    """
    @type folder: str, unicode
    @type ppool: multiprocessing.Pool
    @return: None
    """
    fl = [x for x in os.listdir(folder)]
    for f in fl:
        if os.path.isdir(os.path.join(folder, f)):
            convert(os.path.join(folder, f), ppool, convertlist)
        else:
            if f.endswith(".md"):
                fp = os.path.join(folder, f)
                try:
                    c = open(str(fp), "rt").read()
                except UnicodeDecodeError:
                    c = open(str(fp), "rb").read()
                    try:
                        c = c.decode("utf-8")
                    except UnicodeDecodeError:
                        console_warning("could not read", fp)
                        c = None

                if c is not None:
                    fp2 = open(fp, "wt")
                    fp2.write(c.replace(".md", ".html"))
                    fp2.close()

                # doconversion(f, folder)
                numitems = len([x for x in os.listdir(folder) if x.endswith(".md")])

                # if numitems > 0:
                #    console "convert:", folder, numitems, "items"
                # ppool.apply_async(doconversion, (f, folder))
                convertlist.append((f, folder))


def convertmdcode(ext):
    """
    @type ext: str, unicode
    @return: None
    """
    for p in os.popen("find bookcv -name  '*.md" + ext + "' -type f").read().split("\n"):
        if os.path.exists(p):
            if ext.lower().strip() == "js":
                extcss = "javascript"
            elif ext.lower().strip() == "h":
                extcss = "c"
            elif ext.lower().strip() == "sh":
                extcss = "bash"
            elif ext.lower().strip() == "py":
                extcss = "python"
            else:
                extcss = ext

            open(p.replace(".md" + ext, ".md"), "w").write("```" + extcss + "\n" + open(p).read() + "```")
            os.remove(p)


def doconversion(f, folder):
    """
    @type f: str, unicode
    @type folder: str, unicode
    @return: None
    """
    global g_lock
    try:
        if "tempfolder" in folder:
            console("searching tempfolder, skipping", folder)
            return ""

        tempfolder = "tempfolder" + uuid.uuid4().hex
        cwf = os.path.join(os.getcwd(), folder)
        try:
            g_lock.acquire()

            if os.path.exists(os.path.join(cwf, f.replace(".md", ".html"))):
                console("file exists skipping" + os.path.join(cwf, f.replace(".md", ".html")), color="green")
                return ""

            ebook = Popen(["ebook", "--f", tempfolder, "--source", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
            ebook.wait()
            so, se = ebook.communicate()
            so = so.decode("utf-8")
            se = se.decode("utf-8")
        finally:
            g_lock.release()

        res = str(so) + str(se)

        if len(res.strip()) != 0 or ebook.returncode != 0:
            console("returncode:", ebook.returncode)
            console("res:", res)
        else:
            if os.path.exists(os.path.join(cwf, tempfolder + "/" + f.replace(".md", ".html"))):
                console("writing:", os.path.join(cwf, f.replace(".md", ".html")))
                shutil.copyfile(os.path.join(cwf, tempfolder + "/" + f.replace(".md", ".html")), os.path.join(cwf, f.replace(".md", ".html")))

        return ""
    except Exception as e:
        raise

        return str(e)


def got_books_to_convert(converted):
    """
    got_books_to_convert
    """
    dirfiles = os.listdir("bookcvwait")
    currentdir = None

    if len(dirfiles) > 0:
        for i in dirfiles:
            if os.path.isdir(os.path.join("bookcvwait", i)):
                if i not in converted and currentdir is None:
                    currentdir = i
                    converted.append(i)

    return currentdir


def main():
    """
    main
    """
    parser = ArgumentParser()
    parser.add_argument("-c", "--convertcode", dest="convertcode", help="Convert sourcecode (py, go, coffee and js) to md", action='store_true')
    parser.add_argument("-r", "--restorecode", dest="restorecode", help="Reset the converted code from the bookcv archive", action='store_true')
    args, unknown = parser.parse_known_args()

    if args.restorecode:
        console("busy restoring bookcv folder.", color="green")

        if os.path.exists("bookcv"):
            shutil.rmtree("bookcv")

        os.system("pigz -d bookcvwait.tar.gz&&tar -xf bookcvwait.tar")

    if not os.path.exists("bookcv"):
        os.mkdir("bookcv")

    if len(os.listdir("./bookcvwait")) == 0:
        console("bookcvwait folder is empty", color="red")
        return

    os.system("rm -f bookcvwait.tar.gz; tar -cf bookcvwait.tar ./bookcvwait; pigz bookcvwait.tar;")
    convertcode = args.convertcode
    os.system("rm -Rf ./bookcv/*")
    converted = []
    book = got_books_to_convert(converted)

    while book:
        os.system("cp -r bookcvwait/" + book + " ./bookcv/")
        os.system("sudo find ./bookcv/* -name '.git' -exec rm -rf {} \; 2> /dev/null")
        os.system("sudo find ./bookcv/* -name '.hg' -exec rm -rf {} \; 2> /dev/null")
        dirfiles = os.listdir("bookcv")
        dirforname = []

        if len(dirfiles) > 1:
            for i in dirfiles:
                if os.path.isdir(os.path.join("bookcv", i)):
                    dirforname.append(i)

            if len(dirforname) > 1:
                console("more then 1 folder found in the bookcv directory, please correct this (one folder is one book)", color="red")
                return

            if len(dirforname) == 0:
                console("no folders found in the bookcv directory, please correct this (one folder is one book)", color="red")
                return
        else:
            dirforname = dirfiles

        booktitle = "".join(dirforname)
        specialchar = False
        scs = [" ", "&", "?"]

        for c in scs:
            if c in booktitle.strip():
                specialchard = {1: c,
                                2: booktitle}

                console("directory with special char", specialchard, color="red")
                specialchar = True
                break

        if specialchar is True:
            return

        console(booktitle, color="green")
        console("converting", color="yellow")
        source_file_rm_or_md(convertcode, "sh")
        source_file_rm_or_md(convertcode, "markdown")
        source_file_rm_or_md(convertcode, "rst")
        source_file_rm_or_md(convertcode, "h")
        source_file_rm_or_md(convertcode, "py")
        source_file_rm_or_md(convertcode, "go")
        source_file_rm_or_md(convertcode, "js")
        source_file_rm_or_md(convertcode, "json")
        source_file_rm_or_md(convertcode, "coffee")
        source_file_rm_or_md(convertcode, "c")
        exit(1)
        console("cleaning", color="yellow")
        os.system("cd bookcv/*&&sudo find . -type l -exec rm -f {} \; 2> /dev/null")
        os.system("cd bookcv/*&&sudo find . -name 'man' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookcv/*&&sudo find . -name 'commands' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookcv/*&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookcv/*&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
        os.system("sudo find bookcv -depth -empty -delete")
        os.system("""find bookcv/ ! -name '*.*' -type f -exec bash -c 'mv "$1" "$1.txt"' -- {} \; 2> /dev/null""")
        os.system("""find bookcv/ -name '*.txt' -type f -exec bash -c 'mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")
        os.system("""find bookcv/ -name '*.rst' -type f -exec bash -c 'mv "$1" "${1/.rst/.md}"' -- {} \; 2> /dev/null""")
        os.system("cd bookcv/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")

        console("pandoc", color="yellow")
        ppool = Pool(1)
        convertlist = []
        convert("bookcv", ppool, convertlist)

        for i in convertlist:
            res = startconversion(i)

            if len(res.strip()) > 0:
                console(res)

        ppool.close()
        ppool.join()

        exit(1)
        os.system("cd bookcv/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
        make_toc("bookcv", booktitle)
        console("converting to ebook", color="yellow")
        pdf = False
        os.system("/Applications/calibre.app/Contents/MacOS/ebook-convert ./bookcv/" + booktitle.replace("_", "\\ ") + ".html ./bookcv/" + booktitle.replace("_", "\\ ") + ".mobi -v --authors=edj")
        if pdf:
            os.system("/Applications/calibre.app/Contents/MacOS/ebook-convert ./bookcv/" + booktitle.replace("_", "\\ ") + ".html ./bookcv/" + booktitle.replace("_", "\\ ") + ".pdf \
            --paper-size=a4  --pdf-serif-family=\"Helvetica Neue\" --pdf-sans-family=\"Helvetica\" --pdf-standard-font=\"serif\" --pdf-mono-family=\"Source Code Pro Regular\" --pdf-mono-font-size=\"12\" --pdf-default-font-size=\"12\" -v --authors=edj")

            # os.system("mv ./bookcv/*.pdf ./books/")

        # os.system("rm -Rf ./bookcv/*")
        os.system("rm -Rf ./books/" + booktitle)
        os.system("mv -f ./bookcv/* ./books/")
        book = got_books_to_convert(converted)

        if book:
            console("-------")

    os.system("rm -Rf ./bookcvwait/*")
from rst2md import make_nice_md
from mdcodeblockcorrect import correct_codeblocks


def make_toc(folder, bookname):
    """
    @type folder: str, unicode
    @type bookname: str, unicode
    @return: None
    """
    toc = """
        <html>
           <body>
             <h1>Table of Contents</h1>
             <p style="text-indent:0pt">
     """
    toc = toc_files(folder, toc)
    toc += """
             </p>
           </body>
        </html>"""

    open(folder + "/" + bookname.replace("_", " ") + ".html", "wt").write(toc)


def source_file_rm_or_md(convertcode, targetextension):
    """
    @type convertcode: str, unicode
    @type targetextension: str, unicode
    @return: None
    """
    if targetextension == "markdown":
        for p in os.popen("find bookcv -name  *.markdown -type f").read().split("\n"):
            if len(p.strip()) > 0:
                if os.path.exists(p):
                    console("rst2md:", p, "->", p.lower().replace(".markdown", ".md"))
                    os.rename(p, p.lower().replace(".markdown", ".md"))

    elif targetextension == "rst":
        console("converting rst")

        for p in os.popen("find bookcv -name  *.rst -type f").read().split("\n"):
            if len(p.strip()) > 0:
                if os.path.exists(p):
                    console("rst2md:", p, "->", p.lower().replace(".rst", ".md"))

                    if not os.path.exists(p.lower().replace(".rst", ".md")):
                        bufdotdot = [x for x in open(p)]
                        bufdotdot2 = []

                        for bd in bufdotdot:
                            bd = bd.rstrip()
                            if bd.startswith("    #"):

                                bd = "\n"+bd.replace("   #", '')+"\n\n"

                            if ":class:" in bd:
                                bd = bd.replace(":class:", "").replace("`", "")

                            if not bd.strip().startswith(".."):
                                bufdotdot2.append(bd)

                        open(p, "w").write("\n".join(bufdotdot2))

                        os.system("pandoc -f rst -t markdown_github " + p + " -o " + p.lower().replace(".rst", ".md") + " 2> /dev/null")
                        try:
                            codebuf = [x for x in open(p.lower().replace(".rst", ".md"))]

                            codebuf2 = make_nice_md(codebuf)
                            open(p.lower().replace(".rst", ".md"), "w").write(codebuf2)

                        except BaseException as e:
                            print("\033[31m", e, "\033[0m")
                            codebuf = open(p.lower().replace(".rst", ".md")).read()
                            codebuf = codebuf.replace("sourceCode", "python")
                            open(p.lower().replace(".rst", ".md"), "w").write(codebuf)
                        try:
                            cnt = correct_codeblocks(p.lower().replace(".rst", ".md"))
                            print("\033[94m" + p.lower().replace(".rst", ".md"), "->\033[0;96m " + str(cnt) + " code blocks corrected\033[0m")
                        except BaseException as e:
                            print("\033[31m", e, "\033[0m")

                        codebuf = [x for x in open(p.lower().replace(".rst", ".md"))]
                        codebuf.append("")
                        codebuf2 = make_nice_md(codebuf)
                        open(p.lower().replace(".rst", ".md"), "w").write(codebuf2)
                        cnt = correct_codeblocks(p.lower().replace(".rst", ".md"), force=True)
                        print("\033[94m" + p.lower().replace(".rst", ".md"), "->\033[0;96m " + str(cnt) + " code blocks corrected\033[0m")


                    os.remove(p)

        return
    else:
        if convertcode:
            os.system("""find bookcv/ -name '*.""" + targetextension + """' -type f -exec bash -c 'mv "$1" "${1/.""" + targetextension + """/.md""" + targetextension + """}"' -- {} \; 2> /dev/null""")
            convertmdcode(targetextension)
        else:
            os.system("cd bookcv/*&&sudo find . -name '*." + targetextension + "' -exec rm -rf {} \; 2> /dev/null")


def startconversion(t):
    """
    @type t: str, unicode
    @return: None
    """
    return doconversion(t[0], t[1])


def toc_files(folder, toc):
    """
    @type folder: str, unicode
    @type toc: str, unicode
    @return: None
    """
    fl = [x for x in os.listdir(folder)]
    for f in fl:
        if os.path.isdir(os.path.join(folder, f)):
            toc = toc_files(os.path.join(folder, f), toc)
        else:
            if f.endswith(".html"):
                dname = os.path.join(folder, f)
                dname = dname.split("/")
                dname = dname[2:]
                dname = "/".join(dname)
                toc += '<a href="' + os.path.join(folder, f).replace("bookcv", "").lstrip("/") + '">' + dname.replace("bookcv", "").replace(".html", "").replace("_", " ").strip() + '</a><br/>\n'

    return toc


if __name__ == "__main__":
    main()
