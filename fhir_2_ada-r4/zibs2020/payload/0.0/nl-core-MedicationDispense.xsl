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

<!--
mode = nl-core-MedicationDispense
alle  ZZZNEW templates gaan mee
TODO

-->



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions"
    xmlns:nf="http://www.nictiz.nl/functions" xmlns:util="urn:hl7:utilities" exclude-result-prefixes="#all" version="2.0">

	<xd:doc>
        <xd:desc>Template to convert f:MedicationDispense/f:category/f:coding/f:code/@value = '373784005' to ADA medicatieverstrekking (MVE)</xd:desc>
    </xd:doc>
    <xsl:template match="f:MedicationRequest" mode="nl-core-MedicationDispense">
        <medicatieverstrekking>
            <!-- identificatie -->
            <xsl:apply-templates select="f:identifier" mode="#current"/>
            <!--medicatieverstrekkings_datum_tijd-->
            <xsl:apply-templates select="f:whenHandedOver" mode="#current"/>
            <!--aanschrijf_datum-->
            <xsl:apply-templates
                select="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime" mode="#current"/> 
            <!--verstrekker/zorgaanbieder-->
            <xsl:apply-templates select="f:performer" mode="#current"/>
             <!--verstrekte_hoeveelheid-->
            <xsl:apply-templates select="f:dispenseRequest/f:quantity[f:extension/@url = 'http://hl7.org/fhir/StructureDefinition/iso21090-PQ-translation']" mode="#current"/>
            <!-- verstrekt_geneesmiddel -->
            <xsl:apply-templates select="f:medicationReference" mode="#current"/>
            <!-- verbruiksduur -->
            <xsl:apply-templates select="f:daysSupply" mode="#current"/>
            <!--afleverlocatie-->
            <xsl:apply-templates select="f:destination/f:reference" mode="#current"/>
            <!--distributievorm-->
            <xsl:apply-templates select="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.DistributionForm']" mode="#current"/>
            <!-- medicatieverstrekking_aanvullende_informatie -->
            <xsl:apply-templates select="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation']" mode="#current"/>
            <!-- relatie_verstrekkingsverzoek -->
            <xsl:apply-templates select="f:authorizingPrescription" mode="#current"/>
            <relatie_verstrekkingsverzoek comment="" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.4.349">
                <identificatie value="MBH_920_QA1_VV"
                    root="2.16.840.1.113883.2.4.3.11.999.77.52711000146108.1"
                    conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.4.564"/>
            </relatie_verstrekkingsverzoek>

            <authorizingPrescription>
                <type value="MedicationRequest"/>
                <identifier>
                    <system value="urn:oid:2.16.840.1.113883.2.4.3.11.999.77.52711000146108.1"/>
                    <value value="MBH_920_QA1_VV"/>
                </identifier>
                <display value="relatie naar verstrekkingsverzoek met identificatie: MBH_920_QA1_VV || 2.16.840.1.113883.2.4.3.11.999.77.52711000146108.1"/>
            </authorizingPrescription>
            <!-- toelichting -->
            <xsl:apply-templates select="f:note" mode="nl-core-Note"/>
        </medicatieverstrekking>
    </xsl:template>


    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to convert f:authorizingPrescription to relatie_verstrekkingsverzoek</xd:desc>
    </xd:doc>
    <xsl:template match="f:authorizingPrescription" mode="nl-core-MedicationDispense">
        <relatie_verstrekkingsverzoek>
            <identificatie value="{f:identifier/f:value/@value}"
                root="{replace(f:identifier/f:system/@value, 'urn:oid:', '')}"/>
        </relatie_verstrekkingsverzoek>
    </xsl:template>

    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation'] to aanvullende_informatie</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.MedicationDispenseAdditionalInformation']" mode="nl-core-MedicationDispense">
        <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="adaElementName" select="'medicatieverstrekking_aanvullende_informatie'">
            </xsl:with-param></xsl:call-template>
    </xsl:template>

    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.DistributionForm' to distributievorm</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.DistributionForm']" mode="nl-core-MedicationDispense">
        <xsl:call-template name="CodeableConcept-to-code">
            <xsl:with-param name="adaElementName" select="'distributievorm'">
            </xsl:with-param></xsl:call-template>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:destination/f:reference to </xd:desc>    </xd:doc>
    <xsl:template match="f:destination/f:reference" mode="nl-core-DispenseRequest">
        <afleverlocatie value="{nf:convert2NCName(./@value)}"/>
    </xsl:template>

    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to f:daysSupply convert to verbruiksduur</xd:desc>
    </xd:doc>
    <xsl:template match="f:daysSupply/f:value/@value" mode="nl-core-MedicationDispense">
        <verbruiksduur value="{f:value/@value}" unit="{f:unit/@value}"/>
    </xsl:template>  

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:medicationReference to verstrekt_geneesmiddel</xd:desc>
    </xd:doc>
    <xsl:template match="f:medicationReference" mode="nl-core-DispenseRequest">
        <verstrekt_geneesmiddel>
            <farmaceutisch_product value="{nf:convert2NCName(f:reference/@value)}" datatype="reference"/>
        </verstrekt_geneesmiddel>
    </xsl:template>

    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:quantity to verstrekte_hoeveelheid</xd:desc>
    </xd:doc>
    <xsl:template match="f:quantity[f:extension/@url = 'http://hl7.org/fhir/StructureDefinition/iso21090-PQ-translation']" mode="nl-core-DispenseRequest">
        <verstrekte_hoeveelheid>
            <aantal value="{f:extension/f:valueQuantity/f:value/@value}"/>
            <eenheid code="{f:extension/f:valueQuantity/f:code/@value}"
                codeSystem="{replace(f:extension/f:valueQuantity/f:system/@value, 'urn:oid:', '')}"
                displayName="{f:unit/@value}"/>
        </verstrekte_hoeveelheid>
    </xsl:template>


    <xd:doc>
        <!--ZZZNEW-->
        <xd:desc>Template to convert f:performer to verstrekker/zorgaanbieder </xd:desc>
    </xd:doc>
    <xsl:template match="f:performer" mode="nl-core-DispenseRequest">
        <verstrekker>
            <zorgaanbieder datatype="reference" value="{nf:convert2NCName(f:reference/@value)}"/>
        </verstrekker>
    </xsl:template>

    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to convert f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime to aanschrijf_datum</xd:desc>
    </xd:doc>
    <xsl:template match="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-MedicationDispense.RequestDate']/f:valueDateTime"
        mode="nl-core-MedicationDispense">
        <aanschrijf_datum>
            <xsl:attribute name="value">
                <xsl:call-template name="format2ADADate">
                    <xsl:with-param name="dateTime" select="./@value"> </xsl:with-param>
                </xsl:call-template>
            </xsl:attribute>
        </aanschrijf_datum>
    </xsl:template>


    <xd:doc><!--ZZZNEW-->
        <xd:desc>Template to convert f:whenHandedOver to medicatieverstrekkings_datum_tijd</xd:desc>
    </xd:doc>
    <xsl:template match="f:whenHandedOver" mode="nl-core-MedicationDispense">
        <medicatieverstrekkings_datum_tijd value="{./@value}"/>
    </xsl:template>

    <xd:doc><!-- ZZZNEW -->
        <xd:desc>Template to resolve priorPrescription.</xd:desc>
    </xd:doc>
    <xd:doc>
        <xd:desc>Template to convert f:authorizingPrescription to relatie_medicatieafspraak</xd:desc>
    </xd:doc>
    <xsl:template match="f:priorPrescription" mode="XXXXXXXXXXXXXXX">
        <relatie_medicatieafspraak>
            <xsl:call-template name="Reference-to-identificatie"/>
        </relatie_medicatieafspraak>
    </xsl:template>
    <xd:doc><!-- ZZZNEW -->
        <xd:desc>Template to convert f:identifier to identificatie</xd:desc>
    </xd:doc>
    <xsl:template match="f:identifier" mode="nl-core-MedicationDispense">
        <xsl:call-template name="Identifier-to-identificatie"/>
    </xsl:template>
</xsl:stylesheet>
