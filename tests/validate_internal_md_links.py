"""
python validate_internal_md_links.py 1
"""

import os, re, sys

try:
  verbose = int(sys.argv[1]) == 1
except:
  verbose = False

def findDocsLinks(_text):
  # ..\tutorials\retrieval\answer\PART_I.md
  # ../../introduction/containers/SETUP_WINDOWS_WSL.md#network-access
  pattern = r'\]\(([^\()()]+\.md)#?([^\)]*)\)'
  match_list = []
  for match in re.findall(pattern, _text):
    match_list.append({ "file": match[0], "section": match[1] })

  return match_list

def referenceCheck(link_path, link):
  if link["section"] == "":
    return True

  link_found = False
  with open(link_path, 'r', encoding='utf8') as md_file:
    for line in md_file.readlines():
      if link["section"] in line:
        link_found = True
        break

  return link_found
  
report = {}
count = 0
passed = 0

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
        if link["file"].startswith("http"): continue
        
        count += 1

        if verbose: print(link["file"], link["section"])

        link_path = os.path.abspath(
          os.path.join(dir_path, link["file"])
        )

        if not os.path.isfile(link_path):
          report[file_path].append(f"ERROR - FILE NOT FOUND: {link["file"]}")

        else:
          if "\\" in link["file"]: 
            report[file_path].append(f"WARNING - WINDOWS STYLE SEPARATOR: {link["file"]}")
          
          if not (link["file"].startswith("./") or link["file"].startswith("../")): 
            report[file_path].append(f"WARNING - MISSING RELATIVE PATH AT START: {link["file"]}")

          if referenceCheck(link_path, link) is False:
            report[file_path].append(f"ERROR - SECTION NOT FOUND: {link["file"]}#{link["section"]}")
          else :
            passed += 1
        
result_line = f'Test complete. {passed} passed out of {count}.'
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
