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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    
    <!--<xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="advanceDirectiveReference" match="wilsverklaring[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)] | advance_directive[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doAdvanceDirectiveReference-2.1">
        <xsl:variable name="theIdentifier" select="identificatie_nummer[@value] | identification_number[@value]"/>
        <xsl:variable name="theGroupKey" select="nf:getGroupingKeyDefault(.)"/>
        <xsl:variable name="theGroupElement" select="$advanceDirectives[group-key = $theGroupKey]" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$theGroupElement">
                <xsl:variable name="fullUrl" select="nf:getFullUrlOrId(($theGroupElement/f:entry)[1])"/>
                <reference value="{$fullUrl}"/>
            </xsl:when>
            <xsl:when test="$theIdentifier">
                <identifier>
                    <xsl:call-template name="id-to-Identifier">
                        <xsl:with-param name="in" select="($theIdentifier[not(@root = $mask-ids-var)], $theIdentifier)[1]"/>
                    </xsl:call-template>
                </identifier>
            </xsl:when>
        </xsl:choose>
        
        <xsl:if test="string-length($theGroupElement/reference-display) gt 0">
            <display value="{$theGroupElement/reference-display}"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Produces a FHIR entry element with a Consent resource for AdvanceDirective</xd:desc>
        <xd:param name="uuid">If true generate uuid from scratch. Defaults to false(). Generating a uuid from scratch limits reproduction of the same output as the uuids will be different every time.</xd:param>
        <xd:param name="adaPatient">Optional, but should be there. Patient this resource is for.</xd:param>
        <xd:param name="dateT">Optional. dateT may be given for relative dates, only applicable for test instances</xd:param>
        <xd:param name="entryFullUrl">Optional. Value for the entry.fullUrl</xd:param>
        <xd:param name="fhirResourceId">Optional. Value for the entry.resource.Consent.id</xd:param>
        <xd:param name="searchMode">Optional. Value for entry.search.mode. Default: include</xd:param>
    </xd:doc>
    <xsl:template name="advanceDirectiveEntry" match="wilsverklaring[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)] | advance_directive[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" mode="doAdvanceDirectiveEntry-2.1" as="element(f:entry)">
        <xsl:param name="uuid" select="false()" as="xs:boolean"/>
        <xsl:param name="adaPatient" select="(ancestor::*/patient[*//@value] | ancestor::*/bundle/subject/patient[*//@value])[1]" as="element()"/>
        <xsl:param name="dateT" as="xs:date?"/>
        <xsl:param name="entryFullUrl" select="nf:get-fhir-uuid(.)"/>
        <xsl:param name="fhirResourceId">
            <xsl:if test="$referById">
                <xsl:choose>
                    <xsl:when test="not($uuid) and string-length(nf:removeSpecialCharacters((zibroot/identificatienummer | hcimroot/identification_number)/@value)) gt 0">
                        <xsl:value-of select="nf:removeSpecialCharacters(string-join((zibroot/identificatienummer | hcimroot/identification_number)/@value, ''))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="nf:removeSpecialCharacters(replace($entryFullUrl, 'urn:[^i]*id:', ''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:param>
        <xsl:param name="searchMode">include</xsl:param>
        
        <entry>
            <fullUrl value="{$entryFullUrl}"/>
            <resource>
                <xsl:call-template name="zib-AdvanceDirective-2.1">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="logicalId" select="$fhirResourceId"/>
                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                    <xsl:with-param name="dateT" select="$dateT"/>
                </xsl:call-template>
            </resource>
            <xsl:if test="string-length($searchMode) gt 0">
                <search>
                    <mode value="{$searchMode}"/>
                </search>
            </xsl:if>
        </entry>
    </xsl:template>-->
    
    <xd:doc>
        <xd:desc>Mapping of HCIM AdvanceDirective concept in ADA to FHIR resource <xd:a href="https://simplifier.net/resolve/?target=simplifier&amp;canonical=http://nictiz.nl/fhir/StructureDefinition/zib-AdvanceDirective">zib-AdvanceDirective</xd:a>.</xd:desc>
        <xd:param name="logicalId">Optional FHIR logical id for the record.</xd:param>
        <xd:param name="in">Node to consider in the creation of the Consent resource for AdvanceDirective.</xd:param>
        <xd:param name="adaPatient">Required. ADA patient concept to build a reference to from this resource</xd:param>
        <xd:param name="dateT">Optional. dateT may be given for relative dates, only applicable for test instances</xd:param>
    </xd:doc>
    <xsl:template name="zib-AdvanceDirective-2.1" match="wilsverklaring[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)] | advance_directive[not(@datatype = 'reference')][.//(@value | @code | @nullFlavor)]" as="element(f:Consent)" mode="doZibAdvanceDirective-2.1">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        <xsl:param name="adaPatient" select="(ancestor::*/patient[*//@value] | ancestor::*/bundle/subject/patient[*//@value])[1]" as="element()"/>
        <xsl:param name="adaProblem" select="disorder/problem" as="element()*"/>
        <xsl:param name="adaRelatedPerson" as="element()"/>
        <xsl:param name="dateT" as="xs:date?"/>
        
        <xsl:for-each select="$in">
            <xsl:variable name="resource">
                <xsl:variable name="profileValue">http://nictiz.nl/fhir/StructureDefinition/zib-AdvanceDirective</xsl:variable>
                <Consent>
                    <xsl:if test="string-length($logicalId) gt 0">
                        <id value="{nf:make-fhir-logicalid(tokenize($profileValue, './')[last()], $logicalId)}"/>
                    </xsl:if>
                    
                    <meta>
                        <profile value="{$profileValue}"/>
                    </meta>
                    
                    <!--<xsl:for-each select="$adaProblem">
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/zib-AdvanceDirective-Disorder">
                            <valueReference>
                                <xsl:apply-templates select="$adaProblem" mode="doProblemReference-2.1"/>
                            </valueReference>
                        </extension>
                    </xsl:for-each>-->
                    
                    <xsl:for-each select="(toelichting | comment)[@value]">
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/Comment">
                            <valueString>
                                <xsl:call-template name="string-to-string">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </valueString>
                        </extension>
                    </xsl:for-each>
                    
                    <status value="active" />
                    
                    <category>
                        <coding>
                            <system value="http://snomed.info/sct"/>
                            <code value="11341000146107"/>
                            <display value="levenstestament en wilsverklaring in dossier"/>
                        </coding>
                    </category>
                    
                    <!-- category typeOfLivingWill is required in the FHIR profile, so always output category, data-absent-reason if no actual value -->
                    <category>
                        <xsl:choose>
                            <xsl:when test="(wilsverklaring_type | living_will_type)[@code]">
                                <xsl:variable name="nullFlavorsInValueset" select="('OTH')"/>
                                <xsl:call-template name="code-to-CodeableConcept">
                                    <xsl:with-param name="in" select="wilsverklaring_type | living_will_type"/>
                                    <xsl:with-param name="treatNullFlavorAsCoding" select="(wilsverklaring_type | living_will_type)/@code = $nullFlavorsInValueset and (wilsverklaring_type | living_will_type)/@codeSystem = $oidHL7NullFlavor"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <extension url="{$urlExtHL7DataAbsentReason}">
                                    <valueCode value="unknown"/>
                                </extension>
                            </xsl:otherwise>
                        </xsl:choose>
                    </category>
                    
                    <!-- Patient reference -->
                    <patient>
                        <xsl:apply-templates select="$adaPatient" mode="doPatientReference-2.1"/>
                    </patient>
                    
                    <!-- dateTime is required in the FHIR profile, so always output dateTime, data-absent-reason if no actual value -->
                    <dateTime>
                        <xsl:choose>
                            <xsl:when test="(wilsverklaring_datum | living_will_date)[@value]">
                                <xsl:attribute name="value">
                                    <xsl:call-template name="format2FHIRDate">
                                        <xsl:with-param name="dateTime" select="xs:string((wilsverklaring_datum | living_will_date)/@value)"/>
                                        <xsl:with-param name="dateT" select="$dateT"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <extension url="{$urlExtHL7DataAbsentReason}">
                                    <valueCode value="unknown"/>
                                </extension>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dateTime>
                    
                    <!--<xsl:for-each select="vertegenwoordiger | representative">
                        <consentingParty>
                            <xsl:apply-templates select="$adaRelatedPerson" mode="doRelatedPersonReference-2.0"/>
                        </consentingParty>
                    </xsl:for-each>-->
                    
                    <xsl:for-each select="(wilsverklaring_document | living_will_document)[@value]">
                        <sourceAttachment>
                            <contentType value="application/pdf"/>
                            <data>
                                <xsl:attribute name="value">
                                    <xsl:value-of select="@value"/>
                                </xsl:attribute>
                            </data>
                        </sourceAttachment>
                    </xsl:for-each>
                    
                    <policy>
                        <uri value="http://wetten.overheid.nl/"/>
                    </policy>
                    
                </Consent>
            </xsl:variable>
            
            <!-- Add resource.text -->
            <xsl:apply-templates select="$resource" mode="addNarrative"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>