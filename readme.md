# github-md5-ebook
Loops a directory with github projects, scans for documentation and readme's. And builds a html-version compatible with Callibre

##Convert .md files to an ebook
####Prerequisites
```bash
# ebook converter
$ npm install -g ebook
```
Callibre(http://calibre-ebook.com/download)

####Step 1
Put md5 files in a folder inside of the markdown directory

```bash
$ pwd
~/workspace/research/md2html

$ ls markdown/
total 0
0 drwxr-xr-x+   3 rabshakeh  102 Feb 17 15:45 .
0 drwxr-xr-x+   9 rabshakeh  306 Feb 17 15:45 ..
0 drwxr-xr-x+ 133 rabshakeh 4.5K Feb 17 15:17 GithubReadmeDocs

$ ls markdown/GithubReadmeDocs | wc
    134    1199    7748
```

####Step 2
Run the md2html python script, this will convert all .md files to .html, and generates a table of content

```bash
$ python md2html.py
convert: markdown/GithubReadmeDocs/coffee-script/test/importing 2 items
...
```

####Step 4


##Extra
Run one of the collection scripts 

```bash
# collects all the readme's from ~/workspace/github into a local github directory
$ python get_github_readmes.py
# collects all the readme's and doc directories from ~/workspace/github into a local github directory
$ python get_github_readme_and_docs.py
```


![addbooks](resources/addbooks.png)
