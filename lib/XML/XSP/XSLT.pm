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
    my $nodelist = shift;
    my $node = $nodelist->shift;
    return undef unless $node;
    my $ns = $node->namespaceURI;
    my $prefix = $node->lookupNamespacePrefix( $ns );

    if (my $attr = $node->getAttributeNode( $name )) {
        return '"' . $attr->value . '"';
    }
    elsif ( (my $content) = $node->findnodes('./' . $prefix .':' . $name) ) {
        if ( (my $xsp_text) = $content->getChildrenByLocalName('text')) {
            return '"' . $xsp_text->textContent . '"';
        }
        elsif ( $content->exists('./*')) {
            return scalar $content->find('./*');
        }
        else {
            return '"' . $content->textContent . '"';
        }
    }
    return undef;
}

1;
