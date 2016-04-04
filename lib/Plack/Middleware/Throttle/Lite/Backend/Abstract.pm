package Plack::Middleware::Throttle::Lite::Backend::Abstract;

# ABSTRACT: Base class for Throttle::Lite backends

use strict;
use warnings;
use Carp ();
use POSIX qw/strftime/;

our $VERSION = '0.05'; # VERSION
our $AUTHORITY = 'cpan:CHIM'; # AUTHORITY

sub new {
    my ($class) = shift;
    my $args = defined $_[0] && UNIVERSAL::isa($_[0], 'HASH') ? shift : { @_ };
    my $self = $args;
    bless $self, $class;
    $self->init($args);
    return $self;
}

sub init { 1 }

sub mk_attrs {
    my ($class, @attributes) = @_;

    foreach my $attr (@attributes) {
        my $code = sub {
             my ($self, $value) = @_;
             if (@_ == 1) {
                 return $self->{$attr};
             }
             else {
                 return $self->{$attr} = $value;
             }
         };

        my $method = "${class}::${attr}";
        { no strict 'refs'; *$method = $code; }
    }
}

sub reqs_done { Carp::confess 'method \'reqs_done\' is not implemented' }
sub increment { Carp::confess 'method \'increment\' is not implemented' }

__PACKAGE__->mk_attrs(qw(reqs_max requester_id units));

sub settings {
    my ($self) = @_;

    my $settings = {
        'req/day'  => {
            'interval' => 86400,
            'format'   => '%Y%j',
        },
        'req/hour' => {
            'interval' => 3600,
            'format'   => '%Y%j%H',
        },
        'req/min'  => {
            'format'   => '%Y%j%H%M',
            'interval' => 60,
        },
    };

    $settings->{$self->units};
}

sub expire_in {
    my ($self) = @_;

    my ($sec, $min, $hour) = localtime(time);
    my $interval = $self->settings->{'interval'};

    my $already_passed;

    if ($interval == 86400) {       # req/day
        $already_passed = 3600 * $hour + 60 * $min + $sec;
    }
    elsif ($interval == 3600) {     # req/hour
        $already_passed = 60 * $min + $sec;
    }
    else {                          # req/min
        $already_passed = $sec;
    }

    $interval - $already_passed;
}

sub ymdh {
    my ($self) = @_;

    strftime($self->settings->{'format'} => localtime(time));
}

sub cache_key {
    my ($self) = @_;

    $self->requester_id . ':' . $self->ymdh
}

1; # End of Plack::Middleware::Throttle::Lite::Backend::Abstract

__END__

=pod

=head1 NAME

Plack::Middleware::Throttle::Lite::Backend::Abstract - Base class for Throttle::Lite backends

=head1 VERSION

version 0.05

=head1 DESCRIPTION

This class is provided as a base class for each storage backend. Any backend must inherit from it and provide
a set of methods described below.

=for Pod::Coverage new

=head1 ABSTRACT METHODS

=head2 init

Method invoked after object created. Might be used for initialize connections, setting up values in accessors
(see L</mk_attrs>) and so on.

=head2 reqs_done

This one should return total proceeded requests for current key (available via method L</cache_key>). If no requests done
it should return B<0>.

=head2 increment

This method should increment total proceeded requests by one for current key.

=head1 METHODS

=head2 mk_attrs

Allows to create a list of attributes (accessors) in the backend package. Basic usage is

    package My::Backend::Foo;

    use parent 'Plack::Middleware::Throttle::Lite::Backend::Abstract';
    __PACKAGE__->mk_attrs(qw(foo bar baz));

B<Warning!> You should be careful in picking attributes' names.

=head2 cache_key

Unique requester's identifier. Used to store number of requests. Basically it's a string contains

    throttle:$REMOTE_ADDR:$REMOTE_USER:$INTERVAL

where

=over 4

=item B<$REMOTE_ADDR>

A value of the $ENV{REMOTE_ADDR} (e.g. B<127.0.0.1>).

=item B<$REMOTE_USER>

A value of the $ENV{REMOTE_USER}. If this environment variable is not set, value B<nobody> will be used.

=item B<$INTERVAL>

This value depends on limits used and builds on server's local time. For C<per hour> limits it's like B<YYYYMMDDHH>,
for C<per day> limits - B<YYYYMMDD>. Y, M, D, H symbols mean part of current time: I<YYYY> - year, I<MM> - month,
I<DD> - day and I<HH> - hour.

=back

Typical values of the B<cache_key>

    throttle:127.0.0.1:nobody:2013032006
    throttle:10.90.90.90:chim:20130320

=head2 expire_in

Time (in seconds) formatted according to given limits of requests after which limits will be reset.

=head2 reqs_max

Returns maximum available requests.

=head2 requester_id

Returns a part of client indentifier. A value will changing via the main module L<Plack::Middleware::Throttle::Lite>.
In common, it's looks like

    throttle:$REMOTE_ADDR:$REMOTE_USER

See L</cache_key> for details about B<$REMOTE_ADDR> and B<$REMOTE_USER>.

=head2 settings

Returns some configuration parameters for given limits of requests.

=head2 units

Returns measuring units for given limits of requests.

=head2 ymdh

Returns value of current date and time according to given limits.

=head1 BACKENDS OVERVIEW

Each backend can be implemented in B<Plack::Middleware::Throttle::Lite::Backend> namespace or in your preferred
namespace like B<My::OwnSpace>. In this case you should provide full module name prepended with C<+> (plus) sign
in middleware's options.

    enable 'Throttle::Lite',
        backend => '+My::OwnSpace::MyBackend';

or (with options)

    enable 'Throttle::Lite',
        backend => [ '+My::OwnSpace::MyBackend' => { foo => 'bar', baz => 1 } ];

At the moment known the following storage backends:

=head2 Plack::Middleware::Throttle::Lite::Backend::Simple

Very simple (in-memory) storage backend. Shipped with this distribution. All data holds in memory.
See details L<Plack::Middleware::Throttle::Lite::Backend::Simple>.

=head2 Plack::Middleware::Throttle::Lite::Backend::Redis

Redis-driven storage backend. Take care about memory consumption, has re-connect feature
and can use tcp or unix-socket connection to the redis-server. See details
L<Plack::Middleware::Throttle::Lite::Backend::Redis>.

=head2 Plack::Middleware::Throttle::Lite::Backend::Memcached

Memcached-driven storage backend. See details L<Plack::Middleware::Throttle::Lite::Backend::Memcached>.

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/Wu-Wu/Plack-Middleware-Throttle-Lite/issues>

=head1 SEE ALSO

L<Plack::Middleware::Throttle::Lite>

L<Plack::Middleware::Throttle::Lite::Backend::Simple>

=head1 AUTHOR

Anton Gerasimov <chim@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Anton Gerasimov.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
