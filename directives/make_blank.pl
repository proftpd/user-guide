#!/usr/bin/perl
#
# make_blank.pl <directive> <module> [version valid from]
# ./make_blank.pl Readme readme 1.0.2rc4
#
# Mark Lowes 10/Jan/2002
# A simple script to generate a barebones directive entry
# from the directive.template file, filling in the minimum 
# information to make it useful.
#
( $directive, $module, $version ) = @ARGV;

print "$directive / $module\n";

if ( $directive =~ /^$/ || $module =~ /^$/ )
{
	print "Crapout\n";

}

if ( -f "sgml/$directive" )
{
	print "File $directive exists\n";
}

open ( IN, "<directive.template" ) || die "Can't open template file\n";
open ( OUT, ">sgml/$directive" ) || die "Can't open sgml/$directive\n";

while( <IN> ) {
	$line = $_;
	$line =~ s/\%\%DIRECTIVE\%\%/$directive/;
	$line =~ s/\%\%MODULE\%\%/$module/;
	if( $version ) {
		$line =~ s/\%\%VERSION\%\%/$version/;
	}
	print OUT $line;
}
close( IN );
close( OUT );


