#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions qw/catfile/;
use FindBin;
use lib catfile($FindBin::Bin, 'backend');

use ExtUtils::MakeMaker;
use SourceHighlightBuild qw/find_source_highlight build_source_highlight/;

my %source_highlight_pkg = eval {
    if (defined $ENV{PKG_CONFIG_PATH} and $ENV{PKG_CONFIG_PATH} eq '') {
	if (prompt('Ignore possibly installed backend library?', 'no') =~ m/^y(?:es)?$/i) {
	    die "Possibly installed backend library is ignored";
	}
    }

    find_source_highlight();
};
if (my $exn = $@) {
    warn $exn;

    print qq/
The native backend library GNU Source Highlight was not found. You can
possibly install it using the package manager of your operating system
with a command like

  aptitude install source-highlight libsource-highlight-dev

or

  yum install source-highlight

Make sure that you pick a version above 3.1 since older versions don't
provide the public API used by this Perl extension. Also make sure to
install the development headers and libraries so that the native part
of this extension can be built.

If you wish, this script can also try to download the distribution

  $SourceHighlightBuild::URL

unpack it, build it and link it statically into this Perl extension.
\n/;

    if (prompt('Try to build a private backend library?', 'yes') =~ m/^y(?:es)?$/i) {
	%source_highlight_pkg = build_source_highlight();
    }
    else {
	die $exn;
    }
}

WriteMakefile(
    NAME    => 'Syntax::SourceHighlight',
    CCFLAGS => $source_highlight_pkg{cflags},
    LIBS    => [$source_highlight_pkg{libs}],
    OBJECT  => 'SourceHighlight_wrap.o'
);
