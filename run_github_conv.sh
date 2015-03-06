#!/bin/sh
rm -Rf bookconversionfolder/*
python docs_github_get.py
python md2html.py
