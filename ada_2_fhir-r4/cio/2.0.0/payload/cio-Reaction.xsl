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
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="cio-Reaction" as="element(f:AllergyIntolerance)?">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="subject" select="../../patient" as="element()?"/>
        
        <xsl:for-each select="$in">    
            <AllergyIntolerance>
                <xsl:variable name="registrationData" select="../../bouwstenen/registratie_gegevens[@id = current()/registratie_gegevens/@value]"/>
                <xsl:variable name="identificationNumber" select="$registrationData/identificatienummer"/>
                <xsl:variable name="author" select="$registrationData/auteur/*"/>
                <xsl:variable name="registrationDateTime" select="$registrationData/registratie_datum_tijd"/>
                
                <xsl:variable name="relationHypersensitivityRegistrationData" select="../../bouwstenen/registratie_gegevens[identificatienummer/@value = current()/relatie_overgevoeligheid/identificatie/@value]"/>
                <xsl:variable name="relationHypersensitivity" select="../../geneesmiddelovergevoeligheid/overgevoeligheid[registratie_gegevens/@value = $relationHypersensitivityRegistrationData/@id]"/>
                
                <xsl:variable name="relationReactionRegistrationData" select="../../bouwstenen/registratie_gegevens[identificatienummer/@value = current()/relatie_reactie/identificatie/@value]"/>
                <xsl:variable name="relationReaction" select="../../geneesmiddelovergevoeligheid/reactie[registratie_gegevens/@value = $relationReactionRegistrationData/@id]"/>
                
                <xsl:call-template name="insertLogicalId">
                    <xsl:with-param name="profile" select="'cio-Reaction'"/>
                </xsl:call-template>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/cio-Reaction"/>
                </meta>
                
                <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-AllergyIntolerance-Type">
                    <valueCodeableConcept>
                        <coding>
                            <system value="{$oidMap[@oid=$oidSNOMEDCT]/@uri}"/>
                            <code value="281647001"/>
                            <display value="ongewenste reactie"/>
                        </coding>
                    </valueCodeableConcept>
                </extension>
                
                <xsl:for-each select="diagnostisch_inzicht_datum[@value]">
                    <extension url="http://hl7.org/fhir/StructureDefinition/allergyintolerance-assertedDate">
                        <valueDateTime>
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </valueDateTime>
                    </extension>
                </xsl:for-each>
                
                <xsl:for-each select="wijze_van_vaststellen[@code]">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-WayOfDetermination">
                        <valueCodeableConcept>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </valueCodeableConcept>
                    </extension>
                </xsl:for-each>
                
                <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-RelationCondition">
                    <valueReference>
                        <xsl:call-template name="makeReference">
                            <xsl:with-param name="in" select="."/>
                            <xsl:with-param name="profile" select="'cio-Condition'"/>
                        </xsl:call-template>
                    </valueReference>
                </extension>
                
                <xsl:if test="$relationHypersensitivity">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-RelationHypersensitivity">
                        <valueReference>
                            <xsl:call-template name="makeReference">
                                <xsl:with-param name="in" select="$relationHypersensitivity"/>
                                <xsl:with-param name="profile" select="'cio-Hypersensitivity'"/>
                            </xsl:call-template>
                        </valueReference>
                    </extension>
                </xsl:if>
                
                <xsl:if test="$relationReaction">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Reaction.RelationReaction">
                        <valueReference>
                            <xsl:call-template name="makeReference">
                                <xsl:with-param name="in" select="$relationReaction"/>
                                <xsl:with-param name="profile" select="'cio-Reaction'"/>
                            </xsl:call-template>
                        </valueReference>
                    </extension>
                </xsl:if>
                
                <xsl:for-each select="$identificationNumber[@value]">
                    <identifier>
                        <xsl:call-template name="id-to-Identifier">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </identifier>
                </xsl:for-each>
                
                <xsl:for-each select="aandoening_aanwezigheid[@code]">
                    <clinicalStatus>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                            <xsl:with-param name="codeMap" as="element()*">
                                <map inCode="410515003" inCodeSystem="{$oidSNOMEDCT}" code="active" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical" displayName="Active"/>
                                <map inCode="350361000146109" inCodeSystem="{$oidSNOMEDCT}" code="resolved" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical" displayName="Resolved"/>
                                <map inCode="410516002" inCodeSystem="{$oidSNOMEDCT}" code="inactive" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical" displayName="Inactive"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </clinicalStatus>
                </xsl:for-each>
                
                <xsl:for-each select="zekerheid_status[@code]">
                    <verificationStatus>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                            <xsl:with-param name="codeMap" as="element()*">
                                <map inCode="415684004" inCodeSystem="{$oidSNOMEDCT}" code="unconfirmed" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Unconfirmed"/>
                                <map inCode="410590009" inCodeSystem="{$oidSNOMEDCT}" code="unconfirmed" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Unconfirmed"/>
                                <map inCode="410605003" inCodeSystem="{$oidSNOMEDCT}" code="confirmed" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Confirmed"/>
                                <map inCode="410593006" inCodeSystem="{$oidSNOMEDCT}" code="unconfirmed" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Unconfirmed"/>
                                <map inCode="410516002" inCodeSystem="{$oidSNOMEDCT}" code="refuted" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Refuted"/>
                                <map inCode="UNK" inCodeSystem="2.16.840.1.113883.5.1008" code="unconfirmed" codeSystem="http://terminology.hl7.org/CodeSystem/allergyintolerance-verification" displayName="Unconfirmed"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </verificationStatus>
                </xsl:for-each>
                
                <xsl:for-each select="veroorzaker/veroorzakende_stof[@code]">
                    <code>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </code>
                </xsl:for-each>
                
                <xsl:call-template name="makeReference">
                    <xsl:with-param name="in" select="$subject"/>
                    <xsl:with-param name="wrapIn" select="'patient'"/>
                </xsl:call-template>
                
                <xsl:for-each select="$registrationDateTime[@value]">
                    <recordedDate>
                        <xsl:attribute name="value">
                            <xsl:call-template name="format2FHIRDate">
                                <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </recordedDate>
                </xsl:for-each>
                
                <xsl:for-each select="$author">
                    <xsl:call-template name="makeReference">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="wrapIn" select="'recorder'"/>
                        <xsl:with-param name="profile" select="'nl-core-HealthProfessional-PractitionerRole'"/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <xsl:for-each select="diagnose_steller/*">
                    <xsl:call-template name="makeReference">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="wrapIn" select="'asserter'"/>
                        <xsl:with-param name="profile" select="'nl-core-HealthProfessional-PractitionerRole'"/>
                    </xsl:call-template>
                </xsl:for-each>                
                
                <reaction>
                    <xsl:for-each select="blootstelling_datum_tijd[@value]">
                        <extension url="http://hl7.org/fhir/StructureDefinition/openEHR-exposureDate">
                            <valueDateTime>
                                <xsl:attribute name="value">
                                    <xsl:call-template name="format2FHIRDate">
                                        <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </valueDateTime>
                        </extension>
                    </xsl:for-each>
                    
                    <xsl:for-each select="latentietijd_reactie[@value]">
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-Reaction.LatencyReaction">
                            <valueDuration>
                                <xsl:call-template name="hoeveelheid-to-Duration">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </valueDuration>
                        </extension>
                    </xsl:for-each>
                    
                    <xsl:for-each select="tijdsduur_reactie[@value]">
                        <extension url="http://hl7.org/fhir/StructureDefinition/allergyintolerance-duration">
                            <valueDuration>
                                <xsl:call-template name="hoeveelheid-to-Duration">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </valueDuration>
                        </extension>
                    </xsl:for-each>
                    
                    <xsl:for-each select="veroorzaker/veroorzakende_stof[@code]">
                        <substance>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </substance>
                    </xsl:for-each>
                    
                    <xsl:for-each select="reactie_verschijnsel[@value]">
                        <manifestation>
                            <text>
                                <xsl:call-template name="string-to-string">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </text>
                        </manifestation>
                    </xsl:for-each>
                    
                    <xsl:for-each select="aandoening_begin_datum_tijd[@value]">
                        <onset>
                            <xsl:attribute name="value">
                                <xsl:call-template name="format2FHIRDate">
                                    <xsl:with-param name="dateTime" select="xs:string(@value)"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </onset>
                    </xsl:for-each>
                    
                    <xsl:for-each select="wijze_van_blootstelling[@code]">
                        <exposureRoute>
                            <xsl:call-template name="code-to-CodeableConcept">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </exposureRoute>
                    </xsl:for-each>
                    
                    <xsl:for-each select="toelichting[@value]">
                        <note>
                            <text>
                                <xsl:call-template name="string-to-string">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </text>
                        </note>
                    </xsl:for-each>
                </reaction>
            </AllergyIntolerance>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="reactie[parent::geneesmiddelovergevoeligheid]" mode="_generateDisplay">
        <xsl:param name="profile" required="yes" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$profile = 'cio-Reaction'">
                <xsl:variable name="parts" as="item()*">
                    <xsl:text>Reactie</xsl:text>
                    <xsl:value-of select="veroorzaker/veroorzakende_stof/@displayName"/>
                    <xsl:value-of select="concat('diagnosedatum: ', diagnostisch_inzicht_datum/@value)"/>
                </xsl:variable>
                <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
            </xsl:when>
            <xsl:when test="$profile = 'cio-Condition'">
                <xsl:variable name="parts" as="item()*">
                    <xsl:text>Aandoening</xsl:text>
                    <xsl:value-of select="diagnose/diagnose_naam/@displayName"/>
                    <xsl:value-of select="concat('diagnosedatum: ', diagnostisch_inzicht_datum/@value)"/>
                </xsl:variable>
                <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>