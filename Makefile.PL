#!/usr/bin/env perl
use strict;
use warnings;

use ExtUtils::MakeMaker;
use ExtUtils::PkgConfig;

my %source_highlight_pkg = ExtUtils::PkgConfig->find(
    'source-highlight >= 3.0'
);

WriteMakefile(
    NAME    => 'Syntax::SourceHighlight',
    CCFLAGS => $source_highlight_pkg{cflags},
    LIBS    => [$source_highlight_pkg{libs}],
    OBJECT  => 'SourceHighlight_wrap.o'
);
