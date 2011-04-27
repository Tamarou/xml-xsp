package XML::XSP::Default;
use Moose;
with 'XML::XSP::SAXUtils';
use Data::Dumper::Concise;


sub start_element {
    my $self = shift;
    my $e = shift;
    my $code = '$parent = $self->add_element_node( $document, $parent, ' . $self->quote_args($e->{LocalName}, $e->{NamespaceURI}) . ');';

    foreach my $attr ( values %{$e->{Attributes}} ) {
        if ( length $attr->{NamespaceURI} ) {
            $code .= '$parent->setAttributeNS(' . $self->quote_args($attr->{NamespaceURI}, $attr->{LocalName}, $attr->{Value}) . ');';
        }
        else {
            $code .= '$parent->setAttribute(' . $self->quote_args($attr->{LocalName}, $attr->{Value}) . ');';
        }
    }

    return $code;
}

sub characters {
    my $self = shift;
    my $text = shift;
    return '$self->add_text_node($document, $parent, ' . $self->quote_args( $text->{Data}) . ');';
}

sub end_element {
    return '$parent = $parent->parentNode;' . "\n";
}

1;