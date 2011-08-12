package XML::XSP::Page;
use Moose;
use XML::LibXML;

has xml_document => (
    is          => 'ro',
    isa         => 'XML::LibXML::Document',
    required    => 1,
    default     => sub { XML::LibXML::Document->new },
);

#XXX formalize the object types for request, context response.
has request => (
    is          => 'rw',
    isa         => 'Object',
);

has response => (
    is          => 'ro',
    isa         => 'Object',
    default     => sub { Class::MOP::load_class('Plack::Response'); return Plack::Response->new(200); }
    #required    => 1,
);

has context => (
    is          => 'ro',
    isa         => 'Object',
    #required    => 1,
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

sub add_comment_node {
    my $self = shift;
    my ($document, $parent, $text) = @_;
    my $node = $document->createComment($text);
    $parent->appendChild($node);
}

__PACKAGE__->meta->make_immutable;

1;
