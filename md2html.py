# coding=utf-8
"""
convert markdown to html
"""

import os
import time
import multiprocessing
from multiprocessing import Pool

import subprocess
from subprocess import Popen


def doconversion(f, folder):
    """
    @type f: str, unicode
    @type folder: str, unicode
    @return: None
    """
    try:
        print "conversion", folder, f
        cwf = os.path.join(os.getcwd(), folder)
        ebook = Popen(["ebook", "--f", "conv", "--source", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
        ebook.wait()
        so, se = ebook.communicate()
        res = str(so)+str(se)

        if "Error:" not in res:
            cnt = 0

            while not os.path.exists(os.path.join(cwf, "conv")):
                print folder, f, res
                time.sleep(0.1)
                cnt += 1

                if cnt > 10:
                    break

            cnt = 0

            while len(os.listdir(os.path.join(cwf, "conv"))) == 0:
                time.sleep(0.1)
                cnt += 1

                if cnt > 10:
                    break

            os.system("cp " + os.path.join(cwf, "conv/*.html") + " " + cwf)

            #Popen(["rm", "-Rf", os.path.join(cwf,"conv")], cwd=cwf).wait()
            #Popen(["rm", os.path.join(cwf,f)], cwd=cwf).wait()
    except Exception, e:
        print e
        raise


def convert(folder, ppool):
    """
    @type folder: str, unicode
    @type ppool: multiprocessing.Pool
    @return: None
    """
    numitems = len([x for x in os.listdir(folder) if x.endswith(".md")])

    if numitems > 0:
        print "convert:", folder, numitems, "items"

    fl = [x for x in os.listdir(folder)]
    for f in fl:
        if os.path.isdir(os.path.join(folder, f)):
            convert(os.path.join(folder, f), ppool)
        else:
            if f.endswith(".md"):
                fp = os.path.join(folder, f)
                c = open(fp).read()
                fp2 = open(fp, "w")
                fp2.write(c.replace(".md", ".html"))
                fp2.close()

                #doconversion(f, folder)
                ppool.apply_async(doconversion, (f, folder))

                # doconversion(f, folder)


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
            if f.endswith("html"):
                dname = os.path.join(folder, f)
                dname = dname.split("/")
                dname = dname[2:]
                dname = "/".join(dname)
                toc += '<a href="' + os.path.join(folder, f).replace("markdown", "").lstrip("/") + '">' + dname.replace("markdown", "").replace(".html", "").replace("_", " ").strip() + '</a><br/>\n'

    return toc


def make_toc(folder, bookname):
    """
    @type folder: str, unicode
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

    open(folder + "/" + bookname.replace("_", " ") + ".html", "w").write(toc)


def main():
    """
    main
    """
    os.system("rm markdown/*.html")
    booktitle = "".join(os.listdir("markdown"))
    try:

        #raw_input("press enter to continue with title " + booktitle + ": ")
        print 'booktitle', booktitle
    except KeyboardInterrupt:
        return

    ppool = Pool(multiprocessing.cpu_count())
    convert("markdown", ppool)
    ppool.close()
    ppool.join()
    make_toc("markdown", booktitle)


if __name__ == "__main__":
    main()
