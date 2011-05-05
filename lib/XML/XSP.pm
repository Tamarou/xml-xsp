package XML::XSP;
 # ABSTRACT: Stand-alone, modernized verion of the eXtensible Server Pages.
use Moose;
use XML::LibXML::SAX::Parser;
use XML::XSP::Handler;
use XML::Filter::BufferText;
use Perl::Tidy;
use Carp;
BEGIN { $SIG{__DIE__} = sub { Carp::confess(@_) } }

has config => (
    traits      => ['Hash'],
    is          => 'ro',
    isa         => 'HashRef[Str]',
    default     => sub { {} },
);

has taglibs => (
    traits      => ['Array'],
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
    default     => sub { [] },
    handles     => {
        get_taglibs => 'elements',
    },
);

sub _build_taglibs {
    return [];
    my $conf = shift->config;
    return defined $conf->{taglibs} ? $conf->{taglibs} : [];
}

has sax_generator => (
    is          => 'ro',
    isa         => 'XML::LibXML::SAX::Parser',
    lazy_build  => 1,
);

has sax_filter_buffertext => (
    is          =>  'ro',
    isa         =>  'XML::Filter::BufferText',
    lazy_build  => 1,
);

sub _build_sax_filter_buffertext {
    my $self = shift;
    return XML::Filter::BufferText->new(
        Handler => $self->sax_handler
    );
}

sub _build_sax_generator {
    return XML::LibXML::SAX::Parser->new(
        Handler         => shift->sax_filter_buffertext,
        line_numbers    => 1
    );
}

has sax_handler => (
    is          => 'ro',
    isa         => 'XML::XSP::Handler',
    lazy_build  => 1,
    handles     => [qw(package_name register_taglib)],
);

sub _build_sax_handler {
    my $self = shift;
    my $taglibs = $self->taglibs;
    my $xsp = XML::XSP::Handler->new();

    foreach my $package_name ( $self->get_taglibs ) {
        $xsp->register_taglib( $package_name );
    }

    return $xsp;
}

sub process {
    my $self = shift;
    my $dom  = shift;
    my $code = $self->sax_generator->generate( $dom );

    #XXX make this a config flag
    my $tidied = undef;
    my $errors = undef;

    Perl::Tidy::perltidy(
        source => \$code,
        destination => \$tidied,
        stderr => \$errors,
        argv => '-se -npro -f -nsyn -pt=2 -sbt=2 -csc -csce=2 -vt=1 -lp -cab=3 -iob'
    );

    warn "could not tidy: $errors" if $errors;
    return $tidied;
}

1;
