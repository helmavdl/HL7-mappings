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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:util="urn:hl7:utilities" exclude-result-prefixes="#all" version="2.0">
    <xsl:variable name="humannameAssemblyOrder" select="'http://hl7.org/fhir/StructureDefinition/humanname-assembly-order'"/>

    <xd:doc>
        <xd:desc>Template to convert f:name to ADA naamgegevens</xd:desc>
    </xd:doc>
    <xsl:template match="f:name" mode="nl-core-NameInformation">
        <xsl:variable name="nameUsage" select="f:extension[@url = $humannameAssemblyOrder]/f:valueCode/@value"/>
        <naamgegevens>
            <!-- ongestructureerde_naam -->
            <xsl:apply-templates select="f:text" mode="#current"/>
            <!-- voornamen -->
            <!-- initialen -->
            <!-- roepnaam -->
            <xsl:apply-templates select="f:given" mode="#current"/>
            <!-- naamgebruik -->
            <xsl:apply-templates select="f:extension[@url = $humannameAssemblyOrder]" mode="#current">
                <xsl:with-param name="nameUsage" select="$nameUsage"/>
            </xsl:apply-templates>
            <!-- geslachtsnaam -->
            <!-- geslachtsnaam_partner -->
            <xsl:apply-templates select="f:family" mode="#current">
                <xsl:with-param name="nameUsage" select="$nameUsage"/>
            </xsl:apply-templates>
        </naamgegevens>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:text to ADA ongestructureerde_naam</xd:desc>
    </xd:doc>
    <xsl:template match="f:text" mode="nl-core-NameInformation">
        <ongestructureerde_naam value="{@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:given to ADA voornamen, initialen or roepnaam based on ISO21090-EN qualifier extension.</xd:desc>
    </xd:doc>
    <xsl:template match="f:given" mode="nl-core-NameInformation">
        <xsl:variable name="iso21090-EN-qualifier" select="f:extension[@url = 'http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier']/f:valueCode/@value"/>
        <xsl:variable name="elementName">
            <xsl:choose>
                <xsl:when test="$iso21090-EN-qualifier = 'BR'">voornamen</xsl:when>
                <xsl:when test="$iso21090-EN-qualifier = 'IN'">initialen</xsl:when>
                <xsl:when test="$iso21090-EN-qualifier = 'CL'">roepnaam</xsl:when>
                <!-- MP-1410 default to roepnaam -->
                <xsl:otherwise>
                    <xsl:call-template name="util:logMessage">
                        <xsl:with-param name="msg">Er mist een extensie met URL 'http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier'. Onbekend welk type (officiële voornamen, initialen of roepnaam) 'given' name dit is: "<xsl:value-of select="@value"/>". Aanname is roepnaam.</xsl:with-param>
                        <xsl:with-param name="level" select="$logERROR"/>
                        <xsl:with-param name="terminate" select="false()"/>
                    </xsl:call-template>
                    <xsl:value-of select="'roepnaam'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
            <xsl:attribute name="value" select="@value"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert humanname-assembly-order f:extension to ADA naamgebruik</xd:desc>
        <xd:param name="nameUsage"/>
    </xd:doc>
    <xsl:template match="f:extension[@url = $humannameAssemblyOrder]" mode="nl-core-NameInformation">
        <xsl:param name="nameUsage" required="yes"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="$nameUsage = ('NL1', 'NL2', 'NL3', 'NL4')">
                    <xsl:value-of select="$nameUsage"/>
                </xsl:when>
                <xsl:otherwise>NL4</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <naamgebruik>
            <xsl:call-template name="code-to-code">
                <xsl:with-param name="value" select="$value"/>
                <xsl:with-param name="codeMap" as="element()*">
                    <map inValue="NL1" code="NL1" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Eigen geslachtsnaam"/>
                    <map inValue="NL2" code="NL2" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Geslachtsnaam partner"/>
                    <map inValue="NL3" code="NL3" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Geslachtsnaam partner gevolgd door eigen geslachtsnaam"/>
                    <map inValue="NL4" code="NL4" codeSystem="2.16.840.1.113883.2.4.3.11.60.101.5.4" displayName="Eigen geslachtsnaam gevolgd door geslachtsnaam partner"/>
                </xsl:with-param>
            </xsl:call-template>
        </naamgebruik>
    </xsl:template>

    <xsl:variable name="humanname-own-prefix" select="'http://hl7.org/fhir/StructureDefinition/humanname-own-prefix'"/>
    <xsl:variable name="humanname-own-name" select="'http://hl7.org/fhir/StructureDefinition/humanname-own-name'"/>
    <xsl:variable name="humanname-partner-prefix" select="'http://hl7.org/fhir/StructureDefinition/humanname-partner-prefix'"/>
    <xsl:variable name="humanname-partner-name" select="'http://hl7.org/fhir/StructureDefinition/humanname-partner-name'"/>

    <xd:doc>
        <xd:desc>Template to convert f:family to ADA geslachtsnaam, with children based on f:extensions present.</xd:desc>
    </xd:doc>
    <xsl:template match="f:family" mode="nl-core-NameInformation">
        <xsl:variable name="voorvoegsels" select="f:extension[@url = $humanname-own-prefix]"/>
        <xsl:variable name="achternaam" select="f:extension[@url = $humanname-own-name]"/>
        <xsl:variable name="voorvoegsels_partner" select="f:extension[@url = $humanname-partner-prefix]"/>
        <xsl:variable name="achternaam_partner" select="f:extension[@url = $humanname-partner-name]"/>
        <xsl:choose>
            <xsl:when test="f:extension">
                <xsl:if test="$voorvoegsels or $achternaam">
                    <geslachtsnaam>
                        <xsl:apply-templates select="$voorvoegsels" mode="#current"/>
                        <xsl:apply-templates select="$achternaam" mode="#current"/>
                    </geslachtsnaam>
                </xsl:if>
                <xsl:if test="$voorvoegsels_partner or $achternaam_partner">
                    <geslachtsnaam_partner>
                        <xsl:apply-templates select="$voorvoegsels_partner" mode="#current"/>
                        <xsl:apply-templates select="$achternaam_partner" mode="#current"/>
                    </geslachtsnaam_partner>
                </xsl:if>
            </xsl:when>
            <xsl:when test="@value">
                <geslachtsnaam>
                    <achternaam value="{@value}"/>
                </geslachtsnaam>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:extension humanname-own-prefix to ADA voorvoegsels.</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = $humanname-own-prefix]" mode="nl-core-NameInformation">
        <voorvoegsels value="{f:valueString/@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:extension humanname-own-name to ADA achternaam.</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = $humanname-own-name]" mode="nl-core-NameInformation">
        <achternaam value="{f:valueString/@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:extension humanname-partner-prefix to ADA voorvoegsels_partner.</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = $humanname-partner-prefix]" mode="nl-core-NameInformation">
        <voorvoegsels_partner value="{f:valueString/@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:extension humanname-partner-name to ADA achternaam_partner.</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = $humanname-partner-name]" mode="nl-core-NameInformation">
        <achternaam_partner value="{f:valueString/@value}"/>
    </xsl:template>

</xsl:stylesheet>
