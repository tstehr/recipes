#!/usr/bin/env bash

input_file=$1
output_file=$2

cat << EOF | typst compile - $output_file
#import "@preview/cmarker:0.1.1"

#let filename = "$input_file"

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
  read(filename),
  blockquote: box.with(stroke: (left: 1pt + black), inset: (left: 5pt, y: 6pt)),
  scope: (image: (path, alt: none) => image(path, alt: alt)),
)
EOF