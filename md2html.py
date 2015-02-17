# coding=utf-8
"""
convert markdown to html
"""

import os

def convert(folder):
    """
    convert
    """
    numitems = len([x for x in os.listdir(folder) if x.endswith("md")])
    if numitems>0:
        print "convert:", folder, numitems, "items"
    fl = [x for x in os.listdir(folder)]
    for f in fl:
        if os.path.isdir(os.path.join(folder, f)):
            convert(os.path.join(folder, f))
        else:
            if f.endswith("md"):
                #print os.system("cd "+folder+"&&ls"), f
                os.system("cd "+folder+"&&ebook --f conv --source ./" + f+"&&mv conv/*.html .&&rm -Rf conv&&rm ./"+f)



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
                toc += '<a href="' + os.path.join(folder, f).replace("markdown", "").lstrip("/") + '">' + dname.replace("markdown", "").replace(".html", "").replace("/", " / ").replace("-", " ").replace("_", " ").strip() + '</a><br/>\n'

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

    open(folder + "/"+bookname+".html", "w").write(toc)


def main():
    """
    main
    """
    convert("markdown")
    make_toc("markdown", "Github readmes")



if __name__ == "__main__":
    main()
