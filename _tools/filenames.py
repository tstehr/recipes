import sys
import glob
import os
import re
from pprint import pprint

from recipemd.data import RecipeParser
from unidecode import unidecode

root_path = '.'
rp = RecipeParser()

tt = str.maketrans({
    "ä": "ae",
    "ö": "oe",
    "ü": "ue",
    "Ä": "Ae",
    "Ö": "Oe",
    "Ü": "Ue",
    "ß": "ss",
})

for path in glob.glob(os.path.join(root_path, '**/*.md'), recursive=True):
    try:
        with open(path, 'r', encoding='UTF-8') as file:
            recipe = rp.parse(file.read())
            filename = recipe.title
            filename = filename.translate(tt)
            filename = unidecode(filename)
            filename = re.sub(r'[^a-zA-Z0-9]+', '_', filename)
            filename = re.sub(r'^_+|_+$', '', filename)
            new_path = os.path.join(os.path.dirname(path), f'{filename}.md')
            os.rename(path, new_path)
    except Exception as e:
        print(f'[Filenames] Ignoring {path}', file=sys.stderr)
        pprint(e, stream=sys.stderr)
