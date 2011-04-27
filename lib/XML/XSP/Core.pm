package XML::XSP::Core;
use feature "switch";
use Moose;
with 'XML::XSP::SAXUtils';

use Data::Dumper::Concise;


sub start_element {
    my $self = shift;
    my $e = shift;
    #warn "Core DEPTH " . $self->context_depth . " " . Dumper( $self->context_stack ) . "\n";

    my $parent = $self->parent;

    # cheesy convenience hack
    my %attrs = ();
    foreach my $attrib (values ( %{$e->{Attributes}}) ) {
        $attrs{$attrib->{LocalName}} = $attrib->{Value};
    }

    # tag dispatching
    given ( $e->{LocalName} ) {
        when ( 'page' ) {
            if ($attrs{language} && lc($attrs{language}) ne 'perl') {
                die "Only Perl XSP pages supported at this time!";
            }
            #XXX look into attribute interpolation and user-defined base class here
        }
        when ( 'import' ) {
            return 'use ';
        }
        when ( 'element' ) {
            # XXX
        }
        when ( 'logic' ) {
            # XXX
        }
        when ( 'attribute' ) {
            # XXX
        }
        when ( 'name' ) {
            # XXX
        }
        when ( 'pi' ) {
            # XXX ???
        }
        when ( 'comment' ) {
            # XXX
        }
        when ( 'text' ) {
            # XXX
        }
        when ( 'expr' ) {
            if ( $self->is_non_xsp_text || ($parent && $parent->{LocalName} =~ /(content|element)/) ) {
                return '$self->add_text_node($document, $parent, "" . do { ';
            }
            elsif ( $parent && $parent->{LocalName} =~ /(expr|logic)/ ) {
                return ' do {';
            }
            else {
                return ' . do {';
            }
        }
        default {
            warn "Unknown XSP element '" . $e->{LocalName} . "'\n";
        }
    }
    return '';
}

sub characters {
    my $self = shift;
    my $chars = shift;
    my $text = $chars->{Data};

    given ( $self->current_tag ) {
        when ( /^(content|element)$/ ) {
            return '$self->add_text_node($document, $parent, ' . $self->quote_args( $text) . ');';
        }
        when ( /^(attribute|comment|name)$/ ) {
            $text =~ s/^\s*//; $text =~ s/\s*$//;
            $text = $self->quote_args( $text );
            return ". $text ";
        }
    }

    return $text;
}

sub end_element {
    #warn "core end\n";
    my $self = shift;
    my $e = shift;
    my $code = $self->character_buffer;
    my $parent = $self->parent;

    given ( $e->{LocalName} ) {
        when ( 'page' ) {
            #XXX
        }
        when ( 'import' ) {
            #XXX
        }
        when ( 'element' ) {
            # XXX
        }
        when ( 'attribute' ) {
            # XXX
        }
        when ( 'name' ) {
            # XXX
        }
        when ( 'pi' ) {
            # XXX ???
        }
        when ( 'comment' ) {
            # XXX
        }
        when ( 'text' ) {
            # XXX
        }
        when ( 'expr' ) {
            if ( $self->is_non_xsp_text || ($parent && $parent->{LocalName} =~ /(content|element)/) ) {
                $code .= '}); #core tag ' . "\n";
            }
            else {
                $code .= '} ';
        }
        }
        default {
            warn "Unknown XSP element '" . $e->{LocalName} . "'\n";
        }
    }

    $self->reset_buffer;
    return $code;
}

1;