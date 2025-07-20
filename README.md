PDF-AST-Render
=================

Description
-----------

PDF::API6 based renderer for the fledgling PDF::AST intermediate representation.

Synopsis
--------

```raku
use PDF::AST::Render;

my :role-map = 'U' => :Span[:TextDecorationType<Underline>];
my Pair:D $pdf-ast =
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

my  PDF::AST::Render $renderer .= new: :%role-map;
my PDF::API6 $pdf = $renderer.render($pdf-ast);
$pdf.save-as: "example.pdf";
```
