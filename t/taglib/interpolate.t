use Test::More;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use XML::LibXML;
use Try::Tiny;
use_ok('XML::XSP::TestTemplate');
my $template = XML::XSP::TestTemplate->new;
my $xml_file = 't/samples/taglib/interpolate.xsp';

my $doc = XML::LibXML->new->parse_file( $xml_file );

ok( $doc, "Source XML $xml_file parsed" );

use XML::XSP;
my $xsp = XML::XSP->new(
    taglibs => {
        'http://www.tamarou.com/public/basic/v1' => 'XML::XSP::TestTemplate::Taglib::Basic',
        'http://www.tamarou.com/public/bogus' => 'XML::XSP::TestTemplate::Taglib::NotThere',
    },
);

ok( $xsp );


my $package = $xsp->process( $doc );

ok ( $package, 'Compiled perl class created' );

#warn $package;

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

my $dom = $instance->xml_generator(undef, XML::LibXML::Document->new, undef);
ok( $dom, 'Doc returned from generated code' );

isa_ok( $dom, 'XML::LibXML::Document', 'Returned doc is a proper DOM tree');

my $xt = $template->xml_tester( xml => $dom->toString );

ok( $xt );

$xt->ok( '/page', 'Root element is "page"' );

$xt->ok( '/page/div[@class="reversed"]' );

my $reversed_content = $dom->findvalue('/page/div[@class="reversed"]/text()');

unlike $reversed_content, qr|}|, "interpolation failed.";

#warn $dom->toString(1);

done_testing();
