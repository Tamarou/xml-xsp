<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:xspx="http:/tamarou.com/namespace/xspextended/v1"
    xmlns:web="http://axkit.org/NS/xsp/webutils/v1">

<xsl:template match="xsp:page">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
    <xsp:structure>
      <xsp:import>URI::Escape</xsp:import>
    </xsp:structure>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>

<xsl:template match="web:env_param">
<xsl:variable name="param-name" select="xspx:extract_value('name', .)"/>
<xsp:expr>$self->request->can('env') ? $self->request->env->{<xsl:value-of select="$param-name"/>} : $ENV{<xsl:value-of select="$param-name"/>}</xsp:expr>
</xsl:template>

<xsl:template match="web:url_escape|web:url_encode|web:uri_escape">
<xsl:choose>
    <xsl:when test=".//xsp:expr">
        <xsp:expr>URI::Escape::uri_escape(<xsl:copy-of select="./*"/>)</xsp:expr>
    </xsl:when>
    <xsl:otherwise>
        <xsp:expr>URI::Escape::uri_escape(qq|<xsl:copy-of select="./text()"/>|)</xsp:expr>
    </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="web:url_unescape|uri_unescape">
<xsl:choose>
    <xsl:when test=".//xsp:expr">
        <xsp:expr>URI::Escape::uri_unescape(<xsl:copy-of select="./*"/>)</xsp:expr>
    </xsl:when>
    <xsl:otherwise>
        <xsp:expr>URI::Escape::uri_unescape(qq|<xsl:copy-of select="./text()"/>|)</xsp:expr>
    </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="web:path_info">
<xsp:expr>$self->request->path_info || ''</xsp:expr>
</xsl:template>

<xsl:template match="web:query_string">
<xsp:expr>$self->request->env->{QUERY_STRING} || ''</xsp:expr>
</xsl:template>

<xsl:template match="web:request_uri">
<xsp:expr>$self->request->uri || ''</xsp:expr>
</xsl:template>

<xsl:template match="web:request_host">
<xsp:expr>$self->request->env->{HTTP_HOST} || $self->request->env->{SERVER_NAME} || ''</xsp:expr>
</xsl:template>

<xsl:template match="web:header">
<xsl:variable name="header-name" select="xspx:extract_value('name', .)"/>
<xsl:variable name="header-value" select="xspx:extract_value('value', .)"/>
<xsl:choose>
<xsl:when test="$header-value">
<xsp:logic>
$self->request->header(<xsl:value-of select="$name"/> => '<xsl:value-of select="$name"/>')
</xsp:logic>
</xsl:when>
<xsl:otherwise>
<xsp:expr>$self->request->header(<xsl:value-of select="$name"/>)</xsp:expr>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="web:match_user_agent">
<xsl:variable name="ua-name" select="xspx:extract_value('name', .)"/>
<xsp:expr>$self->request->user_agent =~ qr|<xsl:value-of select="$ua-name"/>|</xsp:expr>
</xsl:template>

<xsl:template match="web:username">
<xsp:expr>$self->request->user || ''</xsp:expr>
</xsl:template>

<xsl:template match="web:is_https">
<xsp:expr>$self->request->secure</xsp:expr>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>
</xsl:stylesheet>
