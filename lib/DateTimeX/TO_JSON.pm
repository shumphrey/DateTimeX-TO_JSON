# ABSTRACT: Adds a TO_JSON method to DateTime
=head1 NAME

DateTimeX::TO_JSON

=head1 SYNOPSIS

  use DateTime;
  use JSON;
  use DateTimeX::TO_JSON formatter => 'DateTime::Format::RFC3339';

  my $dt = DateTime->now;
  my $out = JSON->new->convert_blessed(1)->encode([$dt]);

=head1 DESCRIPTION

Adds a TO_JSON method to L<DateTime> so that L<JSON> and other
JSON serializers can serialize it when it encounters it a data
structure.

Can be given an optional DateTime formatter on import such as
L<DateTime::Format::RFC3339>. Any formatter that supports new and
format_datetime will work.
Defaults to turning DateTime into a string by call L<DateTime/datetime>

=cut

use strict;
use warnings;
package DateTimeX::TO_JSON;
use Class::Load;
use Carp;

sub import {
    my ($class, @args) = @_;

    ## Only deal with formatter just now but might deal with more later
    ## such as importing DateTime itself
    my %args;
    while ($_ = shift @args) {
        if ( $_ eq 'formatter' ) {
            $args{$_} = shift @args;
        }
    }

    if ( $args{formatter} && ref($args{formatter}) ) {
        *DateTime::TO_JSON = sub {
            $args{formatter}->format_datetime($_[0]);
        }
    }
    elsif ( $args{formatter} ) {
        Class::Load::load_class $args{formatter};
        *DateTime::TO_JSON = sub {
            $args{formatter}->new->format_datetime($_[0]);
        }
    }
    else {
        *DateTime::TO_JSON = sub {
            $_[0]->datetime;
        }
    }
}

1;
