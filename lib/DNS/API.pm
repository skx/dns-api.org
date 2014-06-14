
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
    my ( $record, $type ) = (@_);

    $type ||= "any";

    my $res = Net::DNS::Resolver->new;
    my $query = $res->search( $record, $type );

    my @result;

    if ($query)
    {
        foreach my $rr (sort $query->answer )
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
    }

    @result;
}



get '/' => sub {
    send_file 'index.html';
};

get '/:type/:domain/?' => sub {

    my $domain  = params->{ 'domain' };
    my $rtype   = params->{ 'type' };
    my @results = lookup( $domain, $rtype );

    content_type 'application/json';

    return ( to_json( \@results ) );
};


1;
