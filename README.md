PDF-AST-Render
=================

Description
-----------

PDF::API6 based renderer for the fledgling PDF::AST format.

PDF::AST is intended, either as:
- an intermediate representation for simple documentation languages such as
Markdown, Man and Pod. Possibly RakuDoc?
- a suitable high-level target for direct use for general ad-hoc documentation.
- interchange format, which easily maps to XML or JSON.

The format is designed to preserve high-level semantics present in the
input language, leading to compact PDF output, tagged for accessibility.

Styling is internally somewhat CSS driven. This us under development and will
lead to the ability to customise the output lkayout and appearance..

Synopsis
--------

```raku
use PDF::AST::Render;

my %role-map = (
    'U' => :Span[:TextDecorationType<Underline>],
    'X' => :Index[],
);

my Pair:D $pdf-ast =
    :Document[ :Lang<en>,
        :H1["A basic Test Document"],
        :P["This text is ", :Em["italic"], "."],
        :P["This text is ", :Strong["bold"], "."],
        :P["This text is ", :U["underlined"], "."],
        :P["This text contains a link to ", :Link[:href("http://www.google.com/"), "google"], "."],

        "#comment" => " a real-world sample, converted from Supply.rakudoc",
        :P["A tap on an ", :Code[:X[ "on demand"]]," supply will initiate the ",
           "production of values and tapping the supply again may result in a new set of values.",
           "For example, ", :Code[:X["Supply.interval"]], " produces a fresh ",
           "timer with the appropriate interval each time it is tapped."],
     ];

my PDF::AST::Render $renderer .= new: :%role-map;
my PDF::API6 $pdf = $renderer.render($pdf-ast);
$pdf.save-as: "example.pdf";
```
