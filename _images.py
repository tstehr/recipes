import glob
import os
import re
import sys
import urllib.request
from pprint import pprint
from commonmark import Parser
from commonmark.node import NodeWalker
from yarl import URL

from recipemd._vendor.commonmark_extensions.plaintext import CommonMarkToCommonMarkRenderer
from recipemd.data import RecipeParser, RecipeSerializer
from unidecode import unidecode

root_path = os.path.realpath('.')

commonmark_parser = Parser()
commonmark_renderer = CommonMarkToCommonMarkRenderer()

recipe_parser = RecipeParser()
recipe_serializer = RecipeSerializer()


def urlopen_user_agent(url: str): 
    request = urllib.request.Request(url, None, {
    'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7'
    })
    return urllib.request.urlopen(request)
 
def download_recipe_images(recipe_path):
    with open(recipe_path, 'r', encoding='UTF-8') as file:
        ast = commonmark_parser.parse(file.read())

    image_found = False

    for node, entering in NodeWalker(ast):
        if entering and node.t == "image":
            url = URL(node.destination)
            if url.is_absolute():
                image_found = True
                with urlopen_user_agent(str(url)) as resp:
                    image = resp.read()

                image_path = os.path.join(root_path, 'images',  url.name)
                with open(image_path, 'wb') as file:
                    file.write(image)

                relative_image_path = os.path.relpath(image_path, start=os.path.dirname(recipe_path))
                node.destination = relative_image_path

    if image_found:
        print(f"[Images] Processed {recipe_path}", file=sys.stderr)
        transformed_source = commonmark_renderer.render(ast)
        recipe = recipe_parser.parse(transformed_source)
        with open(recipe_path, 'w', encoding='UTF-8') as file:
            file.write(recipe_serializer.serialize(recipe))
        


for path in glob.glob(os.path.join(root_path, '**/*.md'), recursive=True):
    try:
        download_recipe_images(path)
    except Exception as e:
        print(f'[Images] Ignoring {path}', file=sys.stderr)
        pprint(e, stream=sys.stderr)
