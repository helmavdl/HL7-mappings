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
<xsl:stylesheet xmlns:nf="http://www.nictiz.nl/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:pharm="urn:ihe:pharm:medication" xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="../../../hl7_2_ada_mp_include.xsl"/>
    <xd:doc>
        <xd:desc>Dit is een conversie van MP 9.1.0 naar ADA 9.1 beschikbaarstellen medicatieoverzicht</xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>
    <!-- de xsd variabelen worden gebruikt om de juiste conceptId's te vinden voor de ADA xml -->
    <xsl:param name="schema" select="document('../ada_schemas/beschikbaarstellen_medicatieoverzicht.xsd')"/>

    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, 'medicamenteuze_behandeling'))"/>

    <xsl:variable name="templateId-medicatieafspraak" select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9275', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9233'"/>
    <xsl:variable name="templateId-toedieningsafspraak" select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9299', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9256'"/>
    <xsl:variable name="templateId-medicatiegebruik" select="'2.16.840.1.113883.2.4.3.11.60.20.77.10.9279', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9250', '2.16.840.1.113883.2.4.3.11.60.20.77.10.9208'"/>
    <xsl:variable name="templateId-medicamenteuze-behandeling">2.16.840.1.113883.2.4.3.11.60.20.77.10.9084</xsl:variable>

    <xd:doc>
        <xd:desc> if this xslt is used stand alone the template below could be used. </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <!-- todo, add CDA-variant to xpath -->
        <xsl:variable name="medicatieoverzicht-9" select="//hl7:organizer[hl7:code[@code = '129'][@codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.4']]"/>
        <xsl:call-template name="Medicatieoverzicht-9-ADA">
            <xsl:with-param name="medicatieoverzicht-lijst" select="$medicatieoverzicht-9"/>
            <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handles HL7 9.1.0 medication overview, transforms it to ada.</xd:desc>
        <xd:param name="medicatieoverzicht-lijst">HL7 9.1.0 organizer with medication overview.</xd:param>
        <xd:param name="schemaFragment">schemaFragment, in this case of medicamenteuze behandeling. Used for conceptIds.</xd:param>
    </xd:doc>
    <xsl:template name="Medicatieoverzicht-9-ADA">
        <xsl:param name="medicatieoverzicht-lijst" select="//hl7:organizer[hl7:code[@code = '129'][@codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.4']]"/>
        <xsl:param name="schemaFragment" select="$schemaFragment"/>
        <xsl:call-template name="doGeneratedComment">
            <xsl:with-param name="in" select="$medicatieoverzicht-lijst/ancestor::*[hl7:ControlActProcess]"/>
        </xsl:call-template>
        <adaxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../ada_schemas/ada_beschikbaarstellen_medicatieoverzicht.xsd">
            <meta status="new" created-by="generated" last-update-by="generated">
                <xsl:attribute name="creation-date" select="current-dateTime()"/>
                <xsl:attribute name="last-update-date" select="current-dateTime()"/>
            </meta>
            <data>
                <xsl:for-each select="$medicatieoverzicht-lijst">
                    <xsl:call-template name="doGeneratedComment"/>
                    <xsl:variable name="patient" select="hl7:recordTarget/hl7:patientRole"/>
                    <beschikbaarstellen_medicatieoverzicht app="mp-mp910" shortName="beschikbaarstellen_medicatieoverzicht" formName="uitwisselen_medicatieoverzicht" transactionRef="2.16.840.1.113883.2.4.3.11.60.20.77.4.102" transactionEffectiveDate="2016-03-23T16:32:43" prefix="mp-" language="nl-NL" title="Generated" id="TODO">
                        <xsl:variable name="filename" select="tokenize(document-uri(/), '/')[last()]"/>
                        <xsl:variable name="extension" select="tokenize($filename, '\.')[last()]"/>
                        <xsl:variable name="theId" select="replace($filename, concat('.', $extension, '$'), '')"/>
                        <xsl:attribute name="title" select="$theId"/>
                        <xsl:attribute name="id" select="$theId"/>

                        <xsl:for-each select="$patient">
                            <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, 'beschikbaarstellen_medicatieoverzicht'))"/>
                            <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1_20180601000000">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="language" select="$language"/>
                                <xsl:with-param name="schema" select="$schema"/>
                                <xsl:with-param name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, 'patient'))"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <xsl:variable name="component" select=".//*[hl7:templateId/@root = ($templateId-medicatieafspraak, $templateId-toedieningsafspraak, $templateId-medicatiegebruik)]"/>
                        <xsl:for-each-group select="$component" group-by="hl7:entryRelationship/hl7:procedure[hl7:templateId/@root = $templateId-medicamenteuze-behandeling]/hl7:id/concat(@root, @extension)">
                            <!-- medicamenteuze_behandeling -->
                            <xsl:variable name="elemName">medicamenteuze_behandeling</xsl:variable>
                            <xsl:element name="{$elemName}">
                                <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                <xsl:variable name="elemName">identificatie</xsl:variable>
                                <!-- identificatie -->
                                <xsl:for-each select="hl7:entryRelationship/hl7:procedure[hl7:templateId/@root = $templateId-medicamenteuze-behandeling]/hl7:id">
                                    <xsl:variable name="elemName">identificatie</xsl:variable>
                                    <xsl:call-template name="handleII">
                                        <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elemName)))"/>
                                        <xsl:with-param name="elemName" select="$elemName"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                <!-- medicatieafspraak -->
                                <xsl:for-each select="current-group()[hl7:templateId/@root = $templateId-medicatieafspraak]">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9275_20191121115247">
                                        <xsl:with-param name="in" select="."/>
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                <!-- toedieningsafspraak -->
                                <xsl:for-each select="current-group()[hl7:templateId/@root = $templateId-toedieningsafspraak]">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9299_20191125140232">
                                        <xsl:with-param name="in" select="."/>
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                <!-- medicatiegebruik -->
                                <xsl:for-each select="current-group()[hl7:templateId/@root = $templateId-medicatiegebruik]">
                                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9281_20191121142645">
                                        <xsl:with-param name="in" select="."/>
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:for-each-group>

                        <!-- documentgegevens -->
                        <xsl:variable name="elemName">documentgegevens</xsl:variable>
                        <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName))"/>
                        <xsl:element name="{$elemName}">
                            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                            <!-- document_datum -->
                            <xsl:for-each select="hl7:effectiveTime[@value]">
                                <xsl:variable name="elemName">document_datum</xsl:variable>
                                <xsl:call-template name="handleTS">
                                    <xsl:with-param name="elemName" select="$elemName"/>
                                    <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elemName)))"/>
                                </xsl:call-template>
                            </xsl:for-each>

                            <!-- auteur -->
                            <xsl:for-each select="hl7:author">
                                <xsl:variable name="elemName">auteur</xsl:variable>
                                <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elemName))"/>
                                <xsl:element name="{$elemName}">
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <!-- auteur_is_zorgaanbieder -->
                                    <xsl:for-each select="hl7:assignedAuthor[not(hl7:code/@code = 'ONESELF')]/hl7:representedOrganization">
                                        <xsl:variable name="elemName">auteur_is_zorgaanbieder</xsl:variable>
                                        <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elemName))"/>
                                        <xsl:element name="{$elemName}">
                                            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                            <xsl:call-template name="mp908-zorgaanbieder">
                                                <xsl:with-param name="in" select="."/>
                                                <xsl:with-param name="schema" select="$schema"/>
                                                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
                                            </xsl:call-template>
                                        </xsl:element>
                                    </xsl:for-each>

                                    <!-- auteur_is_patient -->
                                    <xsl:for-each select="hl7:assignedAuthor[hl7:code/@code = 'ONESELF']">
                                        <xsl:variable name="elemName">auteur_is_patient</xsl:variable>
                                        <xsl:element name="{$elemName}">
                                            <xsl:attribute name="value">true</xsl:attribute>
                                            <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elemName)))"/>
                                        </xsl:element>
                                    </xsl:for-each>

                                </xsl:element>
                            </xsl:for-each>

                            <!-- verificatie_patient -->
                            <xsl:for-each select="hl7:participant[@typeCode = 'VRF'][hl7:participantRole[@classCode = 'PAT']]">
                                <xsl:variable name="elemName">verificatie_patient</xsl:variable>
                                <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName))"/>
                                <xsl:element name="{$elemName}">
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <!-- geverifieerd_met_patientq -->
                                    <xsl:variable name="elemName">geverifieerd_met_patientq</xsl:variable>
                                    <xsl:element name="{$elemName}">
                                        <xsl:attribute name="value" select="true()"/>
                                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName)))"/>
                                    </xsl:element>
                                    <!-- verificatie_datum -->
                                    <xsl:for-each select="hl7:time">
                                        <xsl:variable name="elemName">verificatie_datum</xsl:variable>
                                        <xsl:call-template name="handleTS">
                                            <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName)))"/>
                                            <xsl:with-param name="elemName" select="$elemName"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:for-each>
                            
                            <!-- verificatie_zorgverlener -->
                            <xsl:for-each select="hl7:participant[@typeCode = 'VRF'][hl7:participantRole[@classCode = 'ASSIGNED']]">
                                <xsl:variable name="elemName">verificatie_zorgverlener</xsl:variable>
                                <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName))"/>
                                <xsl:element name="{$elemName}">
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <!-- geverifieerd_met_patientq -->
                                    <xsl:variable name="elemName">geverifieerd_met_zorgverlenerq</xsl:variable>
                                    <xsl:element name="{$elemName}">
                                        <xsl:attribute name="value" select="true()"/>
                                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName)))"/>
                                    </xsl:element>
                                    <!-- verificatie_datum -->
                                    <xsl:for-each select="hl7:time">
                                        <xsl:variable name="elemName">verificatie_datum</xsl:variable>
                                        <xsl:call-template name="handleTS">
                                            <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elemName)))"/>
                                            <xsl:with-param name="elemName" select="$elemName"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:for-each>

                        </xsl:element>

                    </beschikbaarstellen_medicatieoverzicht>
                </xsl:for-each>
            </data>
        </adaxml>
        <!--<xsl:comment>Input HL7 xml below</xsl:comment>
		<xsl:call-template name="copyElementInComment">
			<xsl:with-param name="in" select="./*"/>
		</xsl:call-template>-->
    </xsl:template>
</xsl:stylesheet>
