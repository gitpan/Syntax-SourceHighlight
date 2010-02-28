#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use FindBin;
use Syntax::SourceHighlight;

my $hl = Syntax::SourceHighlight::SourceHighlight->new('esc.outlang');
my $in = $ARGV[0] // $FindBin::Script;
my $isfile = -e $in;

my $lang = eval {
    my $lm = Syntax::SourceHighlight::LangMap->new();

    if (exists $ARGV[1]) {
	return $lm->getMappedFileName($ARGV[1]);
    }
    elsif ($isfile) {
	return $lm->getMappedFileNameFromFileName($in);
    }
    else {
	die "don't know how to guess\n";
    }
};
unless ($lang) {
    chomp $@;
    warn "Unknown source language, $@, assuming Perl";
    $lang = 'perl.lang';
}

if ($isfile) {
    $hl->highlightFile($in, '', $lang);
}
else {
    say $hl->highlightString($in, $lang);
}
