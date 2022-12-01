"""
python train-faces.py
"""
import os, urllib.parse, urllib.request


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
      f'{meta_key}:{person["metadata"][meta_key]}'
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
  x = urllib.request.urlopen(
    f'{api}RemoveFaceDatabase&database={database_name}'
  )
  print(x.read())

  x = urllib.request.urlopen(
    f'{api}CreateFaceDatabase&database={database_name}'
  )
  print(x.read())

  for person in person_list:
    # print(listMetadata(person))
    # print(listImagesFileNames(person))
    # print(listImagesFilePaths(person))

    x = urllib.request.urlopen(
      f'{api}TrainFace&database={database_name}&nullimagedata={null_image_data}&identifier={person["identifier"]}&metadata={listMetadata(person)}&imagelabels={listImagesFileNames(person)}&imagepath={listImagesFilePaths(person)}'
    )
    print(x.read())

  print(
    f'{api}ListFaces&database={database_name}'
  )
