
DNS-API.org
-----------

This repository contains the code for a simple daemon which provides
an online DNS-lookup service.

The service responds to request received via HTTP with a JSON-encoded
response, in the event of error this response will be empty.


Implementation
--------------

This application is written in Perl, and almost all parts of this code are
trivial.

* The HTTP-server uses [Dancer](http://search.cpan.org/dist/Dancer/)
* The DNS lookups are achieved via [Net::DNS::Resolver](http://search.cpan.org/perldoc?Net%3A%3ADNS%3A%3AResolver)


Installation
------------

Once this repository is cloned you may launch it via the provided
`run` script, which will cause the deamon to start on port 5001.

To deploy for the real world you'll need to install the dependencies
and place behind a reverse HTTP-proxy:

    # apt-get install twiggy libdancer-perl


Steve
--
