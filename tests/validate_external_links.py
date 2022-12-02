"""
python validate_external_links.py 1
"""

import os, re, requests, sys

try:
  verbose = int(sys.argv[1]) == 1
except:
  verbose = False

def isExternalUrl(link):
  return link.find("http://$") == -1 and link.find("&configPath=") == -1 and link.find("IP") == -1 and link.find("localhost") == -1 and link.find("127.0.0.1") == -1

def findDocsLinks(_text):
  # pattern = r'(https:\/\/www\.microfocus\.com\/documentation([\w\d:#@%/;$~_?\+-=\.&](#!)?)*)'
  pattern = r'(https?:\/\/([\w\d:#@%\/;$~_?\+-=\.&](#!)?)*)'
  match_list = []
  for match in re.findall(pattern, _text):
    matched_url = match[0]
    if isExternalUrl(matched_url): match_list.append(matched_url)

  return match_list

report = {}
count = 0
passed = 0

for dir_path, dir_names, file_names in os.walk(".."):
  for file_name in file_names:
    if not file_name.endswith(".md"): continue
    file_path = os.path.join(dir_path, file_name)
    
    print(file_path)

    with open(file_path, 'r') as md_file:
      for link in findDocsLinks(md_file.read()):
        if -1 < link.find("swinfra.net"): continue
        if -1 < link.find("autonomy.com"): continue
        if -1 < link.find("oauth2"): continue
        
        count += 1

        x = requests.get(link)
        if verbose: print(f'{x.status_code}: {link}')

        if x.status_code == 200:
          passed += 1
        else:
          if not file_path in report: 
            report[file_path] = []

          report[file_path].append(f'{x.status_code}: {link}')


result_line = f'Test complete. {passed} passed out of {count}.'
print('='*len(result_line))
print(result_line)
print('='*len(result_line))

for file_path in report.keys():
    print('-'*len(file_path))
    print(file_path)
    print('-'*len(file_path))

    for msg in report[file_path]:
      print(msg)
