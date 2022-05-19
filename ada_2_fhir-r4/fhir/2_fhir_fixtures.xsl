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
<!-- Purpose: do handling for FHIR fixtures for examples and/or Touchstone fixtures
-->
<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:util="urn:hl7:utilities" xmlns:uuid="http://www.uuid.org" version="2.0" exclude-result-prefixes="#all">

    <xd:doc>
        <xd:desc>Usecasename for resource id. Optional, no default.</xd:desc>
    </xd:doc>
    <xsl:param name="usecase" as="xs:string?"/>

    <xd:doc>
        <xd:desc>Helper template for creating logicalId for Touchstone. Adheres to requirements in MM-1752. Profilename-usecase-uniquestring.</xd:desc>
        <xd:param name="in">The ada element for which to create a logical id. Optional. Used to find profileName. Defaults to context.</xd:param>
        <xd:param name="uniqueString">The unique string with which to create a logical id. Optional. If not given a uuid will be generated.</xd:param>
        <xd:param name="profileName">Ability to override the default in case you have two ada element names which may end up in different FHIR profiles</xd:param>
    </xd:doc>
    <xsl:template name="generateLogicalIdWithProfile">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="uniqueString" as="xs:string?"/>
        <!-- NOTE: this does not work if you have two ada element names which may end up in different FHIR profiles, the function simply selects the first one found -->
        <xsl:param name="profileName" as="xs:string?" select="nf:get-profilename-from-adaelement($in)"/>

        <xsl:variable name="logicalIdStartString" as="xs:string*">
            <xsl:value-of select="$profileName"/>
            <xsl:value-of select="$usecase"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($uniqueString) le $maxLengthFHIRLogicalId - 2 and string-length($uniqueString) gt 0">
                <xsl:value-of select="replace(nf:assure-logicalid-length(nf:assure-logicalid-chars(concat(string-join($logicalIdStartString, '-'), '-', $uniqueString))), '\.', '-')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
                <xsl:value-of select="nf:assure-logicalid-length(nf:assure-logicalid-chars(concat(string-join($logicalIdStartString, '-'), '-', uuid:get-uuid(.))))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>Helper template for creating logicalId for Touchstone. Adheres to requirements in MM-1752. Profilename-usecase-uniquestring.</xd:desc>
        <xd:param name="in">The ada element for which to create a logical id. Optional. Used to find profileName. Defaults to context.</xd:param>
        <xd:param name="uniqueString">The unique string with which to create a logical id. Optional. If not given a uuid will be generated.</xd:param>
    </xd:doc>
    <xsl:template name="generateLogicalId">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="uniqueString" as="xs:string?"/>
        <!-- NOTE: this does not work if you have two ada element names which may end up in different FHIR profiles, the function simply selects the first one found -->
        <xsl:variable name="profileName" as="xs:string?" select="nf:get-profilename-from-adaelement($in)"/>

        <xsl:variable name="logicalIdStartString" as="xs:string*">
            <xsl:value-of select="$profileName"/>
            <xsl:value-of select="$usecase"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($uniqueString) le $maxLengthFHIRLogicalId - 2 and string-length($uniqueString) gt 0">
                <xsl:value-of select="replace(nf:assure-logicalid-length(nf:assure-logicalid-chars(concat(string-join($logicalIdStartString, '-'), '-', $uniqueString))), '\.', '-')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
                <xsl:value-of select="nf:assure-logicalid-length(nf:assure-logicalid-chars(concat(string-join($logicalIdStartString, '-'), '-', uuid:get-uuid(.))))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- override the logicalId generation for our Touchstone resources -->
    <xd:doc>
        <xd:desc>Template to generate a unique id to identify this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="medicatieafspraak | wisselend_doseerschema | verstrekkingsverzoek | toedieningsafspraak | medicatieverstrekking | medicatiegebruik | medicatietoediening" mode="_generateId">

        <xsl:variable name="uniqueString" as="xs:string?">
            <xsl:choose>
                <xsl:when test="identificatie[@root][@value]">
                    <xsl:for-each select="(identificatie[@root][@value])[1]">
                        <!-- we remove '.' in root oid and '_' in extension to enlarge the chance of staying in 64 chars -->
                        <xsl:value-of select="replace(@value, '_', '')"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
                    <xsl:value-of select="nf:get-uuid(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="profile" select="nf:get-profilename-from-adaelement(.)"/>
        <xsl:call-template name="generateLogicalIdWithProfile">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
            <xsl:with-param name="profileName" select="replace(replace(replace(replace(replace(replace($profile,'Agreement', 'Agr'), 'Medication', 'Med'), 'Administration', 'Adm'), 'Dispense', 'Dsp'), 'Request', 'Req'), 'VariableDosingRegimen', 'VarDosReg')"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a unique id to identify a HealthProfessional present in a (set of) ada-instance(s)</xd:desc>
        <xd:param name="profile">Profile being handled, to distinguish between Practitioner and PractitionerRole</xd:param>
        <xd:param name="fullUrl">If the HealthProfessional is identified by fullUrl, this optional parameter can be used as fallback for an id</xd:param>
    </xd:doc>
    <xsl:template match="zorgverlener" mode="_generateId">
        <xsl:param name="profile" required="yes" as="xs:string"/>
        <xsl:param name="fullUrl" tunnel="yes"/>

        <!-- we can only use zorgverlener_identificatienummer as logicalId when there is no other preceding zorgverlener with the same identificatienummer and a different grouping-key -->
        <xsl:variable name="currentZvlId" select="nf:ada-healthprofessional-id(zorgverlener_identificatienummer)"/>
        <xsl:variable name="precedingZvlCurrentId" as="element()*" select="preceding::zorgverlener[zorgverlener_identificatienummer[@root = $currentZvlId/@root][@value = $currentZvlId/@value]]"/>
        <xsl:variable name="precedingZvlKey" select="nf:getGroupingKeyDefault($precedingZvlCurrentId)" as="xs:string?"/>
        <xsl:variable name="idAsLogicalIdAllowed" as="xs:boolean?" select="empty($precedingZvlKey) or current-grouping-key() = $precedingZvlKey"/>

        <xsl:variable name="uniqueString" as="xs:string?">

            <xsl:choose>
                <xsl:when test="not($idAsLogicalIdAllowed)">
                    <xsl:next-match>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:next-match>
                </xsl:when>
                <xsl:when test="$profile = $profileNameHealthProfessionalPractitionerRole">
                    <!-- we only use value attributes from person, specialism and organization, including the oid would breach the 64 chars for logicalId -->
                    <xsl:variable name="personIdentifier" select="nf:getValueAttrDefault(nf:ada-healthprofessional-id(zorgverlener_identificatienummer))"/>
                    <xsl:variable name="specialism" select="upper-case(string-join((specialisme//@code)/normalize-space(), ''))"/>
                    <!-- AWE: not so nice to search "anywhere in the input ada" for a matching zorgaanbieder -->
                    <xsl:variable name="organization" select="//zorgaanbieder[@id = current()//zorgaanbieder[not(zorgaanbieder)]/@value]"/>
                    <xsl:variable name="organizationId" select="nf:getValueAttrDefault(nf:ada-healthprovider-id($organization/zorgaanbieder_identificatienummer))"/>

                    <xsl:variable name="display" select="concat($personIdentifier, '-', $specialism, '-', $organizationId)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($display) gt 0">
                            <xsl:value-of select="$display"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:next-match/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$profile = $profileNameHealthProfessionalPractitioner">
                    <xsl:choose>
                        <xsl:when test="zorgverlener_identificatienummer[@value | @root]">
                            <!-- we remove '.' in root oid and '_' in extension to enlarge the chance of staying in 64 chars -->
                            <xsl:for-each select="(zorgverlener_identificatienummer[@value | @root])[1]">
                                <xsl:value-of select="concat(replace(@root, '\.', ''), '-', replace(@value, '_', ''))"/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:next-match/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="generateLogicalIdWithProfile">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
            <xsl:with-param name="profileName" select="replace(replace(replace($profile, 'HealthProfessional', 'HPrf'), 'Practitioner', 'Prac'), 'Role', 'Rol')"/>
        </xsl:call-template>

    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a unique id to identify a HealthProfessional present in a (set of) ada-instance(s)</xd:desc>
        <xd:param name="profile">Profile</xd:param>
    </xd:doc>
    <xsl:template match="zorgaanbieder" mode="_generateId">
        <xsl:param name="profile" required="yes" as="xs:string"/>

        <xsl:variable name="organizationLocation" select="(organisatie_locatie/locatie_naam/@value[not(. = '')], 'Location')[1]"/>

        <!-- we can only use zorgaanbieder_identificatienummer as logicalId when there is no other preceding zorgaanbieder with the same identificatienummer and a different grouping-key -->
        <xsl:variable name="currentZaId" select="nf:ada-healthprovider-id(zorgaanbieder_identificatienummer)"/>
        <xsl:variable name="precedingZaCurrentId" as="element()*" select="preceding::zorgaanbieder[zorgaanbieder_identificatienummer[@root = $currentZaId/@root][@value = $currentZaId/@value]]"/>
        <xsl:variable name="precedingZaKey" select="nf:getGroupingKeyDefault($precedingZaCurrentId)" as="xs:string?"/>
        <xsl:variable name="idAsLogicalIdAllowed" as="xs:boolean?" select="empty($precedingZaKey) or current-grouping-key() = $precedingZaKey"/>

        <xsl:variable name="uniqueString" as="xs:string?">
            <xsl:choose>
                <xsl:when test="not($idAsLogicalIdAllowed)">
                    <xsl:next-match>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:next-match>
                </xsl:when>
                <xsl:when test="zorgaanbieder_identificatienummer[@value | @root]">
                    <!-- we remove '.' in root oid and '_' in extension to enlarge the chance of staying in 64 chars -->
                    <xsl:for-each select="(zorgaanbieder_identificatienummer[@value | @root])[1]">
                        <xsl:value-of select="concat(replace(@root, '\.', ''), '-', replace(@value, '_', ''))"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-match>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:next-match>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="generateLogicalIdWithProfile">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
            <xsl:with-param name="profileName" select="replace(replace(replace($profile, 'HealthcareProvider', 'HPrv'), 'Organization', 'Org'), 'Location', 'Loc')"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a unique id to identify this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="farmaceutisch_product" mode="_generateId">

        <xsl:variable name="uniqueString" as="xs:string?">
            <xsl:choose>
                <xsl:when test="product_code[@codeSystem = ($oidGStandaardZInummer, $oidGStandaardHPK, $oidGStandaardPRK, $oidGStandaardGPK, $oidGStandaardSNK, $oidGStandaardSSK)][@code]">
                    <xsl:variable name="most-specific-product-code" select="nf:get-specific-productcode(product_code)" as="element(product_code)?"/>
                    <xsl:value-of select="concat(replace($most-specific-product-code/@codeSystem, '\.', ''), '-', $most-specific-product-code/@code)"/>
                </xsl:when>
                <xsl:when test="product_code[not(@codeSystem = $oidHL7NullFlavor)]">
                    <!-- own 90-million product-code which will fit in a logicalId -->
                    <xsl:variable name="productCode" select="product_code[not(@codeSystem = $oidHL7NullFlavor)][1]" as="element(product_code)?"/>
                    <!-- we remove '.' in codeSystem to enlarge the chance of staying in 64 chars -->
                    <xsl:value-of select="concat(replace($productCode/@codeSystem, '\.', ''), '-', $productCode/@code)"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
                    <xsl:value-of select="uuid:get-uuid(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="generateLogicalIdWithProfile">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
            <xsl:with-param name="profileName" select="replace(nf:get-profilename-from-adaelement(.), 'PharmaceuticalProduct', 'PhPrd')"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates xml document for a FHIR resource</xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="doResourceInResultdoc">
        <xsl:result-document href="./{./f:id/@value}.xml">
            <xsl:copy-of select="."/>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
