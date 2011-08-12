package XML::XSP::Handler;
use Moose;
use namespace::autoclean;
use MooseX::NonMoose;
extends 'XML::SAX::Base';
with 'XML::XSP::SAXUtils';
use XML::XSP::Default;
use XML::XSP::Core;
use XML::NamespaceSupport;

use Data::Dumper::Concise;

has compiled_package => (
    traits    => ['String'],
    is          => 'rw',
    isa         => 'Str',
    default     => sub { return '' },
    handles     => {
          add_to_package   => 'append',
          reset_package    => 'clear',
    },
);

has taglib_classes => (
    traits      => ['Array'],
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { [] },
);

has passthrough_handler => (
    is          => 'ro',
    isa         => 'XML::XSP::Default',
    lazy_build  => 1,
);

sub _build_passthrough_handler {
    my $self = shift;
    return XML::XSP::Default->new( context_stack => $self->context_stack );
}

has core_handler => (
    is          => 'rw',
    isa         => 'XML::XSP::Core',
);

has current_taglib => (
    is          => 'rw',
    isa         => 'Object',
);

has namespace_support => (
    is          => 'ro',
    isa         => 'XML::NamespaceSupport',
    default     => sub { XML::NamespaceSupport->new },
);

has package_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    default     => sub { 'Testy::Testerson' },
);

around 'start_element' => sub {
    my $orig = shift;
    my $self = shift;
    my $e = shift;
    $self->push_context( $e );
    return $self->$orig( $e );
};

around 'end_element' => sub {
    my $orig = shift;
    my $self = shift;
    my $e = shift;
    my $ret = $self->$orig( $e );
    $self->pop_context;
    return $ret;
};

sub start_document {
    my $self = shift;
    my $doc  = shift;
    $self->reset_package;
    $self->namespace_support->reset;
    $self->core_handler(
        XML::XSP::Core->new(
            xsp_manage_text            => $self->xsp_manage_text,
            context_stack              => $self->context_stack,
            xsp_avt_interpolate        => $self->xsp_avt_interpolate,
            xsp_indent                 => $self->xsp_indent,
            xsp_user_root              => $self->xsp_user_root,
            xsp_attribute_name_context => $self->xsp_attribute_name_context,
        )
    );

    my $code = join "\n",
        'package ' . $self->package_name . ';',
        'use Moose;',
        "extends 'XML::XSP::Page';",
        "use strict;",
        "use warnings;"
    ;
    $self->add_to_package( $code );
}

sub start_prefix_mapping {
    my $self = shift;
    my $map  = shift;
    $self->namespace_support->declare_prefix($map->{Prefix} => $map->{NamespaceURI});
}

sub start_element {
    my ($self, $e ) = @_;
    #warn Dumper( $e );

    # hand off to to the taglib if one is registered
    if ( length $e->{NamespaceURI} && $e->{NamespaceURI} eq $self->xsp_namespace ) {
        $self->manage_text;
        $self->add_to_package( $self->core_handler->start_element( $e ) );
    }
    else {
        # this permits class-level subs, attributes, etc by waiting until
        # the first non-XSP start element event to emit the main wrapper sub
        if ( $self->not_user_root ) {
            my $code = join "\n",
                "\n",
                'sub xml_generator {',
                'my $self = shift;',
                'my ($r, $document, $parent) = @_;',
                '$self->request($r) if defined $r;'
            ;
            $self->add_to_package( $code );
            $self->set_user_root;
        }

        $self->unmanage_text;
        $self->add_to_package( $self->passthrough_handler->start_element( $e ) );
    }
}

sub end_element {
    my ($self, $e ) = @_;

    # hand off to to the taglib if one is registered
    if ( length $e->{NamespaceURI} && $e->{NamespaceURI} eq $self->xsp_namespace ) {
        $self->add_to_package( $self->core_handler->end_element( $e ) );
    }
    else {
        $self->add_to_package( $self->passthrough_handler->end_element( $e ) );
    }

    if ( $self->context_depth == 1 ) {
        my $code = join "\n",
            "\n",
            'return $document;',
            '};'
        ;
        $self->add_to_package( $code );
    }
}

sub characters {
    my ($self, $text ) = @_;

    my $context_element = $self->current_element;


    if ( $context_element &&
         length $context_element->{NamespaceURI} &&
         $context_element->{NamespaceURI} eq $self->xsp_namespace ) {

        $self->add_to_package($self->core_handler->characters( $text ));
    }
    else {
        $self->add_to_package($self->passthrough_handler->characters( $text ));
    }
}


sub end_document {
    my $self = shift;
    my $code = join "\n",
        "\n",
        '__PACKAGE__->meta->make_immutable;',
        '1;'
    ;
    $self->add_to_package( $code );
    return $self->compiled_package;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
