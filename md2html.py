# coding=utf-8
"""
convert markdown to html
"""

import os
import shutil
import uuid
import multiprocessing
from multiprocessing.dummy import Pool

import subprocess
from subprocess import Popen
from threading import Lock

g_lock = Lock()


def doconversion(f, folder):
    """
    @type f: str, unicode
    @type folder: str, unicode
    @return: None
    """
    global g_lock
    try:
        if "tempfolder" in folder:
            print "searching tempfolder, skipping", folder
            return

        tempfolder = "tempfolder" + uuid.uuid4().hex
        cwf = os.path.join(os.getcwd(), folder)

        if os.path.exists(os.path.join(cwf, f.replace(".md", ".html"))):
            print "file exists skipping", os.path.join(cwf, f.replace(".md", ".html"))
            return
        try:
            g_lock.acquire()
            ebook = Popen(["ebook", "--f", tempfolder, "--source", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
            ebook.wait()
            so, se = ebook.communicate()
        finally:
            g_lock.release()

        res = str(so) + str(se)
        if len(res.strip()) != 0:
            print 20 * " ", res
        else:
            print os.path.join(cwf, f.replace(".md", ".html"))
            shutil.copyfile(os.path.join(cwf, tempfolder + "/" + f.replace(".md", ".html")), os.path.join(cwf, f.replace(".md", ".html")))
    except Exception, e:
        print e
        raise


def convert(folder, ppool):
    """
    @type folder: str, unicode
    @type ppool: multiprocessing.Pool
    @return: None
    """
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

                # doconversion(f, folder)
                numitems = len([x for x in os.listdir(folder) if x.endswith(".md")])

                if numitems > 0:
                    print "convert:", folder, numitems, "items"

                ppool.apply_async(doconversion, (f, folder))


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
                toc += '<a href="' + os.path.join(folder, f).replace("markdown", "").lstrip("/") + '">' + dname.replace("markdown", "").replace(".html", "").replace("_", " ").strip() + '</a><br/>\n'

    return toc


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

    open(folder + "/" + bookname.replace("_", " ") + ".html", "w").write(toc)


def main():
    """
    main
    """
    if not os.path.exists("markdown"):
        print "no markdown folder"
        return

    if len(os.listdir("./markdown")) == 0:
        print "markdown folder is empty"
        return

    os.system("rm -f markdown.tar.gz; tar -cf markdown.tar ./markdown; pigz markdown.tar; rm -f markdown/*.html")
    booktitle = "".join(os.listdir("markdown"))
    specialchar = False
    scs = [" ", "&", "?"]

    for c in scs:
        if c in booktitle.strip():
            specialchard = {1: c,
                            2: booktitle}

            print "directory with special char", specialchard
            specialchar = True
            break

    if specialchar is True:
        return

    print 'booktitle', booktitle
    print "== cleaning =="
    print "delete symlinks"
    os.system("cd markdown/*&&sudo find . -type l -exec rm -f {} \;")
    print "delete tempfolders"
    os.system("cd markdown/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
    print "delete py"
    os.system("cd markdown/*&&sudo find . -name '*.py' -exec rm -rf {} \; 2> /dev/null")
    print "delete go"
    os.system("cd markdown/*&&sudo find . -name '*.go' -exec rm -rf {} \; 2> /dev/null")
    print "delete js"
    os.system("cd markdown/*&&sudo find . -name '*.js*' -exec rm -rf {} \; 2> /dev/null")
    print "delete man"
    os.system("cd markdown/*&&sudo find . -name 'man' -exec rm -rf {} \; 2> /dev/null")
    print 'delete commands'
    os.system("cd markdown/*&&sudo find . -name 'commands' -exec rm -rf {} \; 2> /dev/null")
    print "delete godeps"
    os.system("cd markdown/*&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
    os.system("cd markdown/*&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
    print "delete empty folders"
    os.system("sudo find markdown -depth -empty -delete")
    print "convert txt to md"
    os.system("""find markdown/ -name '*.txt' -type f -exec bash -c 'echo $1&&mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")
    os.system("""find markdown/ -name '*.rst' -type f -exec bash -c 'echo $1&&mv "$1" "${1/.rst/.md}"' -- {} \; 2> /dev/null""")
    print "== done cleaning =="
    ppool = Pool(multiprocessing.cpu_count())
    convert("markdown", ppool)
    ppool.close()
    ppool.join()
    os.system("cd markdown/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
    make_toc("markdown", booktitle)


if __name__ == "__main__":
    main()
