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

The code is deployed in production at http://dns-api.org/

=cut

=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2014 by Steve Kemp.  All rights reserved.

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

our $VERSION = '0.2';


=begin doc

Perform a lookup against DNS.

=end doc

=cut

sub lookup
{
    my (%params) = (@_);

    my $res = Net::DNS::Resolver->new();
    my $query =
      $res->search( $params{ 'domain' }, $params{ 'type' } ? $params{'type'} :  "any" );

    my @result;

    if ( $query )
    {
        foreach my $rr ( sort $query->answer )
        {
            my %obj = %{ $rr };

            my %x;
            foreach my $k ( keys %obj )
            {
                next
                  if ( ( $k eq "rdata" ) ||
                       ( $k eq "class" ) ||
                       ( $k eq "rdlength" ) );

                $x{ $k } = $obj{ $k };
            }
            push( @result, \%x );
        }
        return( @result );
    }

    @result = ();
    push( @result, { 'error' =>  $res->errorstring  } );
    return( @result );

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

    my $domain = params->{ 'domain' };
    my $rtype  = params->{ 'type' };

    my @results = lookup( domain => $domain,
                          type   => $rtype, );

    content_type 'application/json';
    return ( to_json( \@results ) );
};


#
#  Send our version
#
get '/version/?' => sub {

    content_type 'application/json';
    my %result = ( version => $VERSION );
    return ( to_json( \%result ) );
};

1;
