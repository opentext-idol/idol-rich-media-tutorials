"""
python xmls2srt.py path/to/output.xml
"""

import os, sys, datetime, math
import xml.etree.ElementTree as ET

# classes
class Word:
  def __init__(self, startMSec, endMSec, text):
    self.startMSec = startMSec
    self.endMSec = endMSec
    self.text = text
  
class Line():
  def __init__(self, duration):
    self.duration = duration
    self.startMSec = None
    self.endMSec = None
    self.words = []

  def addWord(self, word):
    if word.text in ['<SIL>', '<s>']:
      return True

    if self.startMSec is None:
      # add first word
      self.startMSec = word.startMSec
      self.endMSec = word.endMSec
      self.words.append(word.text)
      return True

    elif word.startMSec <= (self.startMSec + self.duration):
      # add additional word
      self.endMSec = word.endMSec
      self.words.append(word.text)
      return True

    else:
      # word is out of range
      return False
  
  def text(self):
    return ' '.join(self.words)

  def _srtDuration(self, MSec, offset):
    now = datetime.datetime.fromtimestamp(MSec/1000.0)
    d = now - offset
    msec = math.floor(0.5 + d.microseconds / 1000.0)
    hours, remainder = divmod(d.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return '{:02}:{:02}:{:02},{:03}'.format(int(hours), int(minutes), int(seconds), int(msec))

  def startTime(self, offset):
    return self._srtDuration(self.startMSec, offset)

  def endTime(self, offset):
    return self._srtDuration(self.endMSec, offset)

# functions
def combineWordsIntoLines(words, durationMSec=5000.0):
  lines = [Line(durationMSec)]

  for word in words:
    if not lines[-1].addWord(word):
      next_line = Line(durationMSec)
      next_line.addWord(word)
      lines.append(next_line)

  return lines

# main execution
if __name__ == '__main__':
  source_xml = os.path.normpath(sys.argv[1])
  print(source_xml)
  tree = ET.parse(source_xml)
  root = tree.getroot()

  sessionStart = datetime.datetime.fromtimestamp(
    float(root.find('.//session/startTime').text) / 1000000.0
  )

  words = []
  for record in root.findall('.//record'):
    if record.find('SpeechToTextResult') == None: continue

    words.append(Word(
      float(record.find('timestamp/startTime').text) / 1000.0,
      float(record.find('timestamp/endTime').text) / 1000.0,
      record.find('SpeechToTextResult/text').text
    ))
    # break

  with open(source_xml.replace('.xml', '.srt'), 'w', encoding='utf-8') as f:
    words.sort(key=lambda x: x.startMSec)
    n = 0
    for line in combineWordsIntoLines(words):
      n += 1
      f.write(f'{n}\n')
      f.write(f'{line.startTime(sessionStart)} --> {line.endTime(sessionStart)}\n')
      f.write(line.text() + '\n')
      f.write('\n')
