<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0">

  <!--OUTPUT PLAIN TEXT-->
  <xsl:output method="text" version="4.0" omit-xml-declaration="yes" encoding="UTF-8" indent="no"/>

  <!--STRIP WHITESPACE-->
  <xsl:strip-space elements="*"/>

  <!-- Variables -->
  <xsl:variable name="newLine">
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>

  <!-- Silence unwanted elements -->
  <xsl:template match="text()"/>


  <!-- Replace all occurences of a pattern within a string -->
  <xsl:template name="replaceAll">
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:param name="in"/>
    <xsl:choose>
      <xsl:when test="contains($in,$replace)">
        <xsl:value-of select="substring-before($in,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replaceAll">
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
          <xsl:with-param name="in" select="substring-after($in,$replace)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$in"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Escape special characters so that they can be written within quotes in JSON -->
  <xsl:template name="escapeText">
    <xsl:param name="string"/>
    <xsl:call-template name="replaceAll">
      <xsl:with-param name="replace">&quot;</xsl:with-param>
      <xsl:with-param name="with">\&quot;</xsl:with-param>
      <xsl:with-param name="in">
        <xsl:call-template name="replaceAll">
          <xsl:with-param name="replace">
            <xsl:text>&#x9;</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="with">\t</xsl:with-param>
          <xsl:with-param name="in">
            <xsl:call-template name="replaceAll">
              <xsl:with-param name="replace">
                <xsl:text>&#xA;</xsl:text>
              </xsl:with-param>
              <xsl:with-param name="with">\n</xsl:with-param>
              <xsl:with-param name="in">
                <xsl:call-template name="replaceAll">
                  <xsl:with-param name="replace">\</xsl:with-param>
                  <xsl:with-param name="with">\\</xsl:with-param>
                  <xsl:with-param name="in" select="$string"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Extract OCR field name -->
  <xsl:template name="getOcrFieldName">
    <xsl:param name="string"/>
    <xsl:param name="delimiter" select="'OCR_'"/>
    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:call-template name="escapeText">
          <xsl:with-param name="string" select="substring-after(substring-before($string, '.'), $delimiter)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Top-level outputs the JSON string -->
  <xsl:template match="/output">
    <xsl:text>{</xsl:text>
    <xsl:value-of select="$newLine"/>
    <xsl:apply-templates select="metadata/segment/importantRecord"/>
    <xsl:value-of select="$newLine"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="ObjectRecognitionResultAndImage">

    <xsl:text>  "TemplateMatch": "</xsl:text>
    <xsl:call-template name="escapeText">
      <xsl:with-param name="string" select="identity/identifier"/>
    </xsl:call-template>
    <xsl:text>",</xsl:text>
    <xsl:value-of select="$newLine"/>

    <xsl:text>  "TemplateScore": "</xsl:text>
    <xsl:value-of select="identity/confidence"/>
    <xsl:text>"</xsl:text>

  </xsl:template>

  <xsl:template match="OCRResult">

    <xsl:text>,</xsl:text>
    <xsl:value-of select="$newLine"/>

    <xsl:text>  "</xsl:text>
    <xsl:call-template name="getOcrFieldName">
      <xsl:with-param name="string" select="../trackname"/>
    </xsl:call-template>
    <xsl:text>": "</xsl:text>
    <xsl:call-template name="escapeText">
      <xsl:with-param name="string" select="text"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>

  </xsl:template>

</xsl:stylesheet>
