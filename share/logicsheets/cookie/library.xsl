<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:xspx="http:/tamarou.com/namespace/xspextended/v1"
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
<xsl:variable name="cookie-name" select="xspx:extract_value('name', .)"/>
<xsl:variable name="expires" select="xspx:extract_value('expires', .)"/>
<xsl:variable name="path" select="xspx:extract_value('path', .)"/>
<xsl:variable name="domain" select="xspx:extract_value('domain', .)"/>
<xsl:variable name="secure" select="xspx:extract_value('secure ', .)"/>

<xsl:if test="$expires">
$cookie_data->{expires} = <xsl:value-of select="$expires"/>;
</xsl:if>

<xsl:if test="$path">
$cookie_data->{path} = <xsl:value-of select="$path"/>;
</xsl:if>

<xsl:if test="$domain">
$cookie_data->{domain} = <xsl:value-of select="$domain"/>;
</xsl:if>

<xsl:if test="$secure">
$cookie_data->{secure} = <xsl:value-of select="$secure"/>;
</xsl:if>

$cookie_data->{value} = <xsl:value-of select="xspx:extract_value('value', .)"/>;

$self->response->{cookies}->{<xsl:value-of select="$cookie-name"/>} = $cookie_data;

}</xsp:logic>
</xsl:template>

<xsl:template match="cookie:fetch">
<xsl:variable name="cookie-name" select="xspx:extract_value('name', .)"/>
<xsl:if test="$cookie-name">
    <xsp:expr>$self->request->cookies->{<xsl:value-of select="$cookie-name"/>} || ''</xsp:expr>
</xsl:if>
</xsl:template>


<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>
</xsl:stylesheet>
