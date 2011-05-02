package XML::XSP::TestTemplate::Howdy;
use Moose::Role;

has default_greeting => (
    is          => 'rw',
    isa         => 'Str',
    default     => sub { 'Howdy!' },
);

1;