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
                die "Only Perl XSP pages are supported by this processor!";
            }
            if (my $interp = $attrs{'attribute-value-interpolate'} ) {
                # default is to interpolate
                $self->avt_uninterpolate if $interp eq 'no';
            }
        }
        when ( 'import' ) {
            return 'use ';
        }
        when ( 'element' ) {
            # XXX could do some error trapping here to (for example)
            # make sure this element isn't a child of <xsp:attribute>
            if (my $name = $attrs{'name'} ) {
                $self->unmanage_text;
                return '$parent = $self->add_element_node($document, $parent, ' . $self->quote_args($name) . ');';
            }
        }
        when ( 'logic' ) {
            # XXX
        }
        when ( 'attribute' ) {
            if (my $uri = $attrs{uri} ) {
                my $prefix = $attrs{prefix};
                my $local_name = $attrs{name};

                $self->attribute_name_seen;

                return '$parent->setNamespace(' .
                        $self->quote_args($uri, $prefix) . ', 0);' .
                        '$parent->setAttributeNS(' .
                        $self->quote_args($uri, $local_name) . ', ""';
            }

            # only here if no NS URI was found

            if ( my $name = $attrs{name} ) {
                $self->attribute_name_seen;

                # XXX prefix mapping?

                 return '$parent->setAttribute(' . $self->quote_args( $name ) .', ""';

            }

            $self->attribute_name_unset;
###
#         if (my $uri = $attribs{uri}) {
#             # handle NS attributes
#             my $prefix = $attribs{prefix} || die "No prefix given";
#             my $name = $attribs{name} || die "No name given";
#             $e->{attrib_seen_name} = 1;
#             return '$parent->setNamespace('.makeSingleQuoted($uri).', '.
#                                             makeSingleQuoted($prefix).', 0);'.
#                    '$parent->setAttributeNS('.makeSingleQuoted($uri).', '.
#                                               makeSingleQuoted($name).', ""';
#         }
#         if (my $name = $attribs{name}) {
#             $e->{attrib_seen_name} = 1;
#             # handle prefixed names
#             if ($name =~ s/^(.*?)://) {
#                 my $prefix = $1;
#                 return 'my $nsuri = $parent->lookupNamespaceURI(' . makeSingleQuoted($prefix) . ')'.
#                         ' || die "No namespace found with given prefix";'."\n".
#                         '$parent->setAttributeNS($nsuri,'.makeSingleQuoted($name).', ""';
#             }
#             return '$parent->setAttribute('.makeSingleQuoted($name).', ""';
#         }
#         $e->{attrib_seen_name} = 0;
###
        }
        when ( 'name' ) {
            if ( $parent && $parent->{LocalName} eq 'element' ) {
                return '$parent = $self->add_element_node($document, $parent, ""';
            }
            elsif ( $parent && $parent->{LocalName} eq 'attribute' ) {
                $self->attribute_name_seen;
                return '$parent->setAttribute(""';
            }
            else {
                die "XSP 'name' element found in invalid context: '". $parent->{LocalName} . "'";
            }
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
        warn "char current " . $self->current_tag . "\n";
        when ( /^(content|element)$/ ) {
            warn "CONTENT TAG\n";
            if ( $text =~ /\S/ || $self->xsp_indent ) {
                warn "INDENTY\n";
                return '$self->add_text_node($document, $parent, ' . $self->quote_args( $text) . ');';
            }
            return '';
        }
        when ( 'attribute' ) {
            warn "ATTR!!!! " . $self->attribute_name_unknown . "\n";
            return '' if $self->attribute_name_unknown;
            $text =~ s/^\s*//; $text =~ s/\s*$//;
            $text = $self->quote_args( $text );
            return ". $text ";
        }
        when ( /^(comment|name)$/ ) {
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
            return '$parent = $parent->getParentNode;' . "\n";
        }
        when ( 'attribute' ) {
            return ");\n";
        }
        when ( 'name' ) {
            if ( $parent && $parent->{LocalName} eq 'element' ) {
                return ");\n";
            }
            elsif ( $parent && $parent->{LocalName} eq 'attribute' ) {
                return ', ""';
            }
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
        when ( 'logic' ) {
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