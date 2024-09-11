# -*- coding: utf-8 -*-
#
# Based on template from ReadTheDocs 2.8.5

from __future__ import division, print_function, unicode_literals

from datetime import datetime

from recommonmark.parser import CommonMarkParser

# Set recursion limit a lot higher than the default of 1000
import sys; sys.setrecursionlimit(50000)

extensions = []
templates_path = ['templates', '_templates', '.templates']
source_suffix = ['.rst', '.md']
source_parsers = {
            '.md': CommonMarkParser,
        }
master_doc = 'index'
project = u'{{ project.name }}'
copyright = str(datetime.now().year)
version = '{{ version.verbose_name }}'
release = '{{ version.verbose_name }}'
exclude_patterns = ['_build']
pygments_style = 'sphinx'
htmlhelp_basename = '{{ project.slug }}'
html_theme = 'sphinx_rtd_theme'
file_insertion_enabled = False
latex_documents = [
  ('index', '{{ project.slug }}.tex', u'{{ project.name }} Documentation',
   u'{{ project.copyright }}', 'manual'),
]
