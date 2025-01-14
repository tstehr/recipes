#!/usr/bin/env bash

cat << EOF | typst compile - $2
#import "@preview/cmarker:0.1.1"
#set page(footer: context [
  \`$1\`
  #h(1fr)
  #if counter(page).final().at(0) > 1 [  
    #counter(page).display(
      "1/1",
      both: true,
    )
  ]
])
#cmarker.render(
  read("$1"),
  blockquote: box.with(stroke: (left: 1pt + black), inset: (left: 5pt, y: 6pt)),
  scope: (image: (path, alt: none) => image(path, alt: alt)),
)
EOF