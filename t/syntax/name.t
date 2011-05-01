use Test::More;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use XML::LibXML;
use Try::Tiny;
use Data::Dumper::Concise;
use_ok('XML::XSP::TestTemplate');

my $template = XML::XSP::TestTemplate->new;
my $xml_file = 't/samples/name.xsp';

my $doc = XML::LibXML->new->parse_file( $xml_file );

ok( $doc, "Source XML $xml_file parsed" );

my $xsp = $template->new_xsp;

my $package = $xsp->process( $doc );

ok ( $package, 'Compiled perl class created' );

warn $package;

try {
    eval "$package";
}
catch {
    my $err = $_;
    ok(0, "Package eval failed: $err");
};

my $package_name = $xsp->package_name;

can_ok( $package_name, qw(new xml_generator));

my $instance = $package_name->new;

ok( $instance->can('xml_generator'), 'Si Se Puede!');

my $dom = $instance->xml_generator(undef, XML::LibXML::Document->new, undef);
ok( $dom, 'Doc returned from generated code' );

isa_ok( $dom, 'XML::LibXML::Document', 'Returned doc is a proper DOM tree');

my $xt = $template->xml_tester( xml => $dom->toString );

ok( $xt );

$xt->ok( '/page', 'Root element is "page"' );

$xt->ok( '/page/unobtainium', 'Dynamically-named element "unobtainium" created.' );

# $xt->is( '/page/baldrick', 'Um, some beans and some beans is some beans.', 'Interpolation worked.' );
#
# $xt->ok( '/page/join', 'Join element created.' );
#
# $xt->is( '/page/join', 'some::some::some', 'Inlined function works' );

warn $dom->toString(1);

done_testing();