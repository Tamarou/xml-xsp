package XML::XSP::Default;
use Moose;
with 'XML::XSP::SAXUtils';
use Data::Dumper::Concise;

sub attribute_value_template {
    my $self = shift;
    my $input = shift;

    warn "AVT INPUT $input \n";
    # if the user turned off AVT interpolation or there are no
    # curlies in the value, just quote the input and return it.
    if ( $self->skip_avt_interpolation || $input !~ /{/ ) {
        return $self->quote_args( $input );
    }

    my $output = "''";

    while ($input =~ /\G([^{]*){/gc) {
        warn "outer: $1\n";
        $output .= "." . $self->quote_args( $1 ) if $1;
        if ($input =~ /\G{/gc) {
            $output .= ".q|{|";
            next;
        }

        # otherwise we're in code now...
        $output .= ".do{";

        while ($input =~ /\G([^}]*)}/gc) {
            warn "inner: $1\n";
            $output .= undouble_curlies( $1 );
            if ($input =~ /\G}/gc) {
                $output .= "}";
                next;
            }
            $output .= "}";
            last;
        }
    }
    $input =~ /\G(.*)$/gc and $output .= "." . $self->quote_args( undouble_curlies($1) );
    return $output;
}



sub undouble_curlies {
    my $value = shift;
    $value =~ s/\{\{/\{/g;
    $value =~ s/\}\}/\}/g;
    return $value;
}

sub start_element {
    my $self = shift;
    my $e = shift;
    my $code = '$parent = $self->add_element_node( $document, $parent, ' . $self->quote_args($e->{LocalName}, $e->{NamespaceURI}) . ');';

    foreach my $attr ( values %{$e->{Attributes}} ) {
        # attribute/value template

        my $value = $self->attribute_value_template( $attr->{Value} );
        if ( length $attr->{NamespaceURI} ) {
            $code .= '$parent->setAttributeNS(' . $self->quote_args($attr->{NamespaceURI}, $attr->{LocalName}) . ', ' . $value . ');';
        }
        else {
            $code .= '$parent->setAttribute(' . $self->quote_args($attr->{LocalName}) . ', ' . $value . ');';
        }
    }

    return $code;
}

sub characters {
    my $self = shift;
    my $text = shift;

    if ( $self->not_indented && $text->{Data} !~ /\S/ ) {
        return '';
    }

    return '$self->add_text_node($document, $parent, ' . $self->quote_args( $text->{Data}) . '); # non-xsp text' . "\n";
}

sub end_element {
    return '$parent = $parent->parentNode;' . "\n";
}

1;