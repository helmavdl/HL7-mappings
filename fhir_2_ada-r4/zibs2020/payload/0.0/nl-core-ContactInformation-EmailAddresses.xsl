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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" exclude-result-prefixes="#all" version="2.0">

    <!--Uncomment imports for standalone use and testing.-->
    <!--<xsl:import href="../../fhir/fhir_2_ada_fhir_include.xsl"/>-->

    <xsl:variable name="code-specification" select="'http://nictiz.nl/fhir/StructureDefinition/code-specification'"/>

    <xd:doc>
        <xd:desc>Template to convert f:emailAddresses (ContactPoint datatype) to ADA email_adressen</xd:desc>
    </xd:doc>
    <xsl:template match="f:emailAddresses" mode="nl-core-ContactInformation-EmailAddresses">
        <email_adressen>
            <email_adres value="{f:value/@value}"/>
            <xsl:for-each select="f:use[@value]">
                <nummer_soort>
                    <xsl:call-template name="code-to-code">
                        <xsl:with-param name="value" select="@value"/>
                        <xsl:with-param name="codeMap" as="element()*">
                            <map inValue="home" code="HP" codeSystem="{$oidHL7AddressUse}" displayName="Privé e-mailadres"/>
                            <map inValue="work" code="WP" codeSystem="{$oidHL7AddressUse}" displayName="Zakelijk e-mailadres"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </nummer_soort>
            </xsl:for-each>
        </email_adressen>
    </xsl:template>

</xsl:stylesheet>