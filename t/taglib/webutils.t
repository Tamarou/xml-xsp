use Test::More;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use XML::LibXML;
use Try::Tiny;
use Plack::Request;
use URI::Escape ();

use_ok('XML::XSP::TestTemplate');
use_ok('XML::XSP');

my $template = XML::XSP::TestTemplate->new;
my $xml_file = 't/samples/taglib/webutils.xsp';

my $doc = XML::LibXML->new->parse_file( $xml_file );

ok( $doc, "Source XML $xml_file parsed" );

my $qs = 'option1=first_option';

my $req = Plack::Request->new({
    REQUEST_METHOD    => 'GET',
    SERVER_PROTOCOL   => 'HTTP/1.1',
    SERVER_PORT       => 80,
    SERVER_NAME       => 'example.com',
    SCRIPT_NAME       => '/foo',
    REMOTE_ADDR       => '127.0.0.1',
    QUERY_STRING      => $qs,
    'psgi.version'    => [ 1, 0 ],
    'psgi.input'      => undef,
    'psgi.errors'     => undef,
    'psgi.url_scheme' => 'http',
});

my $xsp = XML::XSP->new(
    taglibs => {
        'http://axkit.org/NS/xsp/webutils/v1' => 'share/logicsheets/web_utils/library.xsl',
    },
);

ok( $xsp );


my $package = $xsp->process( $doc );

ok ( $package, 'Compiled perl class created' );

try {
    eval $package;
}
catch {
    my $err = $_;
    die "$err";
    ok(0, "Package eval failed: $err");
};

#warn $package;

my $package_name = $xsp->package_name;

can_ok( $package_name, qw(new xml_generator));

my $instance = $package_name->new();

can_ok( $instance, qw(xml_generator));

my $dom = undef;

try {
    $dom = $instance->xml_generator($req, XML::LibXML::Document->new, undef);
}
catch {
    my $err = $_;
    confess $err;
};
ok( $dom, 'Doc returned from generated code' );

isa_ok( $dom, 'XML::LibXML::Document', 'Returned doc is a proper DOM tree');

my $resp = $instance->response;

ok($resp->cookies);

my $xt = $template->xml_tester( xml => $dom->toString );

ok( $xt );

$xt->ok( '/html', 'Root element is "html"' );

$xt->is( '/html/body/div[@id="url_encode1"]/p/text()', URI::Escape::uri_escape('fill in the blanks'), 'Plain string encoded.');

$xt->is( '/html/body/div[@id="url_encode2"]/p/text()', URI::Escape::uri_escape('fill in the blanks'), 'Interpolated string encoded.');

$xt->is( '/html/body/div[@id="env_param"]/p/text()', $qs, 'Environment parameter.');

$xt->is( '/html/body/div[@id="query_string"]/p/text()', $qs, 'Query string.');

$xt->is( '/html/body/div[@id="request_uri"]/p/text()', 'http://example.com/foo?option1=first_option', 'Request URI.');

$xt->is( '/html/body/div[@id="request_host"]/p/text()', 'example.com', 'Request URI.');

$xt->is( '/html/body/div[@id="is_https"]/p/text()', '', 'Secure request.');

#warn $dom->toString(1);

done_testing();
