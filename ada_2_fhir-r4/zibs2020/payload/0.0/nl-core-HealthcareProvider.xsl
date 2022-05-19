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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:util="urn:hl7:utilities" xmlns:f="http://hl7.org/fhir" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:nm="http://www.nictiz.nl/mappings" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc scope="stylesheet">
        <xd:desc>Converts ada zorgaanbieder to FHIR resource conforming to profile nl-core-HealthcareProvider</xd:desc>
    </xd:doc>

    <xsl:variable name="profilenameHealthcareProvider">nl-core-HealthcareProvider</xsl:variable>
    <xsl:variable name="profilenameHealthcareProviderOrganization">nl-core-HealthcareProvider-Organization</xsl:variable>

    <xd:doc>
        <xd:desc>Produces a Location resource based on nl-core-HealthcareProvider</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
    </xd:doc>
    <xsl:template match="zorgaanbieder[not(zorgaanbieder)]" mode="nl-core-HealthcareProvider" name="nl-core-HealthcareProvider" as="element(f:Location)?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:for-each select="$in">
            <Location>
                <xsl:call-template name="insertLogicalId">
                    <xsl:with-param name="profile" select="$profilenameHealthcareProvider"/>
                </xsl:call-template>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider"/>
                </meta>

                <xsl:for-each select="organisatie_locatie/locatie_naam">
                    <name value="{@value}"/>
                </xsl:for-each>

                <xsl:for-each select="organisatie_locatie/locatie_nummer">
                    <alias value="{@value}"/>
                </xsl:for-each>

                <xsl:call-template name="nl-core-ContactInformation">
                    <xsl:with-param name="in" select="contactgegevens"/>
                </xsl:call-template>

                <xsl:call-template name="nl-core-AddressInformation">
                    <xsl:with-param name="in" select="adresgegevens"/>
                </xsl:call-template>

                <xsl:call-template name="makeReference">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="profile" select="'nl-core-HealthcareProvider-Organization'"/>
                    <xsl:with-param name="wrapIn" select="'managingOrganization'"/>
                </xsl:call-template>
            </Location>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Produces a Organization resource based on nl-core-HealthcareProvider-Organization</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
    </xd:doc>
    <xsl:template match="zorgaanbieder[not(zorgaanbieder)]" mode="nl-core-HealthcareProvider-Organization" name="nl-core-HealthcareProvider-Organization" as="element(f:Organization)?">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:for-each select="$in">
            <Organization>
                <xsl:call-template name="insertLogicalId">
                    <xsl:with-param name="profile" select="$profilenameHealthcareProviderOrganization"/>
                </xsl:call-template>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider-Organization"/>
                </meta>
                <xsl:for-each select="zorgaanbieder_identificatienummer[@value]">
                    <identifier>
                        <xsl:call-template name="id-to-Identifier">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </identifier>
                </xsl:for-each>

                <xsl:for-each select="organisatie_type | afdeling_specialisme">
                    <type>
                        <xsl:call-template name="code-to-CodeableConcept">
                            <xsl:with-param name="in" select="."/>
                        </xsl:call-template>
                    </type>
                </xsl:for-each>

                <xsl:for-each select="organisatie_naam">
                    <name value="{@value}"/>
                </xsl:for-each>

                <xsl:call-template name="nl-core-ContactInformation">
                    <xsl:with-param name="in" select="contactgegevens"/>
                </xsl:call-template>

                <xsl:call-template name="nl-core-AddressInformation">
                    <xsl:with-param name="in" select="adresgegevens"/>
                </xsl:call-template>
            </Organization>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a display that can be shown when referencing a HealthcareProvider, both to a Location and an Organization resource</xd:desc>
        <xd:param name="profile"/>
    </xd:doc>
    <xsl:template match="zorgaanbieder" mode="_generateDisplay">
        <xsl:param name="profile" required="yes" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$profile = $profilenameHealthcareProvider">
                <xsl:variable name="parts" as="item()*">
                    <xsl:text>Healthcare provider (location)</xsl:text>
                    <xsl:value-of select="organisatie_naam/@value"/>
                    <xsl:value-of select="organisatie_locatie/locatie_naam/@value"/>
                    <xsl:if test="not(organisatie_naam/@value | organisatie_locatie/locatie_naam/@value)">
                        <xsl:value-of select="concat('organisation-id ', zorgaanbieder_identificatienummer/@value, ' in system ', zorgaanbieder_identificatienummer/@root)"/>
                    </xsl:if>
                    <xsl:value-of select="toelichting/@value"/>
                </xsl:variable>
                <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
            </xsl:when>
            <xsl:when test="$profile = $profilenameHealthcareProviderOrganization">
                <xsl:variable name="parts" as="item()*">
                    <xsl:text>Healthcare provider (organization)</xsl:text>
                    <xsl:value-of select="organisatie_naam/@value"/>
                    <xsl:if test="not(organisatie_naam/@value)">
                        <xsl:value-of select="concat('organisation-id ', zorgaanbieder_identificatienummer/@value, ' in system ', zorgaanbieder_identificatienummer/@root)"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
            </xsl:when>
        </xsl:choose>
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

        <xsl:call-template name="generateLogicalId">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Selects the most appropriate health provider identification. For example to do deduplication of organizations or to base a logicalId on.</xd:desc>
        <xd:param name="healthcareProviderIdentification">ADA element containing the healthcare provider organization identification</xd:param>
    </xd:doc>
    <xsl:function name="nf:ada-healthprovider-id" as="element()?">
        <xsl:param name="healthcareProviderIdentification" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$healthcareProviderIdentification[@root = $oidURAOrganizations]">
                <xsl:copy-of select="$healthcareProviderIdentification[@root = $oidURAOrganizations][1]"/>
            </xsl:when>
            <xsl:when test="$healthcareProviderIdentification[@root = $oidAGB]">
                <xsl:copy-of select="$healthcareProviderIdentification[@root = $oidAGB][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$healthcareProviderIdentification[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
