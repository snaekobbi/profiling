<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:math="http://exslt.org/math" version="2.0" xmlns:f="#">

    <!-- Use this XSLT on an XML file if it contains content that you cannot share publicly. All characters in text nodes will be replaced with another random character. -->
    
    <xsl:output indent="no"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:for-each select="string-to-codepoints(.)">
            <xsl:choose>
                <xsl:when test=". &lt;= 64 or . &gt;= 123 or (. &gt;= 91 and . &lt;= 96)">
                    <!-- not a letter -->
                    <xsl:value-of select="codepoints-to-string(.)"/>

                </xsl:when>
                <xsl:when test=". &lt;= 90">
                    <!-- upper case -->
                    <xsl:value-of select="codepoints-to-string(f:random(26) + 65)"/>

                </xsl:when>
                <xsl:otherwise>
                    <!-- lower case -->
                    <xsl:value-of select="codepoints-to-string(f:random(26) + 97)"/>

                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- returns an integer greater than or equal to 0 and less than $range -->
    <xsl:function name="f:random" as="xs:integer">
        <xsl:param name="range" required="yes" as="xs:integer"/>
        <xsl:value-of select="(floor(math:random()*$range) mod $range)"/>
    </xsl:function>
    
    <!-- exceptions -->
    
    <!-- newline after xml declaration -->
    <xsl:template match="/">
        <xsl:text>
</xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template match="html:style | html:script">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
