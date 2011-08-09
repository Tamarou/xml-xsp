<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:xspx="http:/tamarou.com/namespace/xspextended/v1"
    xmlns:param="http://axkit.org/NS/xsp/param/v1">

<xsl:template match="xsp:page">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>

<xsl:template match="param:*">
<xsp:logic>
use Data::Dumper::Concise;
my @p = $self->request->param;
warn Dumper( \@p );
</xsp:logic>

<xsp:expr>$self->request->param(q|<xsl:value-of select="local-name()"/>|) || ''</xsp:expr>
</xsl:template>


<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>
</xsl:stylesheet>
