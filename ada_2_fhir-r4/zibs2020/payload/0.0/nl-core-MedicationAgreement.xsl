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
        <xd:desc>Converts ADA medicatieafspraak to FHIR MedicationRequest conforming to profile nl-core-MedicationAgreement</xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>Create a nl-core-MedicationAgreement instance as a MedicationRequest FHIR instance from ADA medicatieafspraak.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="subject">The MedicationRequest.subject as ADA element or reference.</xd:param>
        <xd:param name="medicationReference">The MedicationRequest.medicationReference as ADA element or reference.</xd:param>
        <xd:param name="requester">The MedicationRequest.requester as ADA element or reference.</xd:param>
        <xd:param name="reasonReference">The MedicationRequest.reasonReference as ADA element or reference.</xd:param>
    </xd:doc>
    <xsl:template name="nl-core-MedicationAgreement" mode="nl-core-MedicationAgreement" match="medicatieafspraak" as="element(f:MedicationRequest)?">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="subject" select="patient/*" as="element()?"/>
        <xsl:param name="medicationReference" select="(afgesprokengeneesmiddel | afgesproken_geneesmiddel)/farmaceutisch_product" as="element()?"/>
        <xsl:param name="requester" select="voorschrijver" as="element()?"/>
        <xsl:param name="reasonReference" select="reden_van_voorschrijven" as="element()?"/>

        <xsl:for-each select="$in">
            <MedicationRequest>
                <xsl:call-template name="insertLogicalId"/>
                <meta>
                    <profile value="{nf:get-full-profilename-from-adaelement(.)}"/>
                </meta>

                <xsl:for-each select="(medicatieafspraak_aanvullende_informatie | aanvullende_informatie)">
                    <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.MedicationAgreementAdditionalInformation">
                        <valueCodeableConcept>
                            <xsl:call-template name="code-to-CodeableConcept"/>
                        </valueCodeableConcept>
                    </extension>
                </xsl:for-each>

                <xsl:for-each select="gebruiksinstructie">
                    <xsl:call-template name="ext-RenderedDosageInstruction"/>
                </xsl:for-each>

                <xsl:for-each select="gebruiksperiode">
                    <xsl:call-template name="ext-TimeInterval.Period"/>
                    <xsl:call-template name="ext-TimeInterval.Duration"/>
                </xsl:for-each>

                <!-- pharmaceuticalTreatmentIdentifier -->
                <xsl:for-each select="../identificatie">
                    <xsl:call-template name="ext-PharmaceuticalTreatmentIdentifier">
                        <xsl:with-param name="in" select="."/>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:for-each select="kopie_indicator[@value | @nullFlavor]">
                    <xsl:call-template name="ext-CopyIndicator"/>
                </xsl:for-each>
                
                <xsl:for-each select="relatie_zorgepisode/(identificatie | identificatienummer)[@value]">
                    <xsl:call-template name="ext-Context-EpisodeOfCare"/>
                </xsl:for-each>

                <!--herhaalperiode_cyclisch_schema-->
                <xsl:for-each select="gebruiksinstructie">
                    <xsl:call-template name="ext-InstructionsForUse.RepeatPeriodCyclicalSchedule"/>
                </xsl:for-each>

                <xsl:for-each select="medicatieafspraak_stop_type">
                    <modifierExtension url="http://nictiz.nl/fhir/StructureDefinition/ext-StopType">
                        <valueCodeableConcept>
                            <xsl:call-template name="code-to-CodeableConcept"/>
                        </valueCodeableConcept>
                    </modifierExtension>
                </xsl:for-each>

                <xsl:for-each select="identificatie[@value | @root | @nullFlavor]">
                    <identifier>
                        <xsl:call-template name="id-to-Identifier"/>
                    </identifier>
                </xsl:for-each>

                <!-- we do not know the current status of this instance -->
                <status value="unknown"/>

                <intent value="order"/>

                <!-- Issue MP-489: code should be updated to 33633005, but update also needed in FHIR profile -->
                <category>
                    <coding>
                        <system value="http://snomed.info/sct"/>
                        <code value="16076005"/>
                        <display value="voorschrijven"/>
                    </coding>
                </category>

                <xsl:for-each select="$medicationReference">
                    <medicationReference>
                        <xsl:call-template name="makeReference"/>
                    </medicationReference>
                </xsl:for-each>

                <xsl:for-each select="$subject">
                    <subject>
                        <xsl:call-template name="makeReference"/>
                    </subject>
                </xsl:for-each>

                <xsl:for-each select="relatie_contact/(identificatie | identificatienummer)[@value]">
                    <encounter>
                        <type value="Encounter"/>
                        <identifier>
                            <xsl:call-template name="id-to-Identifier"/>
                        </identifier>
                        <display value="relatie naar contact met identificatie: {string-join((@value, @root), ' || ')}"/>
                    </encounter>
                </xsl:for-each>

                <xsl:for-each select="medicatieafspraak_datum_tijd">
                    <authoredOn>
                        <xsl:attribute name="value">
                            <xsl:call-template name="format2FHIRDate">
                                <xsl:with-param name="dateTime" select="./@value"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </authoredOn>
                </xsl:for-each>

                <xsl:for-each select="$requester">
                    <requester>
                        <xsl:call-template name="makeReference">
                            <xsl:with-param name="profile">nl-core-HealthProfessional-PractitionerRole</xsl:with-param>
                        </xsl:call-template>
                    </requester>
                </xsl:for-each>

                <xsl:for-each select="reden_wijzigen_of_staken[@code]">
                    <reasonCode>
                        <xsl:call-template name="code-to-CodeableConcept"/>
                    </reasonCode>
                </xsl:for-each>

                <xsl:for-each select="$reasonReference">
                    <reasonReference>
                        <xsl:call-template name="makeReference"/>
                    </reasonReference>
                </xsl:for-each>
                
                <xsl:for-each select="relatie_toedieningsafspraak/identificatie[@value]">
                    <basedOn>
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.RelationAdministrationAgreement">
                            <valueReference>
                                <type value="MedicationDispense"/>
                                <identifier>
                                    <xsl:call-template name="id-to-Identifier"/>
                                </identifier>
                                <display value="relatie naar toedieningsafspraak met identificatie: {string-join((@value, @root), ' || ')}"/>
                            </valueReference>
                        </extension>
                    </basedOn>
                </xsl:for-each>
                
                <xsl:for-each select="relatie_medicatiegebruik/identificatie[@value]">
                    <basedOn>
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.RelationMedicationUse">
                            <valueReference>
                                <type value="MedicationUse"/>
                                <identifier>
                                    <xsl:call-template name="id-to-Identifier"/>
                                </identifier>
                                <display value="relatie naar medicatiegebruik met identificatie: {string-join((@value, @root), ' || ')}"/>
                            </valueReference>
                        </extension>
                    </basedOn>
                </xsl:for-each>               

                <xsl:for-each select="toelichting">
                    <note>
                        <text>
                            <xsl:call-template name="string-to-string"/>
                        </text>
                    </note>
                </xsl:for-each>

                <xsl:for-each select="gebruiksinstructie">
                    <xsl:call-template name="nl-core-InstructionsForUse.DosageInstruction">
                        <xsl:with-param name="wrapIn">dosageInstruction</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>

                <xsl:for-each select="relatie_medicatieafspraak/identificatie[.//@value]">
                    <priorPrescription>
                        <type value="MedicationRequest"/>
                        <identifier>
                            <xsl:call-template name="id-to-Identifier"/>
                        </identifier>
                        <display value="relatie naar medicatieafspraak: {string-join((@value, @root), ' || ')}"/>
                    </priorPrescription>
                </xsl:for-each>
            </MedicationRequest>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a unique id to identify this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="medicatieafspraak" mode="_generateId">

        <xsl:variable name="uniqueString" as="xs:string?">
            <xsl:choose>
                <xsl:when test="identificatie[@root][@value]">
                    <xsl:for-each select="(identificatie[@root][@value])[1]">
                        <!-- we remove '.' in root oid and '_' in extension to enlarge the chance of staying in 64 chars -->
                        <xsl:value-of select="concat(replace(@root, '\.', ''), '-', replace(@value, '_', ''))"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- we do not have anything to create a stable logicalId, lets return a UUID -->
                    <xsl:value-of select="uuid:get-uuid(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="generateLogicalId">
            <xsl:with-param name="uniqueString" select="$uniqueString"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
    </xd:doc>
    <xsl:template match="medicatieafspraak" mode="_generateDisplay">
        <xsl:variable name="parts">
            <xsl:value-of select="'Medication agreement'"/>
            <xsl:value-of select="afgesprokengeneesmiddel/@display"/>
            <xsl:value-of select="medicatieafspraak_datum_tijd/@value"/>
            <xsl:value-of select="medicatieafspraak_stop_type/@display"/>
        </xsl:variable>
        <xsl:value-of select="string-join($parts, '-')"/>
    </xsl:template>
</xsl:stylesheet>
