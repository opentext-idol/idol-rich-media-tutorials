<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<!--OUTPUT PLAIN TEXT-->
	<xsl:output method="text" version="4.0" encoding="UTF-8"/>

	<!--STRIP WHITESPACE-->
	<xsl:strip-space elements="*"/>

	<!--MAIN-->
	<xsl:template match="/output">
		<xsl:apply-templates select="metadata/segment/importantRecord"/>
	</xsl:template>

	<!--FACE DETECTION-->
	<xsl:template match="FaceResult">

    <xsl:variable name="trackName" select="../trackname"></xsl:variable>
    <xsl:variable name="duration" select="../timestamp/duration"></xsl:variable>

		<xsl:text>{ </xsl:text>
		<xsl:text>"eventType" : "</xsl:text><xsl:value-of select="substring-after($trackName, '.')"/><xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"elapsedMSec" : </xsl:text><xsl:value-of select="$duration div 1000"/>
    <xsl:text> }</xsl:text>
    
	</xsl:template>

	<!--DO NOTHING-->
	<xsl:template match="timestamp|trackname"/>

</xsl:stylesheet>
