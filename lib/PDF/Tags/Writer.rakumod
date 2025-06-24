unit class PDF::Tags::Writer;

use PDF::Tags::Writer::Outlines :Level;
also does PDF::Tags::Writer::Outlines;

use PDF::API6;
use PDF::Tags;
use PDF::Tags::Elem;
use PDF::Tags::Node;
use PDF::Content;
use PDF::Tags::Writer::Style;
use PDF::Tags::Writer::AST;
use Pod::To::PDF::AST;
use CSS::TagSet::TaggedPDF;
use CSS::Stylesheet;
# PDF::Class
use PDF::Action;
use PDF::StructElem;

### Attributes ###
has PDF::API6 $.pdf .= new;
has CSS::TagSet::TaggedPDF $.styler .= new;
has PDF::Tags $.tags .= create: :$!pdf, :$!styler;
has PDF::Tags::Elem $.root = $!tags.Document;
has PDF::Content::FontObj %.font-map;
has Numeric $.width  = 612;
has Numeric $.height = 792;
has Bool $.contents = True;
has %.index;
has Bool $.tag = True;
has Bool $.page-numbers;

sub apply-styling(CSS::Properties:D $css, %props) {
    %props{.key} = .value for $css.Hash;
}

method !init-pdf(Str :$lang) {
    $!pdf.media-box = 0, 0, $!width, $!height;
    self.lang = $_ with $lang;
}

method !preload-fonts(@fonts) {
    my $loader = (require ::('PDF::Font::Loader'));
    for @fonts -> % ( Str :$file!, Bool :$bold, Bool :$italic, Bool :$mono ) {
        # font preload
        my PDF::Tags::Writer::Style $style .= new: :$bold, :$italic, :$mono;
        if $file.IO.e {
            %!font-map{$style.font-key} = $loader.load-font: :$file;
        }
        else {
            warn "no such font file: $file";
        }
    }
}

submethod TWEAK(Str:D :$lang = 'en', :$pod, :@fonts, :$stylesheet, :$page-style, *%opts) {
    self!init-pdf(:$lang);
    self!preload-fonts(@fonts)
        if @fonts;

    $!pdf.creator.push: "{self.^name}-{self.^ver//'v0'}";

    with $stylesheet {
        # dig out any @page{...} styling from the stylesheet
        with $!styler.load-stylesheet($_) -> CSS::Stylesheet $_ {
            .&apply-styling(%opts)
                with .page-properties;
        }
    }

    with $page-style -> $style {
        # apply any command-line page styling at a higher precedence
        my CSS::Properties $css .= new: :$style;
        $css.&apply-styling(%opts);
    }
}

method writer(PDF::Content::PageTree:D :$pages = $!pdf.Pages, PDF::Tags::Elem:D :$frag = $!root.Document) {
    $pages.media-box = 0, 0, $!width, $!height;
    my $finish = ! $!page-numbers;
    my PDF::Tags::Writer::AST $writer .= new: :%!font-map, :$pages, :$finish, :$!tag, :$!pdf, :$!contents; #, |c;
}

method !paginate(
    $pdf,
    UInt:D :$margin = 20,
    Numeric :$margin-right is copy,
    Numeric :$margin-bottom is copy,
                ) {
    my $page-count = $pdf.Pages.page-count;
    my $font = $pdf.core-font: "Helvetica";
    my $font-size := 9;
    my $align := 'right';
    my $page-num;
    $margin-right //= $margin;
    $margin-bottom //= $margin;
    for $pdf.Pages.iterate-pages -> $page {
        my PDF::Content $gfx = $page.gfx;
        my @position = $gfx.width - $margin-right, $margin-bottom - $font-size;
        my $text = "Page {++$page-num} of $page-count";
        $gfx.tag: 'Artifact', {
            .print: $text, :@position, :$font, :$font-size, :$align;
        }
        $page.finish;
    }
}

method merge-batch( % ( :@toc!, :%index!, :$frag!, :%info!, |c ) ) {
    @.toc.append: @toc;
    %.index ,= %index;
    for $frag.kids -> $node {
        $.root.add-kid: :$node;
    }
    if %info {
        my $pdf-info = ($!pdf.Info //= {});
        for %info.pairs {
            $pdf-info{.key} = .value;
        }
    }
    self!paginate(|c)
        if $!page-numbers;
    .Lang = self.lang with $!root;
}

method pdf {
    if @.toc {
        $!pdf.outlines.kids = @.toc;
    }
    $!pdf;
}

method build-index {
    self.add-toc-entry(%( :Title('Index')), :level(1));
    my %idx := %!index;
    %idx .= &categorize-alphabetically
        if %idx > 64;
    self.add-terms(%idx);
}

sub categorize-alphabetically(%index) {
    my %alpha-index;
    for %index.sort(*.key.uc) {
        %alpha-index{.key.substr(0,1).uc}{.key} = .value;
    }
    %alpha-index;
}

method lang is rw { $!pdf.catalog.Lang; }
