package XML::XSP::Taglib::IfParam;
use Moose;
use File::ShareDir qw();
use IO::File;
use Data::Dumper::Concise;

sub namespace_uri { 'http://axkit.org/NS/xsp/if-param/v1' };

sub logicsheet {
    my $file = File::ShareDir::module_file(__PACKAGE__, 'library.xsl');
    my $fh = IO::File->new($file);
    return $fh;
}

1;

