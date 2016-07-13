#!/usr/bin/env perl
#
# parse-action-conf.pl
# --------------------
# Parse the contents of an ambition-0.1 actions.conf file and output potentially
# valid add_route() commands to add to the updated Application.vala bootstrap
# module.
#
# The Route in ambition-0.2 does not support raw regex, instead relying on
# placeholders in paths. This script does not attempt to parse regex into valid
# paths, and will require tweaking to fix.
#
# Once converted, remember to change the controller methods to static.

use strict;
use warnings;

my ($action_conf) = @ARGV;
unless ($action_conf) {
	print 'Usage: parse-action-conf.pl /path/to/action.conf' . "\n";
	exit(-1);
}

open( my $conf, '<', $action_conf ) or die 'Unable to open ' . $action_conf . ' for reading: ' . $!;
while (<$conf>) {
	if (/^#/) {
		s/^#\s+/\/\/ /;
		print $_;
		next;
	}
	if (/^(\/.*)\s+(((CONNECT|DELETE|GET|HEAD|OPTIONS|POST|PUT|TRACE|ALL)(, ?)?)+)\s+(.*)([\r\n])?$/) {
		my $path = $1;
		my @methods = split( /, ?/, $2 );
		my @targets = split( /, ?/, $6 );

		$path =~ s/\s+$//;
		
		print join( "\n",
			'add_route()',
			"\t" . '.path("' . $path . '")',
			( map { "\t" . '.method( HttpMethod.' . uc($_) . ' )' } @methods ),
			( map { s/\s+$//; "\t" . '.target( Controller.' . $_ . ' )' } @targets ),
		) . ';' . "\n";
	}
}
close($conf);


1;
