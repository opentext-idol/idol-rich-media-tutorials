"""
python train-faces.py
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
    metadata.append(
      f'{urllib.parse.quote(meta_key)}:{urllib.parse.quote(person["metadata"][meta_key])}'
    )

  return ','.join(metadata)

def listImagesFilePaths(person):
  image_list = []
  image_folder = os.path.join(os.getcwd(), person['folder'])
  
  for image_file in os.listdir(image_folder):
    image_list.append(
      urllib.parse.quote(os.path.join(image_folder, image_file))
    )

  return ','.join(image_list)

def listImagesFileNames(person):
  image_list = []
  image_folder = os.path.join(os.getcwd(), person['folder'])
  
  for image_file in os.listdir(image_folder):
    image_list.append(
      urllib.parse.quote(image_file)
    )

  return ','.join(image_list)


#  m a i n   e x e c u t i o n
if __name__ == '__main__':
  x = requests.get(
    f'{api}RemoveFaceDatabase&database={urllib.parse.quote(database_name)}'
  )
  print(f'{x.status_code}: {x.text}')

  x = requests.get(
    f'{api}CreateFaceDatabase&database={urllib.parse.quote(database_name)}'
  )
  print(f'{x.status_code}: {x.text}')

  for person in person_list:
    # print(listMetadata(person))
    # print(listImagesFileNames(person))
    # print(listImagesFilePaths(person))

    x = requests.get(
      f'{api}TrainFace&database={database_name}&nullimagedata={null_image_data}&identifier={urllib.parse.quote(person["identifier"])}&metadata={listMetadata(person)}&imagelabels={listImagesFileNames(person)}&imagepath={listImagesFilePaths(person)}'
    )
    print(f'{x.status_code}: {x.text}')

  print(
    f'{api}ListFaces&database={database_name}'
  )
