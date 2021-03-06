package CatalystX::Plugin::Session::PRNGID;

use Moose;
use Math::Random::ISAAC;
use MRO::Compat;
use namespace::clean -except => 'meta';

extends 'Catalyst::Plugin::Session';
with 'Catalyst::ClassData';

=head1 NAME

CatalystX::Plugin::Session::PRNGID - More random Session id generation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


__PACKAGE__->mk_classdata('prng');
__PACKAGE__->mk_classdata('random_device', '/dev/random');


# N.B. Each Math::Random::ISAAC object outputs 32 bits of pseudo random
#      number per round.
#      We want to feed the digest algorithm one block, i.e. 512 bits
#      ergo we get 16 PRNGs to get that much randomness
#      Initializing a Math::Random::ISAAC state uses 256 seeds of 32
#      bits (i.e. 4 bytes)
#      Note that this means we need 16k of randomness to start up!
sub setup_finalize {
    my $app = shift;
    $app->prng([ map { Math::Random::ISAAC->new( map { $app->generate_seed } 1..255) } 1..16 ]);
    $app->next::method(@_);
}

sub generate_seed {
    my $self = shift;

    open my $fh, "<", $self->random_device;
    read $fh, my $bytes, 4;
    close $fh;
    return unpack("I*", $bytes);
}


=head1 SYNOPSIS

An extension to Catalyst::Plugin::Session to use a PRNG for the random 
numbers in the session id's and seed it from /dev/random.  Use this 
module in your list of plugins instead of the Session plugin.  It inherits 
from it and overrides some of the id generation methods.

    use Catalyst qw/
        +CatalystX::Plugin::Session::PRNGID
        Session::Store::FastMmap
        Session::State::Cookie
    /;

The default Session id generation looks good when you look at the resulting 
id because it is hashed.  If you look at the source data that generates it
however it doesn't have very high entropy.  Using the burp sequencer suggests
that the raw data has an entropy of 13 bits, which it rates as poor.

This plugin uses a PRNG and generates several random numbers, to get more
bits of randomness to insert into the id before hashing.  The PRNG used is the 
ISAAC PRNG.  Primarily because I could find a module for it on CPAN and it 
doesn't appear to have any major vulnerabilities, at least at the time of 
constructing this module.  The PRNG is quick so it shouldn't impact your 
sites performance.

=head1 METHODS

=head2 iterations

The number of iterations is the number of times it generates a random number
to put in the session id.  This defaults to 16.  The PRNG is fast so this 
shouldn't be too taxing.

=head2 random_device

This is the device used for the random seed for the PRNG.  This will be used
at startup by every catalyst process you have.  It defaults to /dev/random.

If you don't have a device (i.e. not on a *nix system) look to override 
the L<generate_seed> method.

=head2 prng

This is the PRNG for use in the session hash seed.  This is initialised with a 
Math::Random::ISAAC object.  If you provide an alternative on construction
you can replace the PRNG.  

=head2 generate_seed

This method generates the seed for the PRNG.  This reads from /dev/random
which won't work for non *nix boxes.  Override this to use a different source
of randomness.  Just remember that the PRNG is only as secure as the randomness
for the seed.  For more security use /dev/random.

=head2 session_hash_seed

The session hash seed is the function overriden to use the L<Math::Random::ISAAC>
PRNG instead of rand.  This gives a reasonable promise of unpredictable random
numbers, rather than numbers that should be evenly distributed over the range 
of possible numbers.  

=head2 setup_finalize

This initialises the prng at application startup.

=cut

sub session_hash_seed {
    my $c = shift;

    return join '', map { pack("N", $_->irand) } @{ $c->prng };
}

=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

You probably want to install Math::Random::ISAAC::XS, it's not explicitly in the 
dependencies because I'm not sure that it will install on all platforms.  It's the
usual deal though, if you can, it's supposed to be faster.

Please report any bugs or feature requests to C<bug-catalystx-plugin-session-prngid at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CatalystX-Plugin-Session-PRNGID>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CatalystX::Plugin::Session::PRNGID


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CatalystX-Plugin-Session-PRNGID>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CatalystX-Plugin-Session-PRNGID>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CatalystX-Plugin-Session-PRNGID>

=item * Search CPAN

L<http://search.cpan.org/dist/CatalystX-Plugin-Session-PRNGID/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Colin Newell.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of CatalystX::Plugin::Session::PRNGID
