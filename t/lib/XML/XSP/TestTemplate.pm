package XML::XSP::TestTemplate;
use Moose;
use XML::XSP;

has new_xsp => (
    is          => 'ro',
    isa         => 'XML::XSP',
    lazy_build  => 1,
);

sub _build_new_xsp {
    return XML::XSP->new();
}

1;