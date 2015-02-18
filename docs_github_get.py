# coding=utf-8
"""
convert markdown/Github_Docs_Readmes to html
"""

import os


def get_folder(c, d, fp):
    """
    @type c: str, unicode
    @type d: str, unicode
    @type fp: str, unicode
    @return: None
    """
    if not os.path.exists("markdown/Github_Docs_Readmes/" + d):
        os.mkdir("markdown/Github_Docs_Readmes/" + d)

    open("markdown/Github_Docs_Readmes/" + d + "/" + d + ".md", "w").write(c)
    os.system("sudo cp -r " + fp + " markdown/Github_Docs_Readmes/")
    os.system("sudo rm -Rf markdown/Github_Docs_Readmes/" + d + "/.git")


def main():
    """
    main
    """
    os.system("rm -f markdown/*.html")
    special_interests = ["kubernetes", "coreos", "docker", "redis", "etcd", "celery"]
    os.system("sudo rm -Rf markdown/Github_Docs_Readmes&&mkdir -p markdown/Github_Docs_Readmes/_Readmes")
    bs = os.path.expanduser("~/workspace/github")

    for d in os.listdir(bs):
        have_docs = False
        fp = os.path.join(os.path.expanduser("~/workspace/github"), d)
        print fp
        rm1 = os.path.join(fp, "readme.md")
        rm2 = os.path.join(fp, "readme.txt")
        rm3 = os.path.join(fp, "readme.rst")
        docs = os.path.join(fp, "docs")
        docu = os.path.join(fp, "Documentation")

        for interest in special_interests:
            if interest.lower() in fp.lower():
                get_folder(c, d, fp)
                have_docs = True

        if (os.path.exists(rm1) or os.path.exists(rm2) or os.path.exists(rm3)) and not have_docs:
            c = None
            for rm in [rm1, rm2, rm3]:
                if os.path.exists(rm):
                    c = open(rm).read()
            if c:
                os.mkdir("markdown/Github_Docs_Readmes/" + d)
                open("markdown/Github_Docs_Readmes/" + d + "/" + d + ".md", "w").write(c)

            if os.path.exists(docs):
                get_folder(c, d, fp)
                have_docs = True

            if os.path.exists(docu):
                get_folder(c, d, fp)
                have_docs = True

            if not have_docs:
                os.system("mv markdown/Github_Docs_Readmes/" + d + " markdown/Github_Docs_Readmes/_Readmes/")

    os.system("sudo chown -R `whoami` markdown/Github_Docs_Readmes")
    print "delete py"
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name '*.py' -exec rm -rf {} \; 2> /dev/null")
    print "delete go"
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name '*.go' -exec rm -rf {} \; 2> /dev/null")
    print "delete js"
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name '*.js*' -exec rm -rf {} \; 2> /dev/null")
    print 'delete html'
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name '*.html' -exec rm -rf {} \; 2> /dev/null")
    print "delete godeps"
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name 'Godeps*' -exec rm -rf {} \; 2> /dev/null")
    os.system("cd markdown/Github_Docs_Readmes&&sudo find . -name '_Godeps*' -exec rm -rf {} \; 2> /dev/null")
    print "delete empty folders"
    os.system("sudo find markdown -depth -empty -delete")
    print "convert txt to md"
    os.system("""find markdown/ -name '*.txt' -type f -exec bash -c 'echo $1&&mv "$1" "${1/.txt/.md}"' -- {} \; 2> /dev/null""")


if __name__ == "__main__":
    main()
