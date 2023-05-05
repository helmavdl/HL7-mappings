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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:output name="ada-xml" method="xml" indent="yes" omit-xml-declaration="yes" xmlns=""/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="ada-input" select="collection('../../ada_instance/?select=*.xml')"/>
    <xsl:param name="adaReleaseFile" select="document('zib2017-nl-ada-release.xml')"/>
    
    <!-- output directory for full ada instances -->
    <xsl:param name="outputDir" as="xs:string?">../../ada_processed</xsl:param>
    
    <xd:doc>
        <xd:desc>Template to start conversion. Input are the ada instances of transaction 'beschikbaarstellen BgZ'. Outputs ada instance bundle in the given output directory </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:for-each-group select="$ada-input//*[ends-with(local-name(), '_registration')]/*" group-by="./hcimroot/subject/patient/patient/@value">
            <xsl:variable name="patientIdentifier" select="current-grouping-key()"/>
            <xsl:variable name="patientName">
                <xsl:choose>
                    <xsl:when test="$patientIdentifier = 999901382">
                        <xsl:value-of select="'patA'"/>
                    </xsl:when>
                    <xsl:when test="$patientIdentifier = 999901394">
                        <xsl:value-of select="'patB'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'patX'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="resolvedPatient">
                <xsl:apply-templates select="($ada-input//*[ends-with(local-name(), '_registration')]/patient[patient_identification_number[@value = $patientIdentifier][@root = '2.16.840.1.113883.2.4.6.3']])[1]" mode="copy-for-resolve"/>
            </xsl:variable>
            <xsl:for-each-group select="current-group()" group-by="local-name()">
                <!-- We now have groups of zibs per patient, which we want to resolve and put in an 'ada bundle' (which is no official thing) -->
                <xsl:variable name="resolved-ada-input" as="node()*">
                    <xsl:apply-templates select="current-group()" mode="copy-for-resolve">
                        <xsl:with-param name="resolvedPatient" select="$resolvedPatient" tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:variable>
                
                <xsl:result-document href="{$outputDir}/{concat('medmij-bgz-test-', $patientName, '-', current-grouping-key(), '.xml')}" format="ada-xml">
                    <bundle>
                        <xsl:copy-of select="$resolved-ada-input"/>
                    </bundle>
                </xsl:result-document>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="patient[@value and @root = '2.16.840.1.113883.2.4.6.3'][not(*)]" mode="copy-for-resolve" priority="2">
        <xsl:param name="resolvedPatient" tunnel="yes"/>
        <xsl:copy-of select="$resolvedPatient"/>
    </xsl:template>
    
    <!-- Remove hcimroot from resolved patient -->
    <xsl:template match="*[ends-with(local-name(), '_registration')]/patient/hcimroot" mode="copy-for-resolve" priority="2"/>
    
    <!-- Matching on @value and @root, and excluding local-name containing 'identification' but should be on @datatype = 'reference' -->
    <xsl:template match="*[starts-with(lower-case(@value), 'mm-bgz-')]" mode="copy-for-resolve" priority="1">
        <xsl:variable name="transactionId" select="ancestor::*[ends-with(local-name(), '_registration')]/@transactionRef"/>
        <xsl:variable name="valueDomain" select="nf:get-concept-value-domain(., 'type', $transactionId)"/>
        <xsl:choose>
            <xsl:when test="$valueDomain = 'reference'">
                <xsl:variable name="resolved" select="($ada-input//*[@title = current()/@value]/*)[1]"/>
                <xsl:if test="count($resolved) ne 1">
                    <xsl:message>Could not resolve reference to <xsl:value-of select="current()/local-name()"/> '<xsl:value-of select="current()/@value"/>' in <xsl:value-of select="ancestor::*[ends-with(local-name(), '_registration')]/@title"/></xsl:message>
                </xsl:if>
                <xsl:element name="{$resolved/local-name()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="$resolved/@*"/>
                    <xsl:apply-templates select="$resolved/*" mode="#current"/>
                </xsl:element>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Default copy template</xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()" mode="copy-for-resolve">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Finds valuedomain @type or @originaltype of a concept in ada release file.</xd:desc>
        <xd:param name="currentConcept">The current ada concept, must have @conceptId to find the corresponding concept in ada release file</xd:param>
        <xd:param name="attributeToReturn">The attribute to return, currently supported: type and originaltype. Defaults to type.</xd:param>
    </xd:doc>
    <xsl:function name="nf:get-concept-value-domain" as="xs:string?">
        <xsl:param name="currentConcept" as="element()?"/>
        <xsl:param name="attributeToReturn" as="xs:string?"/>
        <xsl:param name="transactionId" as="xs:string?"/>
        <xsl:if test="$currentConcept">
            <xsl:variable name="adaReleaseConcept" select="$adaReleaseFile/ada/applications/application/views/view[@transactionId eq $transactionId]/dataset[1]//concept[@id = $currentConcept/@conceptId]"/>
            <xsl:choose>
                <xsl:when test="upper-case(normalize-space($attributeToReturn)) = 'ORIGINALTYPE'">
                    <xsl:value-of select="$adaReleaseConcept/valueDomain/@originaltype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <!-- @type reference is no longer used in ada release files, so let's add it here, so we know when to resolve adaref -->
                        <xsl:when test="$adaReleaseConcept[valueDomain/@type = 'string' and contains]">reference</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$adaReleaseConcept/valueDomain/@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>
