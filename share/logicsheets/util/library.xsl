<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsp="http://www.apache.org/1999/XSP/Core"
    xmlns:xspx="http:/tamarou.com/namespace/xspextended/v1"
    xmlns:util="http://apache.org/xsp/util/v1">

<xsl:template match="xsp:page">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>

<xsl:template match="util:include_file">
<xsl:variable name="filename" select="xspx:extract_value('name', .)"/>
<xsp:logic>{
my $dom = XML::LibXML->load_xml( location => <xsl:value-of select="$filename"/> );
my $root = $dom->getDocumentElement;
# $document and $parent scoped to the generated wrapper sub
$document->importNode($root);
$parent->appendChild($root);
}</xsp:logic>
</xsl:template>

<xsl:template match="util:include_uri">
<xsl:variable name="href" select="xspx:extract_value('href', .)"/>
<xsp:logic>{
my $dom = XML::LibXML->load_xml( location => <xsl:value-of select="$href"/> );
my $root = $dom->getDocumentElement;
# $document and $parent scoped to the generated wrapper sub
$document->importNode($root);
$parent->appendChild($root);
}</xsp:logic>
</xsl:template>

<xsl:template match="util:include_expr">
<xsl:variable name="fragment" select="./*"/>
<xsp:logic>{
my $dom = XML::LibXML->load_xml( string => <xsl:value-of select="$fragment"/> );
my $root = $dom->getDocumentElement;
# $document and $parent scoped to the generated wrapper sub
$document->importNode($root);
$parent->appendChild($root);
}</xsp:logic>
</xsl:template>

<xsl:template match="util:include_uri">
<xsl:variable name="href" select="xspx:extract_value('href', .)"/>
<xsp:logic>{
my $dom = XML::LibXML->load_xml( location => <xsl:value-of select="$href"/> );
my $root = $dom->getDocumentElement;
# $document and $parent scoped to the generated wrapper sub
$document->importNode($root);
$parent->appendChild($root);
}</xsp:logic>
</xsl:template>

<xsl:template match="@*|*|text()|processing-instruction()">
    <xsl:copy>
        <xsl:apply-templates select="@*|*|text()|processing-instruction()" />
    </xsl:copy>
</xsl:template>
</xsl:stylesheet>
