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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:hl7="urn:hl7-org:v3" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="../../zib2017bbr/2_hl7_zib2017bbr_include.xsl"/>
    <xsl:import href="../../zib2017bbr/payload/_ada2hl7_zib2017.xsl"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="language" as="xs:string?">nl-NL</xsl:param>

    <xd:doc>
        <xd:desc>Mapping of zib nl.zorg.Contactpersoon 3.4 concept in ADA to HL7 CDA template 2.16.840.1.113883.2.4.3.11.60.121.10.30</xd:desc>
        <xd:param name="in">ADA Node to consider in the creation of the hl7 element</xd:param>
    </xd:doc>
    <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.30_20210701000000" match="contactpersoon" mode="handleContactPersRelEnt">
        <xsl:param name="in" as="element()?" select="."/>

    
        <xsl:for-each select="$in">
            
            <relatedEntity>
                <xsl:attribute name="classCode">AGNT</xsl:attribute>
                
                <!-- shared part 1, role, address, telecom -->
                <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.31_20210701000000"/>

                <xsl:if test="(naamgegevens | relatie)[.//(@value | @code | @nullFlavor)]">
                    <relatedPerson classCode="PSN" determinerCode="INSTANCE">
                        <xsl:if test="naamgegevens[.//(@value | @code | @nullFlavor)]">
                            <name>
                                <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1.100_20170602000000">
                                    <xsl:with-param name="naamgegevens" select="naamgegevens"/>
                                </xsl:call-template>
                            </name>
                        </xsl:if>
                        <xsl:for-each select="relatie[.//(@value | @code | @nullFlavor)]">
                            <sdtc:asPatientRelationship classCode="PRS">
                                <sdtc:code>
                                    <xsl:call-template name="makeCodeAttribs"/>
                                </sdtc:code>
                            </sdtc:asPatientRelationship>
                        </xsl:for-each>
                    </relatedPerson>
                </xsl:if>
                
            </relatedEntity>
            
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Mapping of some shared parts of zib nl.zorg.Contactpersoon 3.4 concept in ADA to HL7 CDA template 2.16.840.1.113883.2.4.3.11.60.121.10.31</xd:desc>
        <xd:param name="in">ADA Node to consider in the creation of the hl7 element, typically contactpersoon. Defaults to context</xd:param>
    </xd:doc>
    <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.31_20210701000000" match="contactpersoon" mode="handleContactPersSharedPart1">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:for-each select="$in">

            <xsl:for-each select="rol[@code]">
                <xsl:call-template name="makeCode"/>
            </xsl:for-each>
            <xsl:for-each select=".//adresgegevens[not(adresgegevens)][.//(@value | @code | @nullFlavor)]">
                <addr>
                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1.101_20180611000000"/>
                </addr>
            </xsl:for-each>

            <!--Telecom gegevens-->
            <xsl:for-each select=".//contactgegevens[not(contactgegevens)][.//(@value | @code | @nullFlavor)]">
                <xsl:call-template name="_CdaTelecom"/>
            </xsl:for-each>

        </xsl:for-each>

    </xsl:template>


</xsl:stylesheet>
