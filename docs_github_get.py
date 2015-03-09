# coding=utf-8
"""
convert bookconversionfolder/Github_Docs_Readmes to html
"""
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import division
from __future__ import absolute_import
from builtins import open
from future import standard_library
standard_library.install_aliases()

import os


def get_folder(d, fp):
    """
    @type d: str, unicode
    @type fp: str, unicode
    @return: None
    """
    if not os.path.exists("bookconversionfolder/Github_Docs_Readmes/" + d):
        os.mkdir("bookconversionfolder/Github_Docs_Readmes/" + d)

    # open("bookconversionfolder/Github_Docs_Readmes/" + d + "/" + d + ".md", "w").write(c)
    os.system("sudo cp -r " + fp + " bookconversionfolder/Github_Docs_Readmes/")
    os.system("sudo rm -Rf bookconversionfolder/Github_Docs_Readmes/" + d + "/.git")


def main():
    """
    main
    """
    os.system("rm -f bookconversionfolder/*.html")
    special_interests = ["kubernetes", "coreos", "docker", "redis", "etcd", "celery"]
    os.system("sudo rm -Rf bookconversionfolder/Github_Docs_Readmes&&mkdir -p bookconversionfolder/Github_Docs_Readmes/_Readmes")
    bs = os.path.expanduser("~/workspace/github")

    for d in os.listdir(bs):
        have_docs = False
        fp = os.path.join(os.path.expanduser("~/workspace/github"), d)
        print(fp)
        if os.path.isdir(fp):
            rm1 = os.path.join(fp, "readme.md")
            rm2 = os.path.join(fp, "readme.txt")
            rm3 = os.path.join(fp, "readme.rst")
            rm4 = os.path.join(fp, "readme")
            docs = os.path.join(fp, "docs")
            docu = os.path.join(fp, "Documentation")

            for interest in special_interests:
                if interest.lower() in fp.lower():
                    # raise AssertionError(str(interest))
                    get_folder(d, fp)
                    have_docs = True

            ce = False

            if (os.path.exists(rm1) or os.path.exists(rm2) or os.path.exists(rm3) or os.path.exists(rm4)) and not have_docs:
                c = None
                for rm in [rm1, rm2, rm3, rm4]:
                    if os.path.exists(rm):
                        ce = True
                        c = open(rm).read()

                if ce:
                    os.mkdir("bookconversionfolder/Github_Docs_Readmes/" + d)
                    open("bookconversionfolder/Github_Docs_Readmes/" + d + "/" + d + ".md", "w").write(c)

                if os.path.exists(docs):
                    get_folder(d, fp)
                    have_docs = True

                if os.path.exists(docu):
                    get_folder(d, fp)
                    have_docs = True

            os.mkdir("bookconversionfolder/Github_Docs_Readmes/_Readmes/" + d)
            os.system("cp bookconversionfolder/Github_Docs_Readmes/" + d + "/readme* bookconversionfolder/Github_Docs_Readmes/_Readmes/" + d + "/ 2> /dev/null")
            os.system("cp bookconversionfolder/Github_Docs_Readmes/" + d + "/README* bookconversionfolder/Github_Docs_Readmes/_Readmes/" + d + "/ 2> /dev/null")
    os.system("rm -Rf bookconversionfolder/Github_Docs_Readmes/_Readmes")
    os.system("sudo chown -R `whoami` bookconversionfolder/Github_Docs_Readmes")
    print("delete py")
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name '*.py' -exec rm -rf {} \; 2> /dev/null")
    print("delete go")
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name '*.go' -exec rm -rf {} \; 2> /dev/null")
    print("delete js")
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name '*.js*' -exec rm -rf {} \; 2> /dev/null")
    print('delete html')
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name '*.html' -exec rm -rf {} \; 2> /dev/null")
    print("delete godeps")
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
    os.system("cd bookconversionfolder/Github_Docs_Readmes&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
    print("delete empty folders")
    os.system("sudo find bookconversionfolder -depth -empty -delete")
    print("convert txt to md")
    os.system("""find bookconversionfolder/ -name '*.txt' -type f -exec bash -c 'echo $1&&mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")


if __name__ == "__main__":
    main()
