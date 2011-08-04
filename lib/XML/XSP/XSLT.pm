package XML::XSP::XSLT;
use Moose;
with 'Role::LibXSLT::Extender';

use Data::Dumper::Concise;

sub set_extension_namespace {
    return 'http:/tamarou.com/namespace/xspextended/v1'
}


sub extract_value {
    my $self = shift;
    my $name = shift;
    my $arg = shift;
    warn "NESTED" . Dumper( $arg );
}

1;