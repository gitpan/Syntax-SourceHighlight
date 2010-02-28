#!/usr/bin/env perl
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
     'NAME' => 'Syntax::SourceHighlight',
     'LIBS' => [qw[-lsource-highlight]],
     'OBJECT' => 'SourceHighlight_wrap.o'
);
