package XML::XSP::SAXUtils;
use Moose::Role;

has context_stack => (
    traits          => ['Array'],
    is              => 'ro',
    isa     => 'ArrayRef[HashRef]',
    default => sub { [] },
    handles => {
        push_context    => 'push',
        context_depth   => 'count',
        pop_context     => 'pop',
    },
);

has xsp_manage_text => (
    traits      => ['Bool'],
    is          => 'rw',
    isa         => 'Bool',
    default     => sub { 0 },
    required    => 1,
    handles     => {
        manage_text     => 'set',
        unmanage_text   => 'unset',
        is_non_xsp_text => 'not',
    },
);

has xsp_indent => (
    traits      => ['Bool'],
    is          => 'rw',
    isa         => 'Bool',
    default     => sub { 1 },
    required    => 1,
    handles     => {
        indent_result   => 'set',
        unindent_result => 'unset',
        not_indented    => 'not',
    },
);

has xsp_attribute_name_context => (
    traits      => ['Bool'],
    is          => 'rw',
    isa         => 'Bool',
    default     => sub { 0 },
    required    => 1,
    handles     => {
        attribute_name_seen    => 'set',
        attribute_name_unset   => 'unset',
        attribute_name_unknown => 'not',
    },
);

has xsp_avt_interpolate => (
    traits      => ['Bool'],
    is          => 'rw',
    isa         => 'Bool',
    default     => sub { 1 },
    required    => 1,
    handles     => {
        avt_interpolate        => 'set',
        avt_uninterpolate      => 'unset',
        skip_avt_interpolation => 'not',
    },
);

has character_buffer => (
    traits      => ['String'],
    is          => 'rw',
    isa         => 'Str',
    default     => sub { return '' },
    handles     => {
          add_to_buffer   => 'append',
          reset_buffer    => 'clear',
    },
);

sub current_tag {
    my $self = shift;
    return undef unless $self->context_depth;
    my $stack = $self->context_stack;
    return $stack->[-1]->{LocalName};
}

sub current_element {
    my $self = shift;
    return undef unless $self->context_depth;
    my $stack = $self->context_stack;
    return $stack->[-1];
}

sub quote_args {
    my $self = shift;
    my @args = @_;
    no warnings 'uninitialized';
    @args = map { 'q|' . $_ . '|' } @args;

    return join ", ", @args;
}

sub parent {
    my $self = shift;
    return undef unless $self->context_depth > 1;
    my $stack = $self->context_stack;
    return $stack->[-2];
}

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

1;