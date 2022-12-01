import os, re, requests

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

count = 0
passed = 0

for dir_path, dir_names, file_names in os.walk(".."):
  for file_name in file_names:
    if not file_name.endswith(".md"): continue
    file_path = os.path.join(dir_path, file_name)
    
    print('-'*20)
    print(file_path)
    print('-'*20)

    with open(file_path, 'r') as md_file:
      for link in findDocsLinks(md_file.read()):
        print(link)
        x = requests.get(link)
        print(x.status_code)

        count += 1
        if x.status_code == 200:
          passed += 1

result_line = f'Test complete. {passed} passed out of {count}.'
print('='*len(result_line))
print(result_line)
print('='*len(result_line))
