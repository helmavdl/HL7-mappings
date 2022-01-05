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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions"
    xmlns:nf="http://www.nictiz.nl/functions" xmlns:util="urn:hl7:utilities" exclude-result-prefixes="#all" version="2.0">

    <xsl:variable name="medication-AdditionalInformation"
        select="'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.MedicationAgreementAdditionalInformation'"/>
    <!--xxxwim geen gerelateerde zib of nl_core gevonden-->
    <xsl:variable name="extRelatedMedicationUse" select="'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.RelatedMedicationUse'"/>

    <xd:doc>
        <xd:desc>Template to convert f:MedicationRequest to ADA medicatieafspraak</xd:desc>
    </xd:doc>
    <xsl:template match="f:MedicationRequest" mode="nl-core-DispenseRequest">
        <verstrekkingsverzoek>
            <!-- identificatie -->
            <xsl:apply-templates select="f:identifier" mode="#current"/>
            <!-- afspraakdatum -->
            <xsl:apply-templates select="f:authoredOn" mode="#current"/>
            <!--auteur/zorgverlener-->
            <xsl:apply-templates select="f:requester" mode="#current"/>
            <!-- (ref) te_verstrekken_geneesmiddel -->
            <xsl:apply-templates select="f:medicationReference" mode="#current"/>
            <!--te_verstrekken_hoeveelheid-->
            <xsl:apply-templates select="f:dispenseRequest/f:quantity" mode="#current"/>
            <!--aantal_herhalingen-->
            <xsl:apply-templates select="f:dispenseRequest/f:numberOfRepeatsAllowed" mode="#current"/>
            <!-- verbruiksperiode/tijds_duur -->
            <xsl:apply-templates select="f:dispenseRequest/f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PeriodOfUse-Duration']"/>
            <!-- verbruiksperiode/@start_datum_tijd/@value en eind_datum_tijd/@value -->
            <xsl:apply-templates select="f:dispenseRequest/f:validityPeriod" mode="#current"/>
            <!--geannuleerd_indicator-->
            <xsl:if test="f:status/@value eq 'cancelled'">
                <geannuleerd_indicator value="true"/>
            </xsl:if>
            <!--beoogd_verstrekker/zorgaanbieder-->
            <xsl:apply-templates select="f:performer" mode="#current"/>
            <!--afleverlocatie-->
            <xsl:apply-templates
                select="f:dispenseRequest/f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.DispenseLocation']"
                mode="#current"/>
            <!--AanvullendeWensen-->
            <xsl:apply-templates select="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.AdditionalWishes']"
                mode="#current"/>
            <!--financiele_indicatiecode-->
            <xsl:apply-templates select="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.FinancialIndicationCode']"
                mode="#current"/>
            <!--toelichting-->
            <xsl:apply-templates select="f:note" mode="#current"/>
            <!-- relatie medicatieafspraak -->
            <xsl:apply-templates select="f:priorPrescription" mode="#current"/>
            <!-- relatie_contact -->
            <xsl:apply-templates select="f:encounter[f:type/@value eq 'Encounter']" mode="contextContactEpisodeOfCare"/>
            <!-- relatie_zorgepisode -->
            <xsl:apply-templates select="f:extension[@url = $extContextEpisodeOfCare]/f:valueReference" mode="contextContactEpisodeOfCare"/>



            <!-- geannuleerd_indicator niet voor MA -->
            <!--			<xsl:apply-templates select="f:status" mode="#current"/>-->
            <!-- stop_type -->
            <xsl:apply-templates select="f:modifierExtension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-StopType']"
                mode="nl-core-ext-StopType"/>
            <!-- relatie_medicatiegebruik -->
            <xsl:apply-templates select="f:extension[@url = $extRelatedMedicationUse]" mode="#current"/>
            <!-- reden_wijzigen_of_staken -->
            <xsl:apply-templates select="f:reasonCode" mode="#current"/>
            <!-- reden_van_voorschrijven -->
            <xsl:apply-templates select="f:reasonReference" mode="#current"/>



            <!-- gebruiksinstructie -->
            <xsl:call-template name="nl-core-InstructionsForUse"/>
            <!-- aanvullende_informatie -->
            <xsl:apply-templates select="f:extension[@url = $medication-AdditionalInformation]" mode="#current"/>
            <!-- kopie indicator -->
            <xsl:apply-templates select="f:extension[@url = $extCopyIndicator]" mode="ext-CopyIndicator"/>
        </verstrekkingsverzoek>
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:note to Toelichting</xd:desc>
    </xd:doc>
    <xsl:template match="f:note" mode="nl-core-DispenseRequest">
        <toelichting value="{f:text/@value}"/>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.FinancialIndicationCode'] to financiele_indicatiecode</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.FinancialIndicationCode']"
        mode="nl-core-DispenseRequest">
        <financiele_indicatiecode code="{f:valueCodeableConcept/f:extension/f:valueCode/@value}" codeSystem="2.16.840.1.113883.5.1008"
            originalText="{f:valueCodeableConcept/f:text/@value}">
        <xsl:if test="./f:valueCodeableConcept/f:extension[@value eq 'http://hl7.org/fhir/StructureDefinition/iso21090-nullFlavor']">
            <xsl:attribute name="codeSystemName" select="'NullFlavor'"/>
        </xsl:if>
        </financiele_indicatiecode>

        <!--            <xsl:call-template name="CodeableConcept-to-code">
                <xsl:with-param name="in" as="element()" select="." />
                <xsl:with-param name="inElementName" select="'financiele_indicatiecode'"/>
                <xsl:with-param name="originalText" select="'text'"/>
            </xsl:call-template>-->
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.AdditionalWishes'] to aanvullende_wensen</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.AdditionalWishes']"
        mode="nl-core-DispenseRequest">
        <aanvullende_wensen>
            <xsl:call-template name="Coding-to-code">
                <xsl:with-param name="in" as="element()" select="f:valueCodeableConcept/f:coding"/>
            </xsl:call-template>
        </aanvullende_wensen>
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.DispenseLocation']  to afleverlocatie</xd:desc>    </xd:doc>
    <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-DispenseRequest.DispenseLocation']"
        mode="nl-core-DispenseRequest">
        <afleverlocatie value="{nf:convert2NCName(f:valueReference/f:reference/@value)}"/>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:performer to beoogd_verstrekker/zorgaanbieder </xd:desc>
    </xd:doc>
    <xsl:template match="f:performer" mode="nl-core-DispenseRequest">
        <beoogd_verstrekker>
            <zorgaanbieder datatype="reference" value="{nf:convert2NCName(f:reference/@value)}"/>
        </beoogd_verstrekker>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PeriodOfUse-Duration'] to verbruiksperiode/tijdsduur</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PeriodOfUse-Duration']" mode="nl-core-DispenseRequest">
        <verbruiksperiode>
            <xsl:call-template name="Duration-to-hoeveelheid">
                <xsl:with-param name="in" select="f:valueDuration"/>
                <xsl:with-param name="adaElementName">tijdsDuur</xsl:with-param>
            </xsl:call-template>
        </verbruiksperiode>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:validityPeriod to verbruiksperiode/@start_datum_tijd/@value en eind_datum_tijd/@value</xd:desc>
    </xd:doc>
    <xsl:template match="f:validityPeriod" mode="nl-core-DispenseRequest">
        <verbruiksperiode>
            <xsl:call-template name="Period-to-dates">
                <xsl:with-param name="in" select="."/>
                <xsl:with-param name="adaElementNameStart">start_datum_tijd</xsl:with-param>
                <xsl:with-param name="adaElementNameEnd">eind_datum_tijd</xsl:with-param>
            </xsl:call-template>
        </verbruiksperiode>
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:numberOfRepeatsAllowed to aantal_herhalingen</xd:desc>
    </xd:doc>
    <xsl:template match="f:numberOfRepeatsAllowed" mode="nl-core-DispenseRequest">
        <aantal_herhalingen value="{@value}"/>
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:quantity to te_verstrekken_hoeveelheid</xd:desc>
    </xd:doc>
    <xsl:template match="f:quantity" mode="nl-core-DispenseRequest">
        <te_verstrekken_hoeveelheid>
            <aantal value="{f:extension/f:valueQuantity/f:value/@value}"/>
            <eenheid code="{f:extension/f:valueQuantity/f:code/@value}"
                codeSystem="{replace(f:extension/f:valueQuantity/f:system/@value, 'urn:oid:', '')}"
                displayName="{f:unit/@value}"/>
        </te_verstrekken_hoeveelheid>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:requester to auteur/zorgverlener</xd:desc>
    </xd:doc>
    <xsl:template match="f:requester" mode="nl-core-DispenseRequest">
        <auteur>
            <zorgverlener value="{nf:convert2NCName(f:reference/@value)}" datatype="reference"/>
        </auteur>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to resolve priorPrescription.</xd:desc>
    </xd:doc>
    <xd:doc>
        <xd:desc>Template to convert f:priorPrescription to relatie_medicatieafspraak</xd:desc>
    </xd:doc>
    <xsl:template match="f:priorPrescription" mode="nl-core-MedicationAgreement">
        <relatie_medicatieafspraak>
            <xsl:call-template name="Reference-to-identificatie"/>
        </relatie_medicatieafspraak>
    </xsl:template>


    <!--xxxwim:-->
    <xd:doc>
        <xd:desc>Template to convert f:extension medication-AdditionalInformation to aanvullende_informatie element.</xd:desc>
        <xd:param name="adaElementName">Optional alternative ADA element name.</xd:param>
    </xd:doc>
    <xsl:template
        match="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationAgreement.MedicationAgreementAdditionalInformation']"
        mode="nl-core-MedicationAgreement">
        <xsl:param name="adaElementName" tunnel="yes" select="'aanvullende_informatie'"/>
        <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="in" select="f:valueCodeableConcept"/>
            <xsl:with-param name="adaElementName" select="$adaElementName"/>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>Template to convert f:extension/relatedMedicationUse to aanvullende_informatie element.</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = $extRelatedMedicationUse]" mode="nl-core-MedicationAgreement">
        <relatie_medicatiegebruik>
            <identificatie value="{f:valueReference/f:identifier/f:value/@value}"
                root="{f:valueReference/f:identifier/f:system/replace(@value, 'urn:oid:', '')}"/>
        </relatie_medicatiegebruik>
    </xsl:template>



    <!--	<xd:doc>
		<xd:desc>Template to resolve f:modifierExtension ext-Medication-stop-type.</xd:desc>
	</xd:doc>
	<xsl:template match="f:modifierExtension[@url = $extStoptype]" mode="nl-core-MedicationAgreement">
		<xsl:apply-templates select="f:valueCodeableConcept" mode="#current"/>
	</xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:valueCodeableConcept to stoptype.</xd:desc>
    </xd:doc>
    <xsl:template match="f:valueCodeableConcept" mode="nl-core-MedicationAgreement">
        <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="in" select="."/>
            <xsl:with-param name="adaElementName" select="'medicatieafspraak_stop_type'"/>
        </xsl:call-template>
    </xsl:template>
    -->


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:identifier to identificatie</xd:desc>
    </xd:doc>
    <xsl:template match="f:identifier" mode="nl-core-DispenseRequest">
        <xsl:call-template name="Identifier-to-identificatie"/>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:medicationReference to afgesproken_geneesmiddel</xd:desc>
    </xd:doc>
    <xsl:template match="f:medicationReference" mode="nl-core-DispenseRequest">
        <te_verstrekken_geneesmiddel>
            <farmaceutisch_product value="{nf:convert2NCName(f:reference/@value)}" datatype="reference"/>
        </te_verstrekken_geneesmiddel>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:authoredOn to afspraakdatum</xd:desc>
    </xd:doc>
    <xsl:template match="f:authoredOn" mode="nl-core-DispenseRequest">
        <xsl:call-template name="datetime-to-datetime">
            <xsl:with-param name="adaElementName">verstrekkingsverzoek_datum</xsl:with-param>
            <xsl:with-param name="adaDatatype">datetime</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:status to geannuleerd_indicator. Only the FHIR status value 'entered-in-error' is used in this mapping.</xd:desc>
    </xd:doc>
    <xsl:template match="f:status" mode="nl-core-MedicationAgreement">
        <xsl:if test="@value = 'entered-in-error'">
            <geannuleerd_indicator value="true"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:reasonCode to reden_wijzigen_of_staken</xd:desc>
    </xd:doc>
    <xsl:template match="f:reasonCode" mode="nl-core-MedicationAgreement">
        <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="in" select="."/>
            <xsl:with-param name="adaElementName" select="'reden_wijzigen_of_staken'"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:reasonReference to reden_van_voorschrijven</xd:desc>
    </xd:doc>
    <xsl:template match="f:reasonReference" mode="nl-core-MedicationAgreement">
        <xsl:variable name="resource" select="nf:resolveRefInBundle(.)"/>
        <reden_van_voorschrijven>
            <xsl:apply-templates select="$resource/f:*" mode="nl-core-Problem"/>
        </reden_van_voorschrijven>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to convert f:note to toelichting</xd:desc>
    </xd:doc>
    <xsl:template match="f:note" mode="nl-core-MedicationAgreement">
        <toelichting value="{f:text/@value}"/>
    </xsl:template>

</xsl:stylesheet>
