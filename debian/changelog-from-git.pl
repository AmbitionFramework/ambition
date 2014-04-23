#!/usr/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);

my $distro = ( shift(@ARGV) or 'trusty' );
my $base_version;
my $git_version = strftime( '%Y%m%d01', localtime );
open( my $fh_cmake, '<', 'CMakeLists.txt' ) or die $!;
while (<$fh_cmake>) {
	if ( /PKGVERSION\s*(\d+\.\d+\.?\d*)/ ) {
		$base_version =$1;
		last;
	}	
}
close($fh_cmake);
die 'No base version found' unless ($base_version);
$base_version .= '.0' if ( $base_version !~ /\d+\.\d+\./ );

my @history = `git log --pretty=oneline --abbrev-commit origin/packaging/debian..`;
my $changelog;
open( my $fh_r_clog, '<', 'debian/changelog' ) or die $!;
while (<$fh_r_clog>) {
	$changelog .= $_;
}
close($fh_r_clog);

my @new_changelog = (
	sprintf( 'ambition (%s~git%s %s; urgency=low', $base_version, $git_version, $distro ),
	'',
	( map { '  * ' . substr( $_, 9 ) } @history ),
	'',
	strftime( ' -- Nick Melnick <nick@abstractwankery.com>  %a, %d %b %Y %H:%M:%S %z', localtime ),
);

print join( "\n", @new_changelog, '', $changelog );

1;

