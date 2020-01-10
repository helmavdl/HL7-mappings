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
<xsl:stylesheet xmlns:nf="http://www.nictiz.nl/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:pharm="urn:ihe:pharm:medication" xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uuid="http://www.uuid.org" exclude-result-prefixes="#all" version="2.0">
    <xd:doc>
        <xd:desc>Conversie van <xd:a href="https://decor.nictiz.nl/ketenzorg/kz-html-20190110T164948/tmp-2.16.840.1.113883.2.4.3.11.60.66.10.8-2018-04-18T000000.html">Organizer AlgemeneBepalingen</xd:a> id: 2.16.840.1.113883.2.4.3.11.60.66.10.8 versie 2018-04-18T00:00:00 naar ADA formaat </xd:desc>
        <xd:desc>Documentatie voor deze mapping staat op de wikipagina <xd:a href="https://informatiestandaarden.nictiz.nl/wiki/Mappings/KZ302BeschikbaarstellenAlgemeneBepalingenCDA_2_ADA">https://informatiestandaarden.nictiz.nl/wiki/Mappings/KZ302BeschikbaarstellenAlgemeneBepalingenCDA_2_ADA</xd:a></xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:include href="../../../hl7_2_ada_ketenzorg_include.xsl"/>
    
    <xd:doc>
        <xd:desc> if this xslt is used stand alone the template below could be used. </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:call-template name="doGeneratedComment"/>
        <xsl:for-each select="//hl7:organizer[hl7:templateId/@root = $oidOrganizerAlgemeneBepalingen]">
            <adaxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../ada_schemas/ada_general_measurements_response.xsd">
                <meta status="new" created-by="generated" last-update-by="generated">
                    <xsl:attribute name="creation-date" select="current-dateTime()"/>
                    <xsl:attribute name="last-update-date" select="current-dateTime()"/>
                </meta>
                <data>
                    <xsl:call-template name="BeschikbaarstellenAlgemeneBepalingen-ADA">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="author" select="(ancestor::hl7:ControlActProcess/hl7:authorOrPerformer//*[hl7:id])[1]"/>
                    </xsl:call-template>
                </data>
            </adaxml>
        </xsl:for-each>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="in"/>
        <xd:param name="author"/>
    </xd:doc>
    <xsl:template name="BeschikbaarstellenAlgemeneBepalingen-ADA">
        <xsl:param name="in" as="element()"/>
        <xsl:param name="author" as="element()?"/>
        
        <xsl:variable name="patient" select="$in/hl7:recordTarget/hl7:patientRole"/>
        <general_measurements_response app="ketenzorg3.0" shortName="general_measurements_response" formName="general_measurements_response" transactionRef="2.16.840.1.113883.2.4.3.11.60.66.4.517" transactionEffectiveDate="2018-04-13T00:00:00" versionDate="" prefix="kz-" language="en-US" title="Generated Through Conversion" id="{uuid:get-uuid($in)}">
            <!-- Bundle stuff -->
            <xsl:call-template name="template_organizer_2_bundle">
                <xsl:with-param name="author" select="(hl7:participant[@typeCode = 'RESP']/hl7:participantRole, hl7:author/hl7:assignedAuthor, $author)[1]"/>
                <xsl:with-param name="custodian" select="(hl7:participant[@typeCode = 'CST']/hl7:participantRole[hl7:scopingEntity], $author)[1]"/>
                <xsl:with-param name="patient" select="$patient"/>
            </xsl:call-template>
            
            <xsl:variable name="organizerComponents" select="$in//*[hl7:templateId/@root = $oidAlgemeneBepaling]"/>
            <xsl:for-each select="$organizerComponents">
                <general_measurement>
                    <!-- Do encounter association -->
                    <xsl:for-each select="hl7:entryRelationship[@typeCode = 'REFR']/hl7:encounter">
                        <xsl:call-template name="handleII">
                            <xsl:with-param name="in" select="hl7:id"/>
                            <xsl:with-param name="elemName">encounter</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                    <!-- Do episode association -->
                    <xsl:for-each select="hl7:entryRelationship[@typeCode = 'REFR']/hl7:act[hl7:code[@code = 'CONC'][@codeSystem = $oidHL7ActClass]]">
                        <xsl:call-template name="handleII">
                            <xsl:with-param name="in" select="hl7:id"/>
                            <xsl:with-param name="elemName">episode</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                    <measurement_result>
                        <xsl:if test="hl7:id | hl7:author/hl7:assignedAuthor | hl7:participant[@typeCode = 'RESP']/hl7:participantRole">
                            <hcimroot>
                                <xsl:if test="hl7:id">
                                    <xsl:call-template name="handleII">
                                        <xsl:with-param name="in" select="hl7:id"/>
                                        <xsl:with-param name="elemName">identification_number</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:for-each select="hl7:author/hl7:assignedAuthor | hl7:participant[@typeCode = 'RESP']/hl7:participantRole">
                                    <author>
                                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.66.10.9025_20140403162802">
                                            <xsl:with-param name="in" select="."/>
                                            <xsl:with-param name="language">en-US</xsl:with-param>
                                            <xsl:with-param name="typeCode" select="../@typeCode"/>
                                        </xsl:call-template>
                                    </author>
                                </xsl:for-each>
                                <!-- Date and if relevant the time the event to which the information relates took place . -->
                                <!--<xsl:for-each select="(hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low)[1]">
                                    <xsl:call-template name="handleTS">
                                        <xsl:with-param name="in" select="."/>
                                        <xsl:with-param name="elemName">date_time</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:for-each>-->
                            </hcimroot>
                        </xsl:if>
                        
                        <xsl:call-template name="handleCV">
                            <xsl:with-param name="in" select="hl7:code"/>
                            <xsl:with-param name="elemName">measurement_name</xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:call-template name="handleANY">
                            <xsl:with-param name="in" select="hl7:value"/>
                            <xsl:with-param name="elemName">result_value</xsl:with-param>
                            <!-- mapping into itself relevant to get the @value attributes which is required in the schema -->
                            <xsl:with-param name="codeMap" as="element(map)*">
                                <map inCode="282291009" inCodeSystem="{$oidSNOMEDCT}" value="1" code="282291009" codeSystem="{$oidSNOMEDCT}" displayName="Diagnosis"/>
                                <!-- other values not supported in Ketenzorg in input format -->
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:for-each select="(hl7:effectiveTime[@value] | hl7:effectiveTime/hl7:low)[1]">
                            <xsl:call-template name="handleTS">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="elemName">result_date_time</xsl:with-param>
                            </xsl:call-template>
                        </xsl:for-each>
                        
                        <xsl:call-template name="handlePQ">
                            <xsl:with-param name="in" select="hl7:referenceRange/hl7:observationRange/hl7:value/hl7:low"/>
                            <xsl:with-param name="elemName">reference_range_lower_limit</xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:call-template name="handlePQ">
                            <xsl:with-param name="in" select="hl7:referenceRange/hl7:observationRange/hl7:value/hl7:high"/>
                            <xsl:with-param name="elemName">reference_range_upper_limit</xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:call-template name="handleCV">
                            <xsl:with-param name="in" select="hl7:interpretationCode"/>
                            <xsl:with-param name="elemName">result_flags</xsl:with-param>
                        </xsl:call-template>
                    </measurement_result>
                </general_measurement>
            </xsl:for-each>
        </general_measurements_response>
        <xsl:comment>Input HL7 xml below</xsl:comment>
        <xsl:call-template name="copyElementInComment">
            <xsl:with-param name="in" select="./*"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
