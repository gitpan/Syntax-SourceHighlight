package SourceHighlightBuild;

use strict;
use warnings;

use Exporter qw/import/;
our @EXPORT_OK = qw/find_source_highlight build_source_highlight/;

use File::Spec::Functions qw/rel2abs updir catfile/;
use Cwd;
use FindBin;
our $Backend = rel2abs(catfile($FindBin::Bin, 'backend'));

use File::Copy qw/move/;
use Archive::Tar;
use ExtUtils::PkgConfig;

our $dist = 'source-highlight-3.1.3';
our $tarball = "$dist.tar.gz";
our $URL = "ftp://ftp.gnu.org/gnu/src-highlite/$tarball";

sub find_source_highlight {
    ExtUtils::PkgConfig->find('source-highlight >= 3.1');
}

sub build_source_highlight {
    my $Base = getcwd();
    chdir $Backend or die "Working directory cannot be changed: $!";

    unless (-e $tarball) {
	print "Downloading $URL...\n";

	if (do { eval 'use LWP::Simple'; not $@ }) {
	    unless (&is_success(&getstore($URL, $tarball))) {
		die "Download of $URL failed";
	    }
	}
	elsif (system('curl', '-O', $URL) != -1) {
	    unless ($? >> 8 == 0) {
		die "Download of $URL failed";
	    }
	}
	elsif (system('wget', $URL) != -1) {
	    unless ($? >> 8 == 0) {
		die "Download of $URL failed";
	    }
	}
	else {
	    die 'Neither LWP::Simple nor curl or wget were useable for the download';
	}
    }

    unless (-d $dist) {
	print "Extracting $tarball...\n";
	
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

    unless (-e 'Makefile') {
	print "Configuring $dist...\n";
	
	if (system(catfile(updir, $dist, 'configure'),
		   '--enable-static', '--disable-shared',
		   '--prefix=' . catfile($Backend, 'stage')) != 0) {
	    die "Couldn't configure $dist";
	}
    }

    print "Building $dist...\n";
    
    if (system('make') != 0) {
	die "Couldn't build $dist";
    }

    print "Staging $dist...\n";

    if (system('make', 'install') != 0) {
	die "Couldn't stage $dist";
    }

    unless (-d (my $datadir = catfile($Base, 'blib', 'lib', 'Syntax', 'SourceHighlight'))) {
	mkdir catfile($Base, 'blib');
	mkdir catfile($Base, 'blib', 'lib');
	mkdir catfile($Base, 'blib', 'lib', 'Syntax');
	mkdir $datadir;
	
	unless (move(catfile($Backend, 'stage', 'share', 'source-highlight'), $datadir)) {
	    die "Couldn't stage $dist: $!"
	}
    }

    chdir $Base or die "Working directory cannot be changed: $!";

    local $ENV{PKG_CONFIG_PATH} = catfile($Backend, 'stage', 'lib', 'pkgconfig');
    find_source_highlight();
}

1;
