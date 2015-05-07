#!/bin/sh
rm -Rf bookcv/*
python docs_github_get.py
python md2html.py
