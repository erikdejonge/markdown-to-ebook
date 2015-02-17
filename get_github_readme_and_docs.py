# coding=utf-8
"""
convert markdown to html
"""

import os


def get_folder(c, d, fp):
    if not os.path.exists("github/" + d):
        os.mkdir("github/" + d)
    open("github/" + d + "/" + d + ".md", "w").write(c)
    os.system("cp -r " + fp + " github/")
    os.system("rm -Rf github/" + d + "/.git")
    os.system("cd github&&find . -name '*.html' -exec rm -rf {} \;")
    os.system("cd github&&find . -name 'Godeps*'  -exec rm -rf {} \;")
    os.system("cd github&&find . -name '_Godeps*'  -exec rm -rf {} \;")


def main():
    """
    main
    """
    os.system("rm -Rf github/*")
    bs = os.path.expanduser("~/workspace")
    for d in os.listdir(bs):
        fp = os.path.join(os.path.expanduser("~/workspace/github"), d)
        print fp
        rm = os.path.join(fp, "readme.md")
        docs = os.path.join(fp, "docs")
        docu = os.path.join(fp, "Documentation")

        if os.path.exists(rm):
            c = open(rm).read()

            os.mkdir("github/" + d)
            open("github/" + d + "/" + d + ".md", "w").write(c)

            if os.path.exists(docs):
                get_folder(c, d, fp)


            if os.path.exists(docu):
                get_folder(c, d, fp)

if __name__ == "__main__":
    main()
