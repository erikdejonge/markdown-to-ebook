# coding=utf-8
"""
convert markdown to html
"""

import os


def main():
    """
    main
    """
    os.system("rm -Rf github/*")
    bs = "/Users/rabshakeh/workspace/github"
    for d in os.listdir(bs):

        fp = os.path.join("/Users/rabshakeh/workspace/github", d)
        rm = os.path.join(fp, "readme.md")
        docs = os.path.join(fp, "docs")

        if os.path.exists(rm):
            c = open(rm).read()

            os.mkdir("github/" + d)
            open("github/" + d + "/" + d + ".md", "w").write(c)




if __name__ == "__main__":
    main()
