#!/usr/bin/perl -w

# $Id$

use strict;
use Test::More tests => 17;
use Term::ANSIColor qw(:constants);
use File::Spec::Functions qw(catfile);
use IO::File;

use lib qw( /Users/gwg/Text-WordDiff-0.05/lib );

# BEGIN {
    use_ok 'Text::WordDiff'       or die;
    use_ok 'Text::WordDiff::HTMLTwoLines' or die;
# }

my $string1   = 'This is a test';
my $string2   = 'That was a test';
my $term_diff = '<div class="file"><span class="hunk"><del>This is </del></span><span class="hunk">a test</span></div>' . "\n" . '<div class="file"><span class="hunk"><ins>That was </ins></span><span class="hunk">a test</span></div>' . "\n";
my %opts = (
    STYLE => 'HTMLTwoLines',
);

# Test scalar refs.
is word_diff(\$string1, \$string2, \%opts), $term_diff,
    'Should HTML diff';

# Try code refs.
is word_diff( sub { \$string1 }, sub { \$string2 } , \%opts ), $term_diff,
    'Should get same result for code refs';

# Try array refs.
my $BEGIN_WORD = qr/(?<!\w)(?=\w)/msx;
my @string1 = split $BEGIN_WORD, $string1;
my @string2 = split $BEGIN_WORD, $string2;
is word_diff( \@string1, \@string2, \%opts ), $term_diff,
    'Should get same result for array refs';

# Mix and match.
is word_diff( \$string1, \@string2, \%opts ), $term_diff,
    'Should get same result for a scalar ref and an array ref';

# Try file names.
my $filename1 = catfile qw(t data left.txt);
my $filename2 = catfile qw(t data right.txt);
my $time1     = localtime( (stat $filename1)[9] );
my $time2     = localtime( (stat $filename2)[9] );
my $header1    = qq{<span class="fileheader">--- $filename1 $time1</span>};
my $header2    = qq{<span class="fileheader">+++ $filename2 $time2</span>};

my $file_diff = qq{<div class="file">$header1}
	. qq{<span class="hunk">This is a </span><span class="hunk"><del>tst;</del></span>}
	. qq{<span class="hunk">\n</span>}
	. qq{<span class="hunk"><del>it </del></span><span class="hunk">is only a\n}
	. qq{test. Had </span><span class="hunk"><del>it </del></span><span class="hunk">been an\n}
	. qq{actual diff, the results would\n}
	. qq{have been output to </span><span class="hunk"><del>HTML</del></span>}
	. qq{<span class="hunk">.\n\nSome string with </span>}
	. qq{<span class="hunk"><del>funny \$</del></span>}
	. qq{<span class="hunk">\nchars in the end</span>}
	. qq{<span class="hunk"><del>*</del></span><span class="hunk">\n</span></div>\n}
	. qq{<div class="file">$header2}
	. qq{<span class="hunk">This is a </span><span class="hunk"><ins>test.</ins></span>}
	. qq{<span class="hunk">\n</span>}
	. qq{<span class="hunk"><ins>It </ins></span><span class="hunk">is only a\n}
	. qq{test. Had </span><span class="hunk"><ins>this </ins></span><span class="hunk">been an\n}
	. qq{actual diff, the results would\n}
	. qq{have been output to </span><span class="hunk"><ins>the terminal</ins></span>}
	. qq{<span class="hunk">.\n\nSome string with </span>}
	. qq{<span class="hunk"><ins>funny \@</ins></span>}
	. qq{<span class="hunk">\nchars in the end</span>}
	. qq{<span class="hunk"><ins>?</ins></span><span class="hunk">\n</span></div>\n};

is word_diff($filename1, $filename2, \%opts), $file_diff,
    'Diff by file name should include a header';

# No more header after this.
$file_diff =~ s/\Q$header1\E//;
$file_diff =~ s/\Q$header2\E//;

# Try globs.
local (*FILE1, *FILE2);
open *FILE1, "<$filename1" or die qq{Cannot open "$filename1": $!};
open *FILE2, "<$filename2" or die qq{Cannot open "$filename2": $!};
is word_diff(\*FILE1, \*FILE2, \%opts), $file_diff,
    'Diff by glob file handles should work';
close *FILE1;
close *FILE2;

# Try file handles.
my $fh1 = IO::File->new($filename1, '<')
    or die qq{Cannot open "$filename1": $!};
my $fh2 = IO::File->new($filename2, '<')
    or die qq{Cannot open "$filename2": $!};
is word_diff($fh1, $fh2, \%opts), $file_diff,
    'Diff by IO::File objects should work';
$fh1->close;
$fh2->close;

# Try a code refence output handler.
my $output = '';
$opts{OUTPUT} = sub { $output .= shift };
is word_diff(\$string1, \$string2, \%opts ), 2,
    'Should get a count of 2 hunks with code ref output';
is $output, $term_diff, 'The code ref should have been called';

# Try a scalar ref output handler.
$output = '';
$opts{OUTPUT} = \$output;
is word_diff(\$string1, \$string2, \%opts), 2,
    'Should get a count of 2 hunks with scalar ref output';
is $output, $term_diff, 'The scalar ref should have been appended to';

# Try an array ref output handler.
my $hunks = [];
$opts{OUTPUT} = $hunks;
is word_diff(\$string1, \$string2, \%opts), 2,
    'Should get a count of 2 hunks with array ref output';
is join('', @$hunks), $term_diff,
    'The array ref should have been appended to';

# Try a file handle output handler.
my $fh = IO::File->new_tmpfile;
SKIP: {
    skip 'Cannot create temp filehandle', 2 unless $fh;
    $opts{OUTPUT} = $fh;
    is word_diff(\$string1, \$string2, \%opts), 2,
        'Should get a count of 2 hunks with file handle output';
    $fh->seek(0, 0);
    is do { local $/; <$fh>; }, $term_diff,
        'The file handle should have been written to';
}
