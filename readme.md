# markdown-to-ebook
Loops a directory with github projects, scans for documentation and readme's. And builds a html-version compatible with Calibre

##Convert .md files to an ebook
####Prerequisites
* ebook converter
* Calibre: http://calibre-ebook.com/download

```bash
# install ebook converter
$ npm install -g ebook
```

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
After conversion an ebook is created with the .mobi extension
GithubReadmeDocs.mobi


#####Optional
The source code can also be converted with the -c flag, it's using the Github syntax coloring for
- shell
- c
- cpp
- python
- go
- javascript
- coffeescript
```bash
$ python md2html.py -c
...

####Result
Kindle on Mac

> ![kindle](resources/kindle.png)


##make an ebook of all your cloned github projects
Run one of the collection scripts, and put the results in the markdown folder, continue at step 1

Checkout [github-star-syncer](https://github.com/erikdejonge/github-stars-syncer)

```bash
# run the syncer
cd ~/workspace/github-stars-syncer
rm -f starlist.pickle
python update_stars_github.py

# collects all the readme's and doc directories from ~/workspace/github
$ python docs_github_get.py
```




