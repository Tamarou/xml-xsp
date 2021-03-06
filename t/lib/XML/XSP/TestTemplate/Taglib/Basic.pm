package XML::XSP::TestTemplate::Taglib::Basic;
use Moose;
#with 'XML::XSP::SAXUtils';

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
    xmlns:basic="http://www.tamarou.com/public/basic/v1">

<xsl:template match="xsp:page">
<xsp:page>
  <xsl:apply-templates select="@*"/>

  <xsp:structure>
    <xsp:import>XML::XSP::TestTemplate::Taglib::Basic</xsp:import>
  </xsp:structure>
  <xsp:logic>
    sub backwards {
        my $arg = shift;
        return reverse $arg;
    }
  </xsp:logic>

  <xsl:apply-templates/>
</xsp:page>
</xsl:template>

<xsl:template match="basic:backwards">
    <xsl:choose>
        <xsl:when test=".//xsp:expr">
            <xsp:expr>backwards(<xsl:copy-of select="./*"/>)</xsp:expr>
        </xsl:when>
        <xsl:otherwise>
            <xsp:expr>backwards(qq|<xsl:copy-of select="./text()"/>|)</xsp:expr>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
