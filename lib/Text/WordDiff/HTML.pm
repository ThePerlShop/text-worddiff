package Text::WordDiff::HTML;

use strict;
use HTML::Entities qw(encode_entities);
use vars qw($VERSION @ISA);

$VERSION = '0.01';
@ISA = qw(Text::WordDiff::Base);

sub file_header {
    my $header = shift->SUPER::file_header(@_);
    return '<div class="file">' unless $header;
    return qq{<div class="file"><span class="fileheader">$header</span>};
}

sub hunk_header { return '<span class="hunk">' }
sub hunk_footer { return '</span>' }
sub file_footer { return '</div>' }

sub same_items {
    my $self = shift;
    return encode_entities( join('', @_) );
}

sub delete_items {
    my $self = shift;
    return '<del>' . encode_entities( join('', @_) ) . '</del>';
}

sub insert_items {
    my $self = shift;
    return '<ins>' . encode_entities( join('', @_) ) . '</ins>';
}

1;
__END__
