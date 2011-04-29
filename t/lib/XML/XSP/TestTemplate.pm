package XML::XSP::TestTemplate;
use Moose;
use XML::XSP;
use Test::XPath;

has new_xsp => (
    is          => 'ro',
    isa         => 'XML::XSP',
    lazy_build  => 1,
);

sub _build_new_xsp {
    return XML::XSP->new();
}

sub xml_tester {
    my $self = shift;
    return Test::XPath->new( @_ );
}

1;