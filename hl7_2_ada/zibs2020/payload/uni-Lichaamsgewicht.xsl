<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright © Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:hl7="urn:hl7-org:v3" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="language" as="xs:string?">nl-NL</xsl:param>

    <xsl:variable name="templateId-lichaamsgewicht" as="xs:string*" select="'2.16.840.1.113883.2.4.3.11.60.121.10.19', '2.16.840.1.113883.2.4.3.11.60.7.10.28', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9123'"/>
    
    <xd:doc>
        <xd:desc>Mapping of HL7 CDA templates <xd:ref name="templateId-lichaamsgewicht" type="variable"></xd:ref> to Lichaamsgewicht concept in ADA. 
                 Created for MP, currently only supports fields used in MP</xd:desc>
        <xd:param name="in">HL7 Node to consider in the creation of the ada element</xd:param>
        <xd:param name="zibroot">Optional. The ada  element to be outputted with this HCIM, will be copied in ada element</xd:param>
    </xd:doc>
    <xsl:template name="uni-Lichaamsgewicht" match="hl7:observation" as="element()*" mode="doUniLichaamsgewicht">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="zibroot" as="element()?"/>

        <xsl:for-each select="$in">
            <!-- body_weight -->
            <xsl:variable name="elemName">
                <xsl:choose>
                    <xsl:when test="$language = 'nl-NL'">lichaamsgewicht</xsl:when>
                    <xsl:otherwise>body_weight</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <lichaamsgewicht>

                <xsl:choose>
                    <!-- zibroot, left here for backwards compatibility reasons -->
                    <xsl:when test="$zibroot">
                        <xsl:copy-of select="$zibroot"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- zibroot no longer in zibs-2020, but we do need id -->
                        <xsl:if test="not($zibroot)">
                            <xsl:call-template name="handleII">
                                <xsl:with-param name="in" select="hl7:id"/>
                                <xsl:with-param name="elemName">identificatie</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- weight_value -->            
                <xsl:call-template name="handlePQ">
                    <xsl:with-param name="in" select="hl7:value[@value | @unit | @nullFlavor]"/>
                    <xsl:with-param name="elemName">gewicht_waarde</xsl:with-param>
                </xsl:call-template>

                <!-- weight_date_time -->                
                <xsl:call-template name="handleTS">
                    <xsl:with-param name="in" select="hl7:effectiveTime[@value | @nullFlavor] | hl7:effectiveTime/hl7:low"/>
                    <xsl:with-param name="elemName">gewicht_datum_tijd</xsl:with-param>
                    <xsl:with-param name="datatype">datetime</xsl:with-param>
                </xsl:call-template>

            </lichaamsgewicht>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
