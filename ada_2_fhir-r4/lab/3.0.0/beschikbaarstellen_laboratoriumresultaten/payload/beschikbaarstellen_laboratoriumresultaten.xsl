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
<xsl:stylesheet exclude-result-prefixes="#all"
    xmlns="http://hl7.org/fhir"
    xmlns:util="urn:hl7:utilities" 
    xmlns:f="http://hl7.org/fhir" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:nf="http://www.nictiz.nl/functions"
    xmlns:nm="http://www.nictiz.nl/mappings"
    xmlns:uuid="http://www.uuid.org"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:import href="../../../../zibs2020/payload/zib_latest_package.xsl"/>
    
    <xsl:param name="referencingStrategy" select="'logicalId'" as="xs:string"/>
    
    <!-- Generate metadata for all ADA instances -->
    <xsl:param name="fhirMetadata" as="element()*">
        <xsl:call-template name="buildFhirMetadata">
            <!-- ADA instances for this project start with $zib2020Oid and end in .1, or in 9.*.* in the case of the medication related zibs -->
            <xsl:with-param name="in" select="collection('../ada_instance/')//(vaccinatie | bundel/patient | bundel/zorgaanbieder | vaccinatie/farmaceutisch_product)"/>
        </xsl:call-template>
    </xsl:param>
    
    <xsl:template match="beschikbaarstellen_laboratoriumresultaten">
        <xsl:variable name="vaccinations" as="element()*">
            <xsl:for-each select="vaccinatie">
                <xsl:call-template name="nl-core-Vaccination-event">
                    <xsl:with-param name="patient" select="../bundel/patient"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="patient" as="element()?">
            <xsl:for-each select="bundel/patient">
                <xsl:call-template name="nl-core-Patient"/>
            </xsl:for-each>
        </xsl:variable>
        
        <Bundle>
            <xsl:for-each select="$vaccinations">
                <entry>
                    <xsl:call-template name="_insertFullUrlById"/>
                    <resource>
                        <xsl:copy-of select="."/>
                    </resource>
                    <search>
                        <mode value="match"/>
                    </search>
                </entry>
            </xsl:for-each>
            <xsl:for-each select="$patient">
                <xsl:call-template name="_insertFullUrlById"/>
                <resource>
                    <xsl:copy-of select="."/>
                </resource>
                <search>
                    <mode value="include"/>
                </search>
            </xsl:for-each>
        </Bundle>        
    </xsl:template>
    
    <xsl:template name="_insertFullUrlById">
        <xsl:param name="in" select="."/>   
        <xsl:param name="fhirId" select="$in/f:id/@value"/>
        
        <xsl:if test="count($fhirMetadata[nm:logical-id = $fhirId]) = 0 ">
            <xsl:message terminate="yes">_insertFullUrlById: Nothing found.</xsl:message>
        </xsl:if>
        
        <xsl:variable name="fullUrl">
            <xsl:value-of select="$fhirMetadata[nm:logical-id = $fhirId]/nm:full-url"/>
        </xsl:variable>
        
        <xsl:if test="string-length($fullUrl) gt 0">
            <fullUrl value="{$fullUrl}"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>