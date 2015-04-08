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
                    c = open(str(fp),"rt").read()
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
                #ppool.apply_async(doconversion, (f, folder))
                convertlist.append((f, folder))


def convertmdcode(ext):
    """
    @type ext: str, unicode
    @return: None
    """
    for p in os.popen("find bookconversionfolder -name  '*.md" + ext + "' -type f").read().split("\n"):
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
    dirfiles = os.listdir("bookconversionswaiting")
    currentdir = None

    if len(dirfiles) > 0:
        for i in dirfiles:
            if os.path.isdir(os.path.join("bookconversionswaiting", i)):
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
    parser.add_argument("-r", "--restorecode", dest="restorecode", help="Reset the converted code from the bookconversionfolder archive", action='store_true')
    args, unknown = parser.parse_known_args()

    if args.restorecode:
        console("busy restoring bookconversionfolder folder.", color="green")

        if os.path.exists("bookconversionfolder"):
            shutil.rmtree("bookconversionfolder")

        os.system("pigz -d bookconversionswaiting.tar.gz&&tar -xf bookconversionswaiting.tar")

    if not os.path.exists("bookconversionfolder"):
        os.mkdir("bookconversionfolder")

    if len(os.listdir("./bookconversionswaiting")) == 0:
        console("bookconversionswaiting folder is empty", color="red")
        return

    os.system("rm -f bookconversionswaiting.tar.gz; tar -cf bookconversionswaiting.tar ./bookconversionswaiting; pigz bookconversionswaiting.tar;")
    convertcode = args.convertcode
    os.system("rm -Rf ./bookconversionfolder/*")
    converted = []
    book = got_books_to_convert(converted)

    while book:
        os.system("cp -r bookconversionswaiting/" + book + " ./bookconversionfolder/")
        os.system("sudo find ./bookconversionfolder/* -name '.git' -exec rm -rf {} \; 2> /dev/null")
        os.system("sudo find ./bookconversionfolder/* -name '.hg' -exec rm -rf {} \; 2> /dev/null")
        dirfiles = os.listdir("bookconversionfolder")
        dirforname = []

        if len(dirfiles) > 1:
            for i in dirfiles:
                if os.path.isdir(os.path.join("bookconversionfolder", i)):
                    dirforname.append(i)

            if len(dirforname) > 1:
                console("more then 1 folder found in the bookconversionfolder directory, please correct this (one folder is one book)", color="red")
                return

            if len(dirforname) == 0:
                console("no folders found in the bookconversionfolder directory, please correct this (one folder is one book)", color="red")
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
        source_file_rm_or_md(convertcode, "rst")
        source_file_rm_or_md(convertcode, "h")
        source_file_rm_or_md(convertcode, "py")
        source_file_rm_or_md(convertcode, "go")
        source_file_rm_or_md(convertcode, "js")
        source_file_rm_or_md(convertcode, "json")
        source_file_rm_or_md(convertcode, "coffee")
        source_file_rm_or_md(convertcode, "c")
        console("cleaning", color="yellow")
        os.system("cd bookconversionfolder/*&&sudo find . -type l -exec rm -f {} \; 2> /dev/null")
        os.system("cd bookconversionfolder/*&&sudo find . -name 'man' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookconversionfolder/*&&sudo find . -name 'commands' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookconversionfolder/*&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
        os.system("cd bookconversionfolder/*&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
        os.system("sudo find bookconversionfolder -depth -empty -delete")
        os.system("""find bookconversionfolder/ ! -name '*.*' -type f -exec bash -c 'mv "$1" "$1.txt"' -- {} \; 2> /dev/null""")
        os.system("""find bookconversionfolder/ -name '*.txt' -type f -exec bash -c 'mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")
        os.system("""find bookconversionfolder/ -name '*.rst' -type f -exec bash -c 'mv "$1" "${1/.rst/.md}"' -- {} \; 2> /dev/null""")
        os.system("cd bookconversionfolder/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
        console("pandoc", color="yellow")
        ppool = Pool(multiprocessing.cpu_count())
        convertlist = []
        convert("bookconversionfolder", ppool, convertlist)

        for i in convertlist:
            res = startconversion(i)

            if len(res.strip()) > 0:
                console(res)

        ppool.close()
        ppool.join()
        os.system("cd bookconversionfolder/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
        make_toc("bookconversionfolder", booktitle)
        console("converting to ebook", color="yellow")
        pdf = True
        os.system("/Applications/calibre.app/Contents/MacOS/ebook-convert ./bookconversionfolder/" + booktitle.replace("_", "\\ ") + ".html ./bookconversionfolder/" + booktitle.replace("_", "\\ ") + ".mobi -v --authors=edj")


        if pdf:
            os.system("/Applications/calibre.app/Contents/MacOS/ebook-convert ./bookconversionfolder/" + booktitle.replace("_", "\\ ") + ".html ./bookconversionfolder/" + booktitle.replace("_", "\\ ") + ".pdf \
            --paper-size=a4  --pdf-serif-family=\"Helvetica Neue\" --pdf-sans-family=\"Helvetica\" --pdf-standard-font=\"serif\" --pdf-mono-family=\"Source Code Pro Regular\" --pdf-mono-font-size=\"12\" --pdf-default-font-size=\"12\" -v --authors=edj")
            #os.system("mv ./bookconversionfolder/*.pdf ./books/")

        #os.system("rm -Rf ./bookconversionfolder/*")
        os.system("rm -Rf ./books/"+booktitle)
        os.system("mv -f ./bookconversionfolder/* ./books/")
        book = got_books_to_convert(converted)

        if book:
            console("-------")

    os.system("rm -Rf ./bookconversionswaiting/*")


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
    if targetextension == "rst":
        console("converting rst")

        for p in os.popen("find bookconversionfolder -name  *.rst -type f").read().split("\n"):
            if len(p.strip()) > 0:
                if os.path.exists(p):
                    console("rst2md:", p, "->", p.lower().replace(".rst", ".md"))

                    if not os.path.exists(p.lower().replace(".rst", ".md")):
                        os.system("pandoc -f rst -t markdown_github " + p + " -o " + p.lower().replace(".rst", ".md"))

                    os.remove(p)

        return
    else:
        if convertcode:
            os.system("""find bookconversionfolder/ -name '*.""" + targetextension + """' -type f -exec bash -c 'mv "$1" "${1/.""" + targetextension + """/.md""" + targetextension + """}"' -- {} \; 2> /dev/null""")
            convertmdcode(targetextension)
        else:
            os.system("cd bookconversionfolder/*&&sudo find . -name '*." + targetextension + "' -exec rm -rf {} \; 2> /dev/null")


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
                toc += '<a href="' + os.path.join(folder, f).replace("bookconversionfolder", "").lstrip("/") + '">' + dname.replace("bookconversionfolder", "").replace(".html", "").replace("_", " ").strip() + '</a><br/>\n'

    return toc


if __name__ == "__main__":
    main()
