package Text::WordDiff::ANSIColor;

use strict;
use Term::ANSIColor qw(:constants);
use vars qw($VERSION @ISA);

$VERSION = '0.01';
@ISA = qw(Text::WordDiff::Base);

sub same_items {
    my $self = shift;
    return join '', @_;
}

sub delete_items {
    my $self = shift;
    return join '', BOLD, RED, @_, RESET;
}

sub insert_items {
    my $self = shift;
    return join '', BOLD, GREEN, @_, RESET;
}

1;
__END__
