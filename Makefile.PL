#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions qw/rel2abs updir catfile/;
use File::Copy qw/move/;
use Archive::Tar;
use ExtUtils::MakeMaker;
use ExtUtils::PkgConfig;

sub find_source_highlight {
    ExtUtils::PkgConfig->find('source-highlight >= 3.1');
}

sub install_source_highlight {
    my $dist = 'source-highlight-3.1.3';
    my $tarball = "$dist.tar.gz";
    my $url = "ftp://ftp.gnu.org/gnu/src-highlite/$tarball";

    print qq/
Unless you cancel the execution of this script within the next 10 s,
an attempt will be made to download GNU Source Highlight from

  $url

and compile it as a static library that will be linked into this Perl
extension...\n/;
    sleep 10;

    mkdir 'backend';
    chdir 'backend' or die "Working directory cannot be changed: $!";

    unless (-e $tarball) {
	print "Downloading...\n";

	if (do { eval 'use LWP::Simple'; not $@ }) {
	    unless (&is_success(&getstore($url, $tarball))) {
		die "Download of $url failed";
	    }
	}
	elsif (system('curl', '-O', $url) != -1) {
	    unless ($? >> 8 == 0) {
		die "Download of $url failed";
	    }
	}
	elsif (system('wget', $url) != -1) {
	    unless ($? >> 8 == 0) {
		die "Download of $url failed";
	    }
	}
	else {
	    die 'Neither LWP::Simple nor curl or wget were useable for the download';
	}
    }

    unless (-d $dist) {
	print "Extracting...\n";
	
	if (my $archive = Archive::Tar->new($tarball, 1)) {
	    unless ($archive->extract()) {
		die "Extraction of $tarball failed: " . $archive->error;
	    }
	}
	else {
	    die "Couldn't open $tarball";
	}
    }

    mkdir 'build';
    chdir 'build';

    unless (-e 'config.h') {
	print "Configuring...\n";
	
	if (system(catfile(updir, $dist, 'configure'),
		   '--enable-static', '--disable-shared',
		   '--prefix=' . rel2abs(catfile(updir, 'stage'))) != 0) {
	    die "Couldn't configure $dist";
	}
    }

    print "Building...\n";
    
    if (system('make') != 0) {
	die "Couldn't build $dist";
    }

    print "Staging...\n";

    if (system('make', 'install') != 0) {
	die "Couldn't stage $dist";
    }

    unless (-d (my $datadir = catfile(updir, updir, 'blib', 'lib', 'Syntax', 'SourceHighlight'))) {
	mkdir catfile(updir, updir, 'blib');
	mkdir catfile(updir, updir, 'blib', 'lib');
	mkdir catfile(updir, updir, 'blib', 'lib', 'Syntax');
	mkdir $datadir;
	
	unless(move(catfile(updir, 'stage', 'share', 'source-highlight'), $datadir)) {
	    die "Couldn't stage $dist: $!"
	}
    }

    chdir catfile(updir, updir) or die "Working directory cannot be changed: $!";

    $ENV{PKG_CONFIG_PATH} = rel2abs(catfile('backend', 'stage', 'lib', 'pkgconfig'));
    find_source_highlight();
}

my %source_highlight_pkg = eval { find_source_highlight() };
if ($@) {
    warn "The native backend library was not found: $@\n";
    %source_highlight_pkg = install_source_highlight();
}

WriteMakefile(
    NAME    => 'Syntax::SourceHighlight',
    CCFLAGS => $source_highlight_pkg{cflags},
    LIBS    => [$source_highlight_pkg{libs}],
    OBJECT  => 'SourceHighlight_wrap.o'
);
