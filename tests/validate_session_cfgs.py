"""
python validate_session_cfgs.py 1
"""

import os
import time
import requests
import xml.etree.ElementTree as ET

api = 'http://localhost:14000/action='
TIME_DELAY = 0.3
count = 0
passed = 0

namespaces = {'autn': 'http://schemas.autonomy.com/aci/'}

for dir_path, dir_names, file_names in os.walk(".."):
  for file_name in file_names:
    if file_name.endswith(".tmpl.cfg"): continue
    if not file_name.endswith(".cfg"): continue
    file_path = os.path.abspath(
      os.path.join(dir_path, file_name)
    )
    
    count += 1

    time.sleep(TIME_DELAY)
    x = requests.post(f'{api}ValidateProcessConfig', files = [
      ('ConfigPath', open(file_path, 'rb'))
    ])
    print("- "*20)
    print(f'{x.status_code}: {file_path}')
    
    if x.status_code == 200:
      xroot = ET.fromstring(x.text)

      is_processable = xroot.find(".//processable").text
      print(f'Processible: {is_processable}')

      if is_processable == "true":
        passed += 1
      else:
        print("\nError report:\n")

        for section_detail in xroot.findall(".//errors/autn:section", namespaces):
          print( "*",
            section_detail.find("autn:sectionname", namespaces).text, 
            section_detail.find("autn:comment", namespaces).text
          )
        
          for key_detail in section_detail.findall("autn:key", namespaces):
            print( "* *",
              key_detail.find("autn:keyname", namespaces).text,
              key_detail.find("autn:keyvalue", namespaces).text,
              key_detail.find("autn:comment", namespaces).text
            )

result_line = f'Test complete. {passed} passed out of {count}.'
print('='*len(result_line))
print(result_line)
print('='*len(result_line))
