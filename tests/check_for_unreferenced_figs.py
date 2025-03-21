"""
python check_for_unreferenced_figs.py 1
"""

import os, re, sys

try:
  verbose = int(sys.argv[1]) == 1
except:
  verbose = False

def findDocsLinks(_text):
  pattern = r'\!\[.*\]\((.*)\)'
  match_list = []
  for match in re.findall(pattern, _text):
    match_list.append(match)

  return match_list

# List all figure references
figure_ref_list = []

for dir_path, dir_names, file_names in os.walk(".."):
  # Ignore hidden folders
  if "\\_" in dir_path: continue

  for file_name in file_names:
    if not file_name.endswith(".md"): continue
    file_path = os.path.join(dir_path, file_name)
    
    print(file_path)

    with open(file_path, 'r', encoding='utf8') as md_file:
      for link in findDocsLinks(md_file.read()):
        if link.startswith("http"): continue
        
        if verbose: print(link)

        link_path = os.path.abspath(
          os.path.join(dir_path, link.split("#")[0])
        )

        figure_ref_list.append(link_path)
        
# print(figure_ref_list)

# Find all figure assets
report_title = "Unreferenced files"
print("-"*len(report_title))
print(report_title)
print("-"*len(report_title))

for dir_path, dir_names, file_names in os.walk(".."):
  # Ignore hidden folders
  if "\\_" in dir_path: continue
  if not "figs" in dir_path: continue

  for file_name in file_names:
    file_path = os.path.abspath(
      os.path.join(dir_path, file_name)
    )

    if not file_path in figure_ref_list:
      print(file_path)
