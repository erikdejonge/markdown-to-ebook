# coding=utf-8
"""
convert rst file

Usage:
  mdcodeblockcorrect.py [options] <mdfile>

Options:
  -h --help     Show this screen.
  -v --verbose  Print arguments
  -f --force    Force check
  -s --silent   Folder from where to run the command [default: .].

  -p --forpdf      Optimize for pdf
"""
import os

from arguments import Arguments
from consoleprinter import forceascii


def correct_codeblocks(mdfile, force=False, fromsrt=False, forpdf=False):
    """
    @type mdfile: str
    @return: None
    """
    ismd = mdfile.strip().endswith("md")

    if force is True:
        if fromsrt is False:
            fromsrt = force
    try:
        inbuf = [x.rstrip().replace("\t", "    ") for x in open(mdfile)]
    except:
        inbuf = []

        for l in open(mdfile):
            if "```" in l:
                l = l.strip().replace("\t", "")

            l = l.replace("\_", "_")

            inbuf.append(forceascii(l).replace("\t", "    "))

    outbuf = []
    cb = False
    inblock = False
    cnt = 0

    for l in inbuf:
        if "```" in l:
            if force is False:
                return 0

    optionsblock = False
    f = False
    for l in inbuf:
        if fromsrt:
            if not ismd:
                l = l.replace("###", "")

            if l.strip().startswith("```"):
                if inblock:
                    inblock = False
                else:
                    inblock = True

            if l.endswith('`.'):
                l = l.replace('`.', '`')

            if inblock:
                l = l.replace("\_", "_")

            if not inblock:
                if l.strip().startswith("--"):
                    optionsblock = True

                if l.strip().startswith("#"):
                    optionsblock = False

                if not optionsblock and not l.strip().startswith("- ") and not l.strip().startswith("1") and not (l.strip().startswith(">") and not l.strip().startswith(">>")):
                    if (l.strip().startswith("sed") or l.strip().startswith("gsed")) and not cb:
                        outbuf.append("\n```bash")
                        cnt += 1
                        cb = True
                    elif ((l.startswith("    ") and not l.strip().startswith("- ")) and not l.strip().startswith("!") and not l.strip().startswith("*") or l.startswith("\t")) and not l.strip().startswith("<!") and not "/>" in l and not l.endswith(";") and not "`" in l and not cb:
                        cnt += 1

                        if l.strip().startswith("$") or 'brew' in l or 'sudo' in l or 'pip' in l or 'python' in l:
                            outbuf.append("\n``` bash")
                        elif l.strip().startswith("SSL") or 'Apache' in l or 'mod_' in l or "Header append" in l or 'Location' in l or 'Mellon' in l:
                            outbuf.append("\n``` apacheconf")
                        elif '<html>' in l or '<p>' in l or '&lt;html' in l or '&lt;p' in l:
                            outbuf.append("\n``` html")
                        else:
                            outbuf.append("\n``` bash")

                        cb = True
                    else:
                        if cb is True:
                            if not (l.strip().startswith("sed") or l.strip().startswith("gsed") or l.startswith("    ") or len(l.strip()) == 0):
                                cb = False
                                outbuf.append("```\n")

                if cb is True:
                    l = l.replace("    ", "", 1)
        if cnt !=0 and f is False:
            f = True
        outbuf.append(l)

    if cb is True:
        outbuf.append("```")

    outbuf = "\n".join(outbuf)


    if force is True:
        outbuf = outbuf.replace("```", "\n```")
        outbuf = outbuf.replace("\n\n\n```", "\n\n```")
        outbuf = outbuf.replace("```\n\n```", "")
        outbuf = outbuf.replace("```\n\n python\n", "\n\n``` python\n")
        outbuf = outbuf.replace("```\n\n bash\n", "\n\n``` bash\n")
        outbuf = outbuf.replace("-   [", "- [")
        outbuf = outbuf.replace("-   ", "- ")
        outbuf = outbuf.replace("1.   ", "1. ")
        outbuf = outbuf.replace("[¶]", "[]")
        outbuf = outbuf.replace("\[", "[")
        outbuf = outbuf.replace("\]", "]")
        outbuf = outbuf.replace("```", "@# @# @# ")
        outbuf = outbuf.replace("\*", "*")
        outbuf = outbuf.replace("`", "**")
        outbuf = outbuf.replace("@# @# @# ", "```")
        outbuf = outbuf.replace("\n\n\n", "\n\n")


        outbuf = outbuf.replace("programlisting", "python")
        outbuf = outbuf.replace("![](2.%20Why%20Value%20Matters%20Less%20with%20Competition.resources/C8D7D470-141C-4985-B463-A7C355237157.jpg)", "- ")

    inblock = False
    outbuf2 = ""
    colwidth = 60
    for l in outbuf.split('\n'):
        if inblock and forpdf is True:
            if len(l) > colwidth:
                index = l[colwidth:].find(' ')

                if index > 0:
                    index = index + colwidth
                    l = l[:index] + '\n\t' + l[index:]

        if inblock and '```' in l:
            outbuf2 += l
        else:
            outbuf2 += '\n' + l

        if '```' in l:
            inblock = not inblock

    open(mdfile, "w").write(outbuf2)

    return cnt


def main():
    """
    main
    """
    arg = Arguments(doc=__doc__)

    if arg.verbose is True:
        print(arg)

    if arg.mdfile.lower().strip().endswith(".markdown"):
        print("mv " + arg.mdfile + " " + arg.mdfile.replace(".markdown", ".md"))
        os.system("mv " + arg.mdfile + " " + arg.mdfile.replace(".markdown", ".md"))

    if not os.path.exists(arg.mdfile):
        print("file does not exist")
        return

    mdfile = arg.mdfile
    forpdf = arg.forpdf

    cnt = correct_codeblocks(mdfile, arg.force, forpdf=forpdf)

    if not arg.silent:
        if cnt != 0:
            print("\033[34m" + arg.mdfile.lower(), "->\033[0;96m " + str(cnt) + " code blocks corrected\033[0m")


if __name__ == "__main__":
    main()
