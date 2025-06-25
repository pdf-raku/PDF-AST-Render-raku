PDF-Tags-Renderer
=================

Synopsis
--------

```raku
my :role-map = 'U' => :Span[:TextDecorationType<Underline>];
my Pair:D $doc-ast =
    :Document[ :Lang<en>,
        :H1["A basic Test Document"],
        :P["This text is ", :Em["italic"], "."],
        :P["This text is ", :Strong["bold"], "."],
        :P["This text is ", :U["underlined"], "."],
        :P["This text contains a link to ", :Link[:href("http://www.google.com/"), "google"], "."],

        "#comment" => " a real-world sample, converted from Supply.rakudoc",
        :P["A tap on an ", :Code[:Span[ :role<Index>, "on demand"]]," supply will initiate the ",
           "production of values and tapping the supply again may result in a new set of values.",
           "For example, ", :Code[:Span[ :role<Index>, "Supply.interval"]], " produces a fresh ",
           "timer with the appropriate interval each time it is tapped."],
     ];

my PDF::API6 $pdf = PDF::Tags::Renderer.render($doc-ast, :%role-map);
$pdf.save-as: "example.pdf";
```

Description
-----------
This module facilitates PDF construction from a simple data-structure that
is simple enough to be used directly, or can act as an intermediate structure
tree representation for conversion of basic documentation formats, such as Pod
or Markdown, to PDF. 

There is an emphasis on accessibility; the structure tree is directly translated
to marked content in the generated PDF.
