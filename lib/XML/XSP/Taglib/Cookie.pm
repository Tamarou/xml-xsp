package XML::XSP::Taglib::Cookie;
use Moose;
use File::ShareDir qw();
use IO::File;
use Data::Dumper::Concise;

sub namespace_uri { 'http://www.tamarou.com/public/basic/v1' };

sub logicsheet {
    my $file = File::ShareDir::module_file(__PACKAGE__, 'library.xsl');
    warn "file: $file\n";
    my $fh = IO::File->new($file);
    return $fh;
}

1;

