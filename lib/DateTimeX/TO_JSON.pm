# ABSTRACT: Adds a TO_JSON method to DateTime
=head1 SYNOPSIS

  use DateTime;
  use JSON;
  use DateTimeX::TO_JSON formatter => 'DateTime::Format::RFC3339';

  my $dt = DateTime->now;
  my $out = JSON->new->convert_blessed(1)->encode([$dt]);

=head1 DESCRIPTION

Adds a TO_JSON method to L<DateTime> so that L<JSON> and other
JSON serializers can serialize it when they encounter it in a data
structure.

Can be given an optional DateTime formatter on import such as
L<DateTime::Format::RFC3339>. Any formatter that supports new and
format_datetime will work.
Defaults to turning DateTime into a string by calling L<DateTime/datetime>

If you want to format the date in your own way, then just define the following
function in your code instead of using this module:

    sub DateTime::TO_JSON {
        my $dt = shift;
        # do something with $dt, such as:
        return $dt->ymd;
    }

=cut

package DateTimeX::TO_JSON;
use strict;
use warnings;
use Class::Load;

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

    no warnings 'redefine';

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
