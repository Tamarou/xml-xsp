use Test::More;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use XML::LibXML;
use Carp qw(croak confess);
use Try::Tiny;
use Data::Dumper::Concise;
use_ok('XML::XSP::TestTemplate');
my $template = XML::XSP::TestTemplate->new;
my $xml_file = 't/samples/taglib/cookie.xsp';

my $doc = XML::LibXML->new->parse_file( $xml_file );

ok( $doc, "Source XML $xml_file parsed" );

use XML::XSP;
my $xsp = XML::XSP->new(
    taglibs => {
        'http://www.tamarou.com/public/cookie' => 'XML::XSP::TestTemplate::Taglib::Cookie',
    },
);

ok( $xsp );


my $package = $xsp->process( $doc );

ok ( $package, 'Compiled perl class created' );

warn $package;


try {
    eval $package;
}
catch {
    my $err = $_;
    die "$err";
    ok(0, "Package eval failed: $err");
};

my $package_name = $xsp->package_name;

can_ok( $package_name, qw(new xml_generator));

my $instance = $package_name->new;

can_ok( $instance, qw(xml_generator));

my $dom = undef;

try {
    $dom = $instance->xml_generator(undef, XML::LibXML::Document->new, undef);
}
catch {
    my $err = $_;
    confess $err;
};
ok( $dom, 'Doc returned from generated code' );

isa_ok( $dom, 'XML::LibXML::Document', 'Returned doc is a proper DOM tree');

warn $dom->toString;

my $resp = $instance->response;

ok($resp);

warn Dumper($resp);

done_testing();

=cut;

my $xt = $template->xml_tester( xml => $dom->toString );

ok( $xt );

$xt->ok( '/page', 'Root element is "page"' );

$xt->ok( '/page[@title]', 'Root element has a "title" attribute' );

$xt->is( 'count(/page/p)', 1, '"page" element has on "p" child' );

warn $dom->toString(1);

done_testing();