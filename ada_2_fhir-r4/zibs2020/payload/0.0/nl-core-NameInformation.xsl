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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir"
    xmlns:util="urn:hl7:utilities" xmlns:f="http://hl7.org/fhir"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- Can be uncommented for debug purposes. Please comment before committing! -->
   <!-- <xsl:import href="../../../fhir/2_fhir_fhir_include.xsl"/>-->
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>Converts ada naamgegevens to FHIR resource conforming to profile nl-core-NameInformation</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Unwrap naamgegevens_registratie element</xd:desc>
    </xd:doc>
    <xsl:template match="naamgegevens_registratie">
        <xsl:apply-templates select="naamgegevens" mode="zib-NameInformation"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Produces FHIR HumanName datatypes with name elements.</xd:desc>
        <xd:param name="in">Ada 'naamgegevens' element containing the zib data</xd:param>
    </xd:doc>
    <xsl:template match="naamgegevens" mode="nl-core-NameInformation" name="nl-core-NameInformation" as="element(f:name)*">
        <xsl:param name="in" select="." as="element()*"/>
        <xsl:for-each select="$in[.//@value]">
            <name>
                <xsl:if test="naamgebruik">
                    <extension url="http://hl7.org/fhir/StructureDefinition/humanname-assembly-order">
                        <valueCode>
                            <xsl:call-template name="code-to-code">
                                <xsl:with-param name="in" select="naamgebruik"/>
                            </xsl:call-template>
                        </valueCode>
                    </extension>
                </xsl:if>
                <xsl:if test="geslachtsnaam | geslachtsnaam_partner">
                    <xsl:variable name="lastName" select="normalize-space(string-join((./geslachtsnaam/voorvoegsels/@value, ./geslachtsnaam/achternaam/@value), ' '))[not(. = '')]"/>
                    <xsl:variable name="lastNamePartner" select="normalize-space(string-join((./voorvoegsels_partner/@value, ./achternaam_partner/@value), ' '))[not(. = '')]"/>
                    <xsl:variable name="nameUsage" select="naamgebruik/@code"/>
                    <family>                    
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <!-- Eigen geslachtsnaam -->
                                <xsl:when test="$nameUsage = 'NL1'">
                                    <xsl:value-of select="$lastName"/>
                                </xsl:when>
                                <!--     Geslachtsnaam partner -->
                                <xsl:when test="$nameUsage = 'NL2'">
                                    <xsl:value-of select="$lastNamePartner"/>
                                </xsl:when>
                                <!-- Geslachtsnaam partner gevolgd door eigen geslachtsnaam -->
                                <xsl:when test="$nameUsage = 'NL3'">
                                    <xsl:value-of select="string-join(($lastNamePartner, $lastName), '-')"/>
                                </xsl:when>
                                <!-- Eigen geslachtsnaam gevolgd door geslachtsnaam partner -->
                                <xsl:when test="$nameUsage = 'NL4'">
                                    <xsl:value-of select="string-join(($lastName, $lastNamePartner), '-')"/>
                                </xsl:when>
                                <!-- otherwise: we nemen aan NL4 - Eigen geslachtsnaam gevolgd door geslachtsnaam partner zodat iig geen informatie 'verdwijnt' -->
                                <xsl:otherwise>
                                    <xsl:value-of select="string-join(($lastName, $lastNamePartner), '-')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>                
                        <xsl:for-each select="geslachtsnaam/voorvoegsels">
                            <extension url="http://hl7.org/fhir/StructureDefinition/humanname-own-prefix">
                                <valueString>
                                    <xsl:call-template name="string-to-string">
                                        <xsl:with-param name="in" select="."/>
                                    </xsl:call-template>
                                </valueString>
                            </extension>
                        </xsl:for-each>
                        <xsl:for-each select=".//geslachtsnaam/achternaam">
                            <extension url="http://hl7.org/fhir/StructureDefinition/humanname-own-name">
                                <valueString>
                                    <xsl:call-template name="string-to-string">
                                        <xsl:with-param name="in" select="."/>
                                    </xsl:call-template>
                                </valueString>
                            </extension>
                        </xsl:for-each>
                        <xsl:for-each select=".//voorvoegsels_partner">
                            <extension url="http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix">
                                <valueString>
                                    <xsl:call-template name="string-to-string">
                                        <xsl:with-param name="in" select="."/>
                                    </xsl:call-template>
                                </valueString>
                            </extension>
                        </xsl:for-each>
                        <xsl:for-each select=".//achternaam_partner">
                            <extension url="http://hl7.org/fhir/StructureDefinition/humanname-partner-name">
                                <valueString>
                                    <xsl:call-template name="string-to-string">
                                        <xsl:with-param name="in" select="."/>
                                    </xsl:call-template>
                                </valueString>
                            </extension>
                        </xsl:for-each>
                    </family>
                </xsl:if>
                <xsl:if test="voornamen">
                    <given value="{voornamen/@value}">
                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                            <valueCode value="BR"/>
                        </extension>
                    </given>
                </xsl:if> 
                <xsl:if test="initialen">
                    <given value="{initialen/@value}">
                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                            <valueCode value="IN" />
                        </extension>
                    </given>
                </xsl:if>
                <xsl:if test="roepnaam">
                    <given value="{roepnaam/@value}">
                        <extension url="http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier">
                            <valueCode value="CL" />
                        </extension>
                    </given>
                </xsl:if>
                <xsl:if test="titels/@value">
                    <!-- 'titels' can be mapped both to prefix and suffix, but we cannot determine the type of 'titel' more specifically -->
                    <prefix value="{normalize-space(titels/@value)}"/>
                </xsl:if>
            </name>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>