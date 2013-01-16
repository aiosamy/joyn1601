import HTMLParser
import tesseract
import sys
import difflib
#import PythonMagick

class WordCoord:

    pass


class HOCRParser(HTMLParser.HTMLParser):
    def __init__(self):
        HTMLParser.HTMLParser.__init__(self)
        self.results = []
        self.word_found = False 
    def handle_starttag(self, tag, attrs):
        if tag == "span":
            for attr in attrs:
                if attr[0] == "class" and attr[1] == "ocr_word":
                    self.word_found = True
                if self.word_found and attr[0] == "title":
                    self.coords = [int(item) for item in attr[1].replace("bbox ", "").split(" ")]
    def handle_endtag(self, tag):
        if self.word_found:
            wc = WordCoord()
            wc.word = self.word
            wc.coords = self.coords
            self.results.append(wc)
            self.word_found = False 
    def handle_data(self, data):
        if self.word_found:
            if data.strip() != "":
                self.word = data.strip().lower()
            else:
                self.word_found = False
            


if sys.argv is None or len(sys.argv) < 2:
    print "Usage: " + sys.argv[0] + " text" 
    sys.exit(-1)

high_accuracy = False    
    
text = sys.argv[1].lower() 
api = tesseract.TessBaseAPI()
api.Init(".","eng",tesseract.OEM_DEFAULT)
api.SetPageSegMode(tesseract.PSM_AUTO)
api.SetVariable("tessedit_create_hocr", "1")
img_file = "imageforocr.png"
if high_accuracy:
    img = PythonMagick.Image(img_file)
    img_width = img.size().width()
    img_height = img.size().height()
    img.transform(str(img_width * 2) + "x" + str(img_height * 2))
    img.write("screenshot-resized.png")
    img_file = "screenshot-resized.png"
buff = open(img_file,"rb").read()
html = tesseract.ProcessPagesBuffer(buff,len(buff), api)
text_file = open("OCR.html", "w")
text_file.write(html)
text_file.close()
parser = HOCRParser()
parser.feed(html)
results = parser.results
words = text.split(" ")
if len(words) > 1:
    i = 0
    found = False 
    while i < len(results) and not found:
        result1 = difflib.get_close_matches(results[i].word, [words[0]])
        if len(result1) > 0:
            j = 0
            discarded = False
            while j < (len(words) - 1) and not discarded:
                result2 = difflib.get_close_matches(results[i + 1 + j].word, [words[j + 1]])
                if len(result2) == 0:
                    discarded = True
                if not discarded:
                    j = j + 1
            if not discarded:
                found = True
        if not found:
            i = i + 1
    if found:
        coords1 = results[i].coords
        coords2 = results[i+j].coords
        x = coords1[0] + (coords2[2] - coords1[0]) / 2
        y = coords1[1] + (coords2[3] - coords1[1]) / 2
        if not high_accuracy:
            print str(x) + "|" + str(y)
        else:
            print str(x/2) + "|" + str(y/2)
else:
    i = 0
    found = False
    while i < len(results) and not found:
        wc = results[i]
        if wc.word == words[0]:
            x = wc.coords[0] + (wc.coords[2] - wc.coords[0]) / 2
            y = wc.coords[1] + (wc.coords[3] - wc.coords[1]) / 2
            found = True
            if not high_accuracy:
                print str(x) + "|" + str(y)
            else:
                print str(x/2) + "|" + str(y/2)
        i = i + 1
    if not found:    
        i = 0
        while i < len(results) and not found:
            wc = results[i]
            result = difflib.get_close_matches(wc.word, words[0])
            if len(result) > 0:
                x = wc.coords[0] + (wc.coords[2] - wc.coords[0]) / 2
                y = wc.coords[1] + (wc.coords[3] - wc.coords[1]) / 2
                found = True
                if not high_accuracy:
                    print str(x) + "|" + str(y)
                else:
                    print str(x/2) + "|" + str(y/2)
            i = i + 1
    
            
