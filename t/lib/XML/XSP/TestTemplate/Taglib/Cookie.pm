package XML::XSP::TestTemplate::Taglib::Cookie;
use Moose;

sub namespace_uri { 'http://www.tamarou.com/public/basic/v1' };

sub logicsheet {
    return *DATA;
}

1;

__DATA__
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:cookie="http://www.tamarou.com/public/cookie">

<xsl:template match="xsp:page">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>

<xsl:template match="cookie:create">
<xsl:variable name="name" select="@name|./cookie:name/text()"/>
<xsl:variable name="value" select="@value|./cookie:value/text()"/>
<xsp:logic>{
my $cookie_data = {};

<xsl:choose>
    <xsl:when test="@value">
    $cookie_data->{value} = '<xsl:value-of select="@value"/>';
    </xsl:when>
    <xsl:when test="./cookie:value">
        <xsl:choose>
        <xsl:when test="./cookie:value//xsp:expr">
            $cookie_data->{value} = qq|<xsl:copy-of select="./cookie:value/*"/>|;
        </xsl:when>
        <xsl:otherwise>
            $cookie_data->{value} = qq|<xsl:value-of select="cookie:value/text()"/>|;
        </xsl:otherwise>
        </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
        die "Cookie must have a 'value' attribute or child element.\n";
    </xsl:otherwise>
</xsl:choose>

$self->response->{cookies}->{<xsl:value-of select="$name"/>} = $cookie_data;
}</xsp:logic>
<meh><xsl:value-of select="$name"/></meh>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
