package CatalystX::Plugin::Session::PRNGID;

use Moose;
extends 'Catalyst::Plugin::Session';
use namespace::clean -except => 'meta';
use Math::Random::ISAAC;

=head1 NAME

CatalystX::Plugin::Session::PRNGID - The great new CatalystX::Plugin::Session::PRNGID!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has prng => (is => 'ro', lazy => 1, builder => '_build_prng');

sub _build_prng
{
    my $self = shift;
    return Math::Random::ISAAC->new(rand, localtime);
}

=head1 SYNOPSIS

An extension to Catalyst::Plugin::Session to use a more PRNG for the random 
numbers in the session id's.

    use Catalyst qw/
        Session
        Session::Store::FastMmap
        Session::State::Cookie
        +CatalystX::Plugin::Session::PRNGID
    /;

Note that this module should be loaded *after* the Session plugin. 
It overrides one of the Session plugins methods.

=head1 METHODS

=head2 prng

This is the PRNG for use in the session hash seed.  This is initialised with a 
Math::Random::ISAAC object.  If you provide an alternative on construction
you can replace the PRNG.  

=head2 session_hash_seed

The session hash seed is the function overriden to use the L<Math::Random::ISAAC>
PRNG instead of rand.  This gives a reasonable promise of unpredictable random
numbers, rather than numbers that should be evenly distributed over the range 
of possible numbers.  

=cut

my $counter;
override session_hash_seed => sub
{
    my $c = shift;

    return join( "", ++$counter, time, $c->prng->rand, $$, {}, overload::StrVal($c), );
};

=head1 AUTHOR

Colin Newell, C<< <colin.newell at gmail.com> >>

=head1 BUGS

I'm not entirely sure whether this is the best approach to generating the session
id's as perversely the hashing of the random number may actually remove some of
the randomness.  This module is hopefully solving the 'rand' not being the right
sort of random problem, it doesn't try to alter the fundamental way the session
id is then generated.

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