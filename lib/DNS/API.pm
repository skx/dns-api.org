#!/usr/bin/perl

=head1 NAME

DNS::API - A simple DNS API.

=cut

=head1 ABOUT

DNS::API is a simple L<Dancer> application which will respond to DNS
requests received via HTTP, with JSON-encoded results.

In brief HTTP requests will be made of the form:

=for example begin

   http://server.name:port/record/hostname

=for example end

Where I<record> is a string such as "A", "AAAA", "MX", "NS", and
I<hostname> is the name to query.

The returned data will be a JSON-encoded array of hashes.

=cut

=head1 Live Usage

The code is deployed in production at https://dns-api.org/

=cut

=head1 AUTHOR

 Steve
 --
 http://steve.kemp.fi/

=cut

=head1 LICENSE

Copyright (c) 2014-2016 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut



package DNS::API;


use strict;
use warnings;


use Net::DNS::Resolver;
use Dancer;
use JSON qw!!;

our $VERSION = '0.3';


=begin doc

Perform a lookup against DNS.

=end doc

=cut

sub lookup
{
    my (%params) = (@_);

    my $res = Net::DNS::Resolver->new( udp_timeout => 10,
                                       tcp_timeout => 10 );
    my $query;
    my @result;

    my $count = 0;
    my $retry = 5;

    while ( $count < $retry )
    {
        $query =
          $res->search( $params{ 'domain' },
                        $params{ 'type' } ? $params{ 'type' } : "any" );
        if ($query)
        {
            foreach my $rr ( sort $query->answer )
            {
                my %x;

                $x{ 'type' }  = $rr->type();
                $x{ 'ttl' }   = $rr->ttl();
                $x{ 'name' }  = $rr->name();
                $x{ 'value' } = $rr->rdstring();

                push( @result, \%x );
            }
            return (@result);
        }

        $count += 1;

    }

    @result = ();
    push( @result, { 'error' => $res->errorstring } );
    return (@result);

}



#
#  Serve the index-page.
#
get '/' => sub {
    send_file 'index.html';
};


#
#  Respond to a request.
#
get '/:type/:domain/?' => sub {

    my $rtype  = params->{ 'type' };
    my $domain = params->{ 'domain' };

    #
    # We always return JSON.
    #
    content_type 'application/json';

    #
    #  Ensure we have a known type
    #
    if ( $rtype !~ /^(A|AAAA|ANY|CNAME|MX|NS|PTR|SOA|TXT)$/i )
    {
        return '{"error":"Invalid lookup-type - use A|AAAA|ANY|CNAME|MX|NS|PTR|SOA|TXT"}';
    }

    #
    #  Ensure we're not handling abusive clients.
    #
    if ( $domain =~ /spamhaus.org/i )
    {
        return '{"error":"This service is not for RBL lookups"}';
    }

    my @results = lookup( domain => $domain,
                          type   => $rtype, );

    content_type 'application/json';

    my $json;

    # Try to work out if we're being tested by a browser
    # or not.  Just to be nice.
    my $lang = request->accept_language();

    if ( $lang && length($lang) )
    {
        $json = JSON->new->pretty;
    }
    else
    {
        $json = JSON->new;
    }

    my $out = $json->encode( \@results );
    return ($out);
};


#
#  Send our version
#
get '/version/?' => sub {

    content_type 'application/json';
    my %result = ( version => $VERSION );

    my $json = JSON->new();
    my $out  = $json->encode( \%result );
    return ($out);
};

1;
