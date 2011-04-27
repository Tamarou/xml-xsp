package XML::XSP::Page;
use Moose;
use XML::LibXML;

has xml_document => (
    is          => 'ro',
    isa         => 'XML::LibXML::Document',
    required    => 1,
    default     => sub { XML::LibXML::Document->new },
);

sub add_element_node {
    my $self = shift;
    my ( $document, $parent_node, $tag_name, $ns_uri ) = @_;
    my $e = undef;

    if ( length $ns_uri ) {
        $e = $document->createElementNS( $ns_uri, $tag_name );
    }
    else {
        $e = $document->createElement( $tag_name );
    }

    if ( $parent_node) {
        $parent_node->appendChild( $e );
    }
    else {
        $document->setDocumentElement( $e );
    }

    return $e;
};


sub add_text_node {
    my $self = shift;
    my ( $document, $parent_node, $text ) = @_;
    my $node = $document->createTextNode($text);
    $parent_node->appendChild($node);
};


__PACKAGE__->meta->make_immutable;

1;