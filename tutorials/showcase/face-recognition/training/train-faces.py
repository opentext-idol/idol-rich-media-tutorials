"""
python3 train-faces.py
"""
import os
import urllib.parse
import requests

#  v a r i a b l e s
api = 'http://localhost:14000/action='
database_name = 'LFW'
null_image_data = False

person_list = [
  {'folder': 'David_Bowie', 'identifier': 'David Bowie', 'metadata': { 'Occupation': 'Musician' }},
  {'folder': 'Michael_Jordan', 'identifier': 'Michael Jordan', 'metadata': { 'Occupation': 'Sportsman', 'Sponsor': 'Nike' }},
  {'folder': 'Roger_Federer', 'identifier': 'Roger Federer', 'metadata': { 'Occupation': 'Sportsman', 'Sponsor': 'Nike' }}
]


#  f u n c t i o n s
def listMetadata(person):
  metadata = []
  for meta_key in person['metadata'].keys():
    metadata.append({
      "key": urllib.parse.quote(meta_key),
      "value": urllib.parse.quote(person["metadata"][meta_key])
    })

  return metadata

def listImageFileNames(person):
  image_list = []
  image_folder = os.path.join(os.getcwd(), person['folder'])
  
  for image_file in os.listdir(image_folder):
    image_list.append(image_file)

  return image_list

def getImagePath(person, image_file):
  return os.path.join(os.getcwd(), person['folder'], image_file)


#  m a i n   e x e c u t i o n
if __name__ == '__main__':
  database_safe = urllib.parse.quote(database_name)

  x = requests.get(
    f'{api}RemoveFaceDatabase&database={database_safe}'
  )
  if not x.text.find(f"'database={database_safe}' does not exist"):
    print(f'{x.status_code}: {x.text}')

  x = requests.get(
    f'{api}CreateFaceDatabase&database={database_safe}'
  )
  print(f'{x.status_code}: {x.text}')

  # Process each person's images
  for person in person_list:
    # print(listMetadata(person))
    # print(listImageFileNames(person))
    identifier_safe = urllib.parse.quote(person["identifier"])

    x = requests.get(
      f'{api}NewFace&database={database_safe}&identifier={identifier_safe}'
    )
    print(f'{x.status_code}: {x.text}')

    for m in listMetadata(person):
      x = requests.get(
        f'{api}AddFaceMetadata&database={database_safe}&identifier={identifier_safe}&key={m["key"]}&value={m["value"]}'
      )
      print(f'{x.status_code}: {x.text}')

    for i in listImageFileNames(person):
      image_label = urllib.parse.quote(i)

      x = requests.post(
        f'{api}AddFaceImages&database={database_safe}&identifier={identifier_safe}&imagelabels={image_label}',
        files = [('ImageData', open(getImagePath(person, i), 'rb'))]
      )
      print(f'{x.status_code}: {x.text}')

  # Finalize
  x = requests.get(
    f'{api}BuildAllFaces&database={database_safe}'
  )
  print(f'{x.status_code}: {x.text}')
  
  print("To view the build status, go to:")
  print(f'{api}Admin#page/async-queues/BUILDALLFACES')
  print()
  print("To view the trained faces, go to:")
  print(f'{api}ListFaces&database={database_safe}')
  print()
