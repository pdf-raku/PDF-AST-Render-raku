use Test;
use PDF::Tags::Writer::AST;
use PDF::API6;
use PDF::Tags;
use PDF::Tags::Elem;
use CSS::TagSet::TaggedPDF;

plan 1;

my Pair:D $doc-ast =
    :Document[
             :Lang<en>,
             :P["This text is of ", :Span[:TextDecorationType("Underline"), "minor significance"], "."],
             :P["This text is of ", :Em["major significance"], "."],
             :P["This text is of ", :Strong["fundamental significance"], "."],
             :P["This text is verbatim C<with> B<disarmed> Z<formatting>."],
             :P["This text ", "has been replaced", "."], :P["This text is ", "invisible."],
             :P["This text contains a link to ", :Link[:href("http://www.google.com/"), "http://www.google.com/"], "."],
             :P["This text contains a link with label to ", :Link[:href("http://www.google.com/"), "google"], "."],

             "#comment" => " a real-world sample, taken from Supply.pod6 ",
             :P["A tap on an ", :Code["on demand"], " supply will initiate the production of values, and tapping the supply again may result in a new set of values. For example, ", :Code["Supply.interval"], " produces a fresh timer with the appropriate interval each time it is tapped. If the tap is closed, the timer simply stops emitting values to that tap."],
         ];

my PDF::API6 $pdf .= new;
my $pages = $pdf.Pages;
my PDF::Tags::Writer::AST $writer .= new: :$pdf, :$pages;
my CSS::TagSet::TaggedPDF $styler .= new;
my PDF::Tags $tags .= create: :$pdf, :$styler;
my PDF::Tags::Elem $root = $tags.Document;
my Pair:D @content = $writer.process-root(|$doc-ast);
$writer.write-batch(@content, $root);
my Hash:D $index = $writer.index;
my @toc = $writer.toc;

todo "complete import; Create PDF::Tags::Writer from Pod::To::PDF::API6";
lives-ok { $pdf.save-as: "t/basic.pdf" };

