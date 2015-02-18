# coding=utf-8
"""
convert markdown to html
"""

import os
import shutil
import uuid
import time
import multiprocessing
from multiprocessing.dummy import Pool

import subprocess
from subprocess import Popen


def doconversion_md2html(f, folder):
    """
    @type f: str, unicode
    @type folder: str, unicode
    @return: None
    """
    try:
        cwf = os.path.join(os.getcwd(), folder)
        #ebook = Popen(["ebook", "--f", tempfolder, "--source", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
        ebook = Popen(["md2html", "-p", "-f", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
        print folder, f
        ebook.wait()
        out, err = ebook.communicate()
        out = [x for x in out.split("\n") if "Completed" in x]
        hf = None
        if len(out)>0:
            out = out[0].split(" ")
            if len(out) > 1:
                hf = out[1].replace("'", "")
        if hf is not None:
            c = open(hf).read()
            l = ['<div>Loading...</div>',
                 '<link type="text/css" rel="stylesheet" href="http://jasonm23.github.com/markdown-css-themes/swiss.css">',
                 '<textarea id="mdstr" style=display:none>',
                 '</textarea>',
                 '    <script src="https://raw.github.com/evilstreak/markdown-js/master/lib/markdown.js"></script>\n    <script>\n      var mdstr = document.getElementById(\'mdstr\').value;\n      var html = markdown.toHTML(mdstr);\n      document.body.innerHTML = html;\n    </script>\n']
            for i in l:
                c = c.replace(i, "")
            open(hf, "w").write(c)
    except Exception, e:
        print e
        raise

def doconversion(f, folder):
    """
    @type f: str, unicode
    @type folder: str, unicode
    @return: None
    """
    try:
        if "tempfolder" in folder:
            raise AssertionError("searching tempfolder")

        tempfolder = "tempfolder"+uuid.uuid4().hex
        cwf = os.path.join(os.getcwd(), folder)
        ebook = Popen(["ebook", "--f", tempfolder, "--source", "./" + f], stderr=subprocess.PIPE, stdout=subprocess.PIPE, cwd=cwf)
        ebook.wait()
        so, se = ebook.communicate()
        res = str(so)+str(se)

        if len(res.strip())!=0:
            print 20*" ", res
        else:
            print os.path.join(cwf, f.replace(".md", ".html"))
            shutil.copyfile(os.path.join(cwf, tempfolder+"/"+f.replace(".md", ".html")), os.path.join(cwf, f.replace(".md", ".html")))
            
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

    #if numitems > 0:
    #    print "convert:", folder, numitems, "items"

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
                #exit(1)
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

    print "delete py"
    os.system("cd markdown/*&&sudo find . -name '*.py' -exec rm -rf {} \; 2> /dev/null")
    print "delete go"
    os.system("cd markdown/*&&sudo find . -name '*.go' -exec rm -rf {} \; 2> /dev/null")
    print "delete js"
    os.system("cd markdown/*&&sudo find . -name '*.js*' -exec rm -rf {} \; 2> /dev/null")
    print 'delete html'
    os.system("cd markdown/*&&sudo find . -name '*.html' -exec rm -rf {} \; 2> /dev/null")
    print "delete godeps"
    os.system("cd markdown/*&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
    os.system("cd markdown/*&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
    print "delete empty folders"
    os.system("sudo find markdown -depth -empty -delete")
    print "convert txt to md"
    os.system("""find markdown/ -name '*.txt' -type f -exec bash -c 'echo $1&&mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")
    booktitle = "".join(os.listdir("markdown"))
    try:

        #raw_input("press enter to continue with title " + booktitle + ": ")
        print 'booktitle', booktitle
    except KeyboardInterrupt:
        return

    ppool = Pool(multiprocessing.cpu_count()*2)
    convert("markdown", ppool)
    ppool.close()
    ppool.join()
    os.system("cd markdown/*&&sudo find . -name 'tempfolder*' -exec rm -rf {} \; 2> /dev/null")
    make_toc("markdown", booktitle)


if __name__ == "__main__":
    main()
