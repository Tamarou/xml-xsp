package XML::XSP;
 # ABSTRACT: Stand-alone, modernized verion of the eXtensible Server Pages.
use Moose;
use XML::LibXML;
use Scalar::Util qw(reftype);
use XML::LibXSLT;
use XML::LibXML::SAX::Parser;
use XML::XSP::Handler;
use XML::Filter::BufferText;
use Perl::Tidy;
use Data::Dumper::Concise;
use Carp;
BEGIN { $SIG{__DIE__} = sub { Carp::confess(@_) } }

has config => (
    traits      => ['Hash'],
    is          => 'ro',
    isa         => 'HashRef[Str]',
    default     => sub { {} },
);

has taglibs => (
    traits      => ['Hash'],
    is          => 'ro',
    isa         => 'HashRef[Str]',
    default     => sub { {} },
    handles     => {
        registered_taglibs    => 'keys',
        fetch_taglib          => 'get',
    }
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
    handles     => [qw(package_name)],
);

sub _build_sax_handler {
    my $self = shift;
    return XML::XSP::Handler->new();
}

sub process {
    my $self = shift;
    my $dom  = shift;
    my $root = $dom->documentElement;
    my @used_taglibs = ();

    foreach my $taglib_uri ($self->registered_taglibs) {
        warn "Checking URI $taglib_uri\n";
        if ($root->findvalue("count(//*[namespace-uri()='$taglib_uri'])") > 0) {
            push @used_taglibs, $taglib_uri;
        }
    }

    my %loaded_processors = ();
    my $xsl_proc = XML::LibXSLT->new;

    foreach my $t (@used_taglibs) {
        my $logicsheet = undef;

        my $class_or_path = $self->fetch_taglib($t);
        if (-f $class_or_path ) {
            $logicsheet = XML::LibXML->load_xml(location => $class_or_path);
        }
        else {
            Class::MOP::load_class($class_or_path);
            my $obj = $class_or_path->new;
            $logicsheet = XML::LibXML->load_xml(IO => $obj->logicsheet);
        }
        my $stylesheet = $xsl_proc->parse_stylesheet($logicsheet);
        $dom = $stylesheet->transform( $dom );
    }

    warn "AFTER " . $dom->toString;


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
