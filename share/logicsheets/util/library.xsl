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
<xsp:logic>{

my $cookie_data = {};

<xsl:variable name="cookie-value">
    <xsl:choose>
        <xsl:when test="@value">"<xsl:value-of select="@value"/>"</xsl:when>
        <xsl:when test="cookie:value">
            <xsl:call-template name="get-nested-content">
                <xsl:with-param name="content" select="cookie:value"/>
            </xsl:call-template>
        </xsl:when>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="cookie-name">
    <xsl:choose>
        <xsl:when test="@name">"<xsl:value-of select="@name"/>"</xsl:when>
        <xsl:when test="cookie:name">
            <xsl:call-template name="get-nested-content">
                <xsl:with-param name="content" select="cookie:name"/>
            </xsl:call-template>
        </xsl:when>
    <xsl:otherwise>
    feh
    </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

$cookie_data->{value} = <xsl:value-of select="$cookie-value"/>;


$self->response->{cookies}->{<xsl:value-of select="$cookie-name"/>} = $cookie_data;

<meh><xsl:value-of select="$cookie-name"/></meh>
}</xsp:logic>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>

  <xsl:template name="get-nested-content">
    <xsl:param name="content"/>
    <xsl:choose>
      <xsl:when test="$content/xsp:text">"<xsl:value-of select="$content"/>"</xsl:when>
      <xsl:when test="$content/*">
        <xsl:apply-templates select="$content/*"/>
      </xsl:when>
      <xsl:otherwise>"<xsl:value-of select="$content"/>"</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
