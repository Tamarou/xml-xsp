package XML::XSP::TestTemplate::Taglib::Basic;
use Moose;
#with 'XML::XSP::SAXUtils';

sub namespace_uri { 'http://www.tamarou.com/public/basic/v1' };

sub logicsheet {
    return *DATA;
}


sub foo {
    my $self = shift;
    my $arg = shift;
    return "foo called with $arg";
}

1;

__DATA__
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:basic="http://www.tamarou.com/public/basic/v1">

<xsl:template match="xsp:page">
<xsp:page>
  <xsl:apply-templates select="@*"/>

  <xsp:structure>
    <xsp:include>use XML::XSP::TestTemplate::Taglib::Basic;</xsp:include>
  </xsp:structure>
  <xsp:logic>
  my $obj = XML::XSP::TestTemplate::Taglib::Basic->new();
  </xsp:logic>

  <xsl:apply-templates/>
</xsp:page>
</xsl:template>

<xsl:template match="basic:foo">
<!--
    <xsp:expr>
        XML::XSP::TestTemplate::Taglib::Basic::foo(<xsl:copy-of select="./*" />);
    </xsp:expr>

-->
<foo/>
<xsp:expr>$obj->foo()</xsp:expr>

</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
