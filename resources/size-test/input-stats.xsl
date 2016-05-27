<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0"
    xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/" xpath-default-namespace="http://www.daisy.org/z3986/2005/dtbook/">

    <xsl:output indent="yes"/>

    <xsl:template match="/*">
        <xsl:variable name="dtbooks"
            select="(
               document('552974.xml'),
               document('550284.xml'),
               document('552431.xml'),
               document('550148.xml'),
               document('553269.xml'),
               document('554569.xml'),
               document('554399.xml'),
               document('551848.xml'),
               document('554804.xml'),
               document('501093.xml'),
               document('555969.xml'),
               document('553098.xml'),
               document('501524.xml'),
               document('552739.xml'),
               document('550322.xml'),
               document('550247.xml'),
               document('554848.xml'),
               document('555509.xml'),
               document('553753.xml'),
               document('555809.xml'),
               document('553184.xml'),
               document('555508.xml'),
               document('552087.xml'),
               document('554664.xml'),
               document('501243.xml'),
               document('555968.xml'),
               document('555217.xml'),
               document('555082.xml'),
               document('501035.xml')
            )"/>

        <table>
            <thead>
                <th>Book ID</th>
                <th>Text nodes</th>
                <th>Words</th>
                <th>Tables</th>
                <th>Max table rows</th>
                <th>Max table cols</th>
                <th>Most used elements</th>
            </thead>
            <xsl:for-each select="$dtbooks">
                <xsl:call-template name="stats">
                    <xsl:with-param name="dtbook" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </table>
    </xsl:template>

    <xsl:template name="stats">
        <xsl:param name="dtbook" as="document-node()"/>
        <tr>
            <td>
                <xsl:value-of select="replace(replace(base-uri($dtbook),'.*/',''),'\..*','')"/>
            </td>
            <td>
                <xsl:value-of select="count($dtbook//text()[normalize-space()])"/>
            </td>
            <td>
                <xsl:value-of select="count($dtbook//text()[normalize-space()]/tokenize(.,'\s+'))"/>
            </td>
            <td>
                <xsl:value-of select="count($dtbook//dtbook:table)"/>
            </td>
            <td>
                <xsl:value-of select="max((0, $dtbook//dtbook:table//count(dtbook:tr)))"/>
            </td>
            <td>
                <xsl:value-of select="max((0, $dtbook//dtbook:table//dtbook:tr/count(dtbook:td)))"/>
            </td>
            <td>
                <xsl:variable name="names" select="$dtbook//*/name()"/>
                <xsl:variable name="names" as="element()*">
                    <xsl:for-each select="distinct-values($names)">
                        <xsl:sort select="."/>
                        <name count="{count($names[.=current()])}">
                            <xsl:value-of select="current()"/>
                        </name>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="names" as="element()*">
                    <xsl:for-each select="$names">
                        <xsl:sort select="number(@count)" order="descending"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="string-join(for $name in $names return concat($name,'(',$name/@count,')'),' ')"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
