import glob
import os
import sys
from typing import List
import urllib.request
from pprint import pprint
from markdown_it import MarkdownIt
from markdown_it.token import Token
from yarl import URL

from recipemd.data import RecipeParser, RecipeSerializer
from mdformat.renderer import MDRenderer

root_path = os.path.realpath('.')

markdown_it = MarkdownIt()
renderer = MDRenderer()

recipe_parser = RecipeParser()
recipe_serializer = RecipeSerializer()


def urlopen_user_agent(url: str): 
    request = urllib.request.Request(url, None, {
    'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7'
    })
    return urllib.request.urlopen(request)

def transform_image(token: Token, recipe_path: str):
    src = token.attrGet('src')

    if not isinstance(src, str):
        return False

    url = URL(src)
    if not url.is_absolute():
        return False

    with urlopen_user_agent(str(url)) as resp:
        image = resp.read()

    image_path = os.path.join(root_path, 'images',  url.name)
    with open(image_path, 'wb') as file:
        file.write(image)

    relative_image_path = os.path.relpath(image_path, start=os.path.dirname(recipe_path))
    token.attrSet('src', relative_image_path)

    return True

def transform_images(tokens: List[Token], recipe_path: str) -> bool:
    image_found = False

    for token in tokens:
        if token.children:
            image_found |= transform_images(token.children, recipe_path)

        if token.type == "image":
            image_found |= transform_image(token, recipe_path)
            
    return image_found

def download_recipe_images(recipe_path):
    with open(recipe_path, 'r', encoding='UTF-8') as file:
        tokens = markdown_it.parse(file.read())

    image_found = transform_images(tokens, recipe_path)

    if image_found:
        print(f"[Images] Processed {recipe_path}", file=sys.stderr)
        options = {}
        env = {}
        transformed_source = renderer.render(tokens, options, env)
        recipe = recipe_parser.parse(transformed_source)
        with open(recipe_path, 'w', encoding='UTF-8') as file:
            file.write(recipe_serializer.serialize(recipe))
        


for path in glob.glob(os.path.join(root_path, '**/*.md'), recursive=True):
    try:
        download_recipe_images(path)
    except Exception as e:
        print(f'[Images] Ignoring {path}', file=sys.stderr)
        pprint(e, stream=sys.stderr)
