package XML::XSP::TestTemplate::Taglib::Basic;
use Moose;
with 'XML::XSP::SAXUtils';

sub namespace_uri { 'http://www.tamarou.com/public/basic/v1' };

sub start_element {
    warn "START\n";
    return '$wtf';
}

sub end_element {
    warn "END\n";
}

1;