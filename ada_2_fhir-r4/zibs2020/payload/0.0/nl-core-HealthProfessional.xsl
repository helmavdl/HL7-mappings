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
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet"> 
        <xd:desc>Converts ada zorgverlener_rol to FHIR resource conforming to profile nl-core-HealthProfessional-PractitionerRole</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Creates an nl-core-HealthProfessional-PractitionerRole FHIR instance from an ada 'zorgverlener' element. Please note that following the zib2020 R4 profiling guidelines, a PractitionerRole that references a Practitioner is considered more meaningful than directly referencing a Practitioner.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="logicalId">Optional logical id for the FHIR instance.</xd:param>
    </xd:doc>
    <xsl:template match="zorgverlener" mode="nl-core-HealthProfessional-PractitionerRole" name="nl-core-HealthProfessional-PractitionerRole" as="element(f:PractitionerRole)?">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="logicalId" as="xs:string?"/>
        
        <xsl:for-each select="$in[.//@value]">
            <PractitionerRole>
                <xsl:if test="zorgverlener_identificatienummer | naamgegevens | geslacht | adresgegevens">
                    <practitioner>
                        <xsl:call-template name="makeReference">
                            <xsl:with-param name="profile">nl-core-HealthProfessional-Practitioner</xsl:with-param>
                        </xsl:call-template>
                    </practitioner>
                </xsl:if>
                <xsl:if test="zorgaanbieder">
                    <organization>
                        <!--<xsl:call-template name="nl-core-HealthcareProvider-reference"/>-->
                    </organization>
                </xsl:if>
                <xsl:if test="specialisme/@value">
                    <valueCodeableConcept>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </valueCodeableConcept>
                </xsl:if>
                <xsl:for-each select="contactgegevens">
                    <xsl:call-template name="nl-core-ContactInformation"/>
                </xsl:for-each>
            </PractitionerRole>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Creates an nl-core-HealthProfessional-Practitioner FHIR instance from an ada 'zorgverlener' element.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="logicalId">Optional logical id for the FHIR instance.</xd:param>
    </xd:doc>
    <xsl:template match="zorgverlener" mode="nl-core-HealthProfessional-Practitioner"
        name="nl-core-HealthProfessional-Practitioner" as="element(f:Practitioner)*">
        <xsl:param name="in" select="." as="element()*"/>
        <xsl:for-each select="$in[.//@value]">
            <Practitioner>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner" />
                </meta>
                <xsl:for-each select="zorgverlener_identificatienummer">
                    <identifier>
                        <xsl:call-template name="id-to-Identifier">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </identifier>
                </xsl:for-each>
                
                <!--<xsl:for-each select="naamgegevens">
                    <xsl:call-template name="nl-core-NameInformation"/>
                </xsl:for-each>-->
                <xsl:for-each select="contactgegevens">
                    <xsl:call-template name="nl-core-ContactInformation"/>
                </xsl:for-each>
                <xsl:for-each select="adresgegevens">
                    <xsl:call-template name="nl-core-AddressInformation"/>
                </xsl:for-each>
                <xsl:for-each select="geslacht">
                    <gender>
                        <xsl:call-template name="code-to-code">
                            <xsl:with-param name="in" select="."/>
                            <xsl:with-param name="codeMap" as="element()*">
                                <map inCode="M" inCodeSystem="2.16.840.1.113883.5.1" code="male"/>
                                <map inCode="F" inCodeSystem="2.16.840.1.113883.5.1" code="female"/>
                                <map inCode="UN" inCodeSystem="2.16.840.1.113883.5.1" code="other"/>
                                <map inCode="UNK" inCodeSystem="2.16.840.1.113883.5.1008" code="unknown"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="ext-CodeSpecification"/>
                    </gender>
                </xsl:for-each>            
                <!--<xsl:for-each select="zorgaanbieder">
                    <xsl:call-template name="nl-core-HealthcareProvider-reference"/>
                </xsl:for-each>-->       
            </Practitioner>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="zorgverlener" mode="_generateDisplay">
        <xsl:param name="profile" required="yes" as="xs:string"/>
        
        <xsl:variable name="personIdentifier" select="nf:ada-zvl-id(.//zorgverlener_identificatienummer[1])"/>
        <xsl:variable name="personName" select=".//naamgegevens[not(naamgegevens)][1]//*[not(name() = 'naamgebruik')]/@value"/>
        
        <!--<xsl:variable name="theHealthCareProvider" select="naf:resolve-ada-reference(.//(zorgaanbieder[not(zorgaanbieder)] | healthcare_provider[not(healthcare_provider)]))"/>-->
        <!--<xsl:variable name="organizationName" select="$theHealthCareProvider//(organisatie_naam | organization_name)[1]/@value"/>-->
        <xsl:variable name="organizationName" select=".//organisatie_naam[1]/@value"/>
        <xsl:variable name="specialty" select=".//specialisme[not(@codeSystem = $oidHL7NullFlavor)][1]/@displayName"/>
        <xsl:variable name="role" select=".//zorgverleners_rol[1]/(@displayName, @code)[1]"/>
        
        <xsl:choose>
            <xsl:when test="$profile = 'nl-core-HealthProfessional-PractitionerRole'">
                <xsl:choose>
                    <xsl:when test="$personName | $specialty | $organizationName">
                        <xsl:value-of select="normalize-space(string-join((string-join($personName, ' ')[not(. = '')], $specialty, $organizationName), ' || '))"/>
                    </xsl:when>
                    <xsl:when test="$role">
                        <xsl:value-of select="normalize-space($role)"/>
                    </xsl:when>
                    <xsl:when test="$personIdentifier[@value]">
                        <xsl:variable name="codesystemDisplay" as="xs:string?">
                            <xsl:choose>
                                <xsl:when test="string-length($oidMap[@oid = $personIdentifier/@root]/@displayName) gt 0">
                                    <xsl:value-of select="$oidMap[@oid = $personIdentifier/@root]/@displayName"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$personIdentifier/@root"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="idDisplay" as="xs:string*">
                            <xsl:if test="string-length($personIdentifier/@value) gt 0">Persoonsidentificatie: <xsl:value-of select="normalize-space($personIdentifier/@value)"/></xsl:if>
                            <xsl:if test="string-length($codesystemDisplay) gt 0">(uit codesysteem <xsl:value-of select="$codesystemDisplay"/>).</xsl:if>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space(string-join($idDisplay, ' '))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$profile = 'nl-core-HealthProfessional-Practitioner'">
                <xsl:choose>
                    <xsl:when test="$personName">
                        <xsl:value-of select="normalize-space(string-join($personName, ' '))"/>
                    </xsl:when>
                    <xsl:when test="$role">
                        <xsl:value-of select="normalize-space($role)"/>
                    </xsl:when>
                    <xsl:when test="$personIdentifier">
                        <xsl:value-of select="normalize-space($personIdentifier)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="zorgverlener" mode="_generateId">
        <xsl:param name="profile" required="yes" as="xs:string"/>
        <xsl:param name="fullUrl" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$profile = 'nl-core-HealthProfessional-PractitionerRole'">
                <xsl:variable name="personIdentifier" select="nf:getValueAttrDefault(nf:ada-zvl-id(zorgverlener_identificatienummer))"/>
                <xsl:variable name="specialism" select="upper-case(string-join((specialisme//@code)/normalize-space(), ''))"/>
                <xsl:variable name="organizationId" select="nf:getValueAttrDefault(nf:ada-za-id(.//(zorgaanbieder_identificatienummer | zorgaanbieder_identificatie_nummer | healthcare_provider_identification_number)))"/>
                
                <xsl:value-of select="concat($personIdentifier, $specialism, $organizationId)"/>
            </xsl:when>
            <xsl:when test="$profile = 'nl-core-HealthProfessional-Practitioner'">
                <xsl:choose>
                    <xsl:when test="(zorgverlener_identificatienummer)[@value | @root]">
                        <xsl:value-of select="(upper-case(nf:removeSpecialCharacters(string-join((zorgverlener_identificatienummer)[1]/(@value | @root), ''))))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="nf:removeSpecialCharacters(replace($fullUrl, 'urn:[^i]*id:', ''))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>