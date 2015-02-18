#!/bin/sh
rm -Rf markdown/*
python docs_github_get.py
python md2html.py
