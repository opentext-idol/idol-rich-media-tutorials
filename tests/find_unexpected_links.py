"""
python find_unexpected_links.py 1
"""

import os, re, sys

try:
  verbose = int(sys.argv[1]) == 1
except:
  verbose = False

def findDocsLinks(_text):
  pattern = r'\[(.+)\]\((.+)\)'
  match_list = []
  for match in re.findall(pattern, _text):
    print(match)
    match_list.append({ "label": match[0], "value": match[1] })

  return match_list

report = {}
count = 0
failed = 0

for dir_path, dir_names, file_names in os.walk(".."):
  # Ignore hidden folders
  if "\\_" in dir_path: continue

  for file_name in file_names:
    if not file_name.endswith(".md"): continue
    file_path = os.path.join(dir_path, file_name)
    
    print(file_path)
    if not file_path in report: 
      report[file_path] = []

    with open(file_path, 'r', encoding='utf8') as md_file:
      for link in findDocsLinks(md_file.read()):

        count += 1

        if link["value"].startswith("#"): continue # TOC
        if link["value"].startswith("http"): continue # web
        if link["value"].endswith(".md"): continue # Markdown
        if link["value"].find(".md#") > -1: continue # Markdown section
        if link["value"].startswith("chrome://"): continue # browser extension
        if link["value"].find("/figs/") > -1 and link["value"].endswith(".png"): continue # Figure
        if link["value"].find("/figs/") > -1 and link["value"].endswith(".gif"): continue # Figure
        if link["value"].find("/figs/") > -1 and link["value"].endswith(".svg"): continue # Figure
        
        failed += 1

        report[file_path].append(link["value"])

        if verbose: print(link)

        
result_line = f'Test complete. {failed} unusual links found out of {count}.'
print('='*len(result_line))
print(result_line)
print('='*len(result_line))

for file_path in report.keys():
  if len(report[file_path]) > 0:
    print('-'*len(file_path))
    print(file_path)
    print('-'*len(file_path))

    for msg in report[file_path]:
      print(msg)
