package Plack::Middleware::Throttle::JSON;

use parent 'Plack::Middleware::Throttle::Lite';

use strict;
use warnings;

# Rejects incoming request with some reason
sub reject_request
{
    my ( $self, $reason, $code ) = @_;

    my $reasons = { blacklist => 'IP Address Blacklisted',
                    ratelimit => 'Rate Limit Exceeded',
                  };


    [200,
     ['Content-Type' => 'application/json'],
     ["[\n\t{\n\t\t\"error\": \"$reasons->{$reason}\"\n\t}\n]"]];

}


1;


__END__

=pod

=head1 NAME

Plack::Middleware::Throttle::JSON - Reject requests with JSON

=head1 VERSION

version 0.01

=head1 DESCRIPTION

This module overrides L<Plack::Middleware::Throttle::LITE> to return
error-messages as JSON, rather than using HTTP status-codes and plain-text
output.

It is useful because consumers of our API will expect JSON to be returned
and almost certainly don't contain error-handling.  Sigh.

=cut

=head1 AUTHOR

Steve Kemp <https://steve.kemp.fi>


=head1 LICENSE

Copyright (c) 2014 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut
