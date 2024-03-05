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

    <xsl:variable name="code-specification" select="'http://nictiz.nl/fhir/StructureDefinition/code-specification'"/>
    <xsl:variable name="ext-Comment" select="'http://nictiz.nl/fhir/StructureDefinition/ext-Comment'"/>

    <xd:doc>
        <xd:desc>Template to convert f:telephoneNumbers (ContactPoint datatype) to ADA telefoonnummers</xd:desc>
    </xd:doc>
    <xsl:template match="f:telecom[f:system/@value=('phone', 'fax', 'pager', 'sms')]" mode="nl-core-ContactInformation">
        
        <xsl:choose>
            <xsl:when test="preceding-sibling::f:telecom[f:system/@value=('phone', 'fax', 'pager', 'sms')]"/>
            <xsl:otherwise>
                <telefoonnummers>
                    <xsl:for-each select="self::* | following-sibling::f:telecom[f:system/@value = ('phone', 'fax', 'pager', 'sms')]">
                        <telefoonnummer value="{f:value/@value}"/>
                        <xsl:if test="f:system/f:extension[@url = $code-specification]">
                            <xsl:call-template name="CodeableConcept-to-code">
                                <xsl:with-param name="in" select="f:system/f:extension[@url = $code-specification]/f:valueCodeableConcept"/>
                                <xsl:with-param name="adaElementName">telecom_type</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:for-each select="f:use[@value]">
                            <nummer_soort>
                                <xsl:call-template name="code-to-code">
                                    <xsl:with-param name="value" select="@value"/>
                                    <xsl:with-param name="codeMap" as="element()*">
                                        <map inValue="home" code="HP" codeSystem="{$oidHL7AddressUse}" displayName="Telefoonnummer thuis"/>
                                        <map inValue="temp" code="TMP" codeSystem="{$oidHL7AddressUse}" displayName="Tijdelijk telefoonnummer"/>
                                        <map inValue="work" code="WP" codeSystem="{$oidHL7AddressUse}" displayName="Zakelijk telefoonnummer"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </nummer_soort>
                        </xsl:for-each>
                        <xsl:for-each select="f:extension[@url = $ext-Comment]/f:valueString/@value">
                            <toelichting value="{.}"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </telefoonnummers>
                
            </xsl:otherwise>
        </xsl:choose>
       </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:emailAddresses (ContactPoint datatype) to ADA email_adressen</xd:desc>
    </xd:doc>
    <xsl:template match="f:telecom[f:system/@value='email']" mode="nl-core-ContactInformation">
        <email_adressen>
            <email_adres value="{f:value/@value}"/>
            <xsl:for-each select="f:use[@value]">
                <email_soort>
                    <xsl:call-template name="code-to-code">
                        <xsl:with-param name="value" select="@value"/>
                        <xsl:with-param name="codeMap" as="element()*">
                            <map inValue="home" code="HP" codeSystem="{$oidHL7AddressUse}" displayName="Privé e-mailadres"/>
                            <map inValue="work" code="WP" codeSystem="{$oidHL7AddressUse}" displayName="Zakelijk e-mailadres"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </email_soort>
            </xsl:for-each>
        </email_adressen>
    </xsl:template>
    

</xsl:stylesheet>
