#!/usr/bin/env bash

input_file=$1
output_file=$2
filename=${3:-$input_file}
ignore_image_not_found=${4:-false}

cat << EOF | typst compile - $output_file
#import "@preview/cmarker:0.1.1"
#import "@preview/based:0.2.0": base64

#let inputFile = "$input_file"
#let filename = "$filename"
#let ignoreImageNotFound=$ignore_image_not_found

#let context-function = (context { }).func()
#let unique-string(path) = base64.encode(path)
#let maybe-image(path, alt: none) = context {
  let not-found = []
  let path-label = label(unique-string(path))
  let first-time = query(context-function).len() == 0
  let used-path = query(path-label).len() > 0
  if first-time or used-path [#image(path, alt: alt)#path-label] else { not-found }
}

#let wrapAfterSymbol(body) = [
  #show regex("[^a-zA-Z]"): it => it + sym.zws
  #body
]

#show link: underline

#set page(
  footer: context [
    #if counter(page).final().at(0) > 1 {
      let pagenum = counter(page).display(
        "1/1",
        both: true,
      )
      let pagenumsize = measure(pagenum)
      [
        #box(
          width: 100% - pagenumsize.width - 5pt,
          baseline: 100% - pagenumsize.height,
          wrapAfterSymbol(raw(filename)),
        )
        #h(1fr)
        #pagenum
      ]
    } else {
      wrapAfterSymbol(raw(filename))
    }
  ],
)

#cmarker.render(
  read(inputFile),
  blockquote: box.with(stroke: (left: 1pt + black), inset: (left: 5pt, y: 6pt)),
  scope: (image: (path, alt: none) => if ignoreImageNotFound {
    maybe-image(path, alt: alt)
  } else {
    image(path, alt: alt)
  }),
)
EOF