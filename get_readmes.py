# coding=utf-8
"""
convert markdown to html
"""
import os


def main():
    """
    main
    """
    os.makedirs(os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/"), exist_ok=True)

    os.chdir(os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme"))

    os.system("rm -Rf ~/workspace/markdown-to-ebook/bookcvwait/githubreadme/*")
    bs = os.path.expanduser("~/workspace/github/_projects")
    bs = os.path.expanduser("~/study/django-modules")

    for d in os.listdir(bs):
        fp = os.path.join(bs, d)
        rm = os.path.join(fp, "readme.md")
        np = os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/") + d + "/readme.md"
        if not os.path.exists(rm):
            rm = os.path.join(fp, "readme.rst")
            np = os.path.expanduser("~/workspace/markdown-to-ebook/bookcvwait/githubreadme/") + d + "/readme.rst"

        if os.path.exists(rm):
            c = open(rm).read()

            print(np)
            os.makedirs(os.path.dirname(np), exist_ok=True)
            open(np, "w").write(c)
        if np.endswith("rst"):
            os.system("python3 ~/workspace/devenv/rst2python.py -cf "+np)

if __name__ == "__main__":
    main()
