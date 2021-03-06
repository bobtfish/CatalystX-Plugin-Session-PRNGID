package SessionTest;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;


use Catalyst qw/
    +CatalystX::Plugin::Session::PRNGID
    Session::Store::FastMmap
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'SessionTest',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
);

# Start the application
__PACKAGE__->setup();


1;
