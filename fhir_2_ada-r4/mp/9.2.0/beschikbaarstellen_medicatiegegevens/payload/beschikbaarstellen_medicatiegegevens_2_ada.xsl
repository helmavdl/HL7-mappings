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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://hl7.org/fhir"
	xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" exclude-result-prefixes="#all" version="2.0">

	<!-- TODO currently the 907 version, we should upgrade to 920 -->
	<xsl:import href="../../../../../fhir_2_ada/mp/fhir_2_ada_mp_include.xsl"/>
	<xsl:import href="../../../../zibs2020/payload/zib_latest_package.xsl"/>
	<xsl:output indent="yes"/>


	<xd:doc>
		<xd:desc> replace non permitted chars in an xml ID (xs:ID) [\i-[:]][\c-[:]]* in
			targets (bouwstenen element) zorgaanbieder@id, zorgverlener@id, farmaceutisch_product@id.
			And the corresponding references to them zorgaanbieder@value, zorgverlener@value, farmaceutisch_product@value
		</xd:desc>
		<xd:param name="stringIn"/>
	</xd:doc>
	<xsl:function name="nf:convert2NCName">
		<xsl:param name="stringIn"/>
		<xsl:value-of select="replace(replace($stringIn, '^[^\c]|^\d', '_'), ':', '-')"/>
	</xsl:function>

	<xd:doc>
		<xd:desc>Base template for the main interaction.</xd:desc>
	</xd:doc>
	<xsl:template match="/">

		<!--xxxwim bouwstenen toevoegen  -->
		<xsl:variable name="bouwstenen">
			
			<xsl:for-each select="f:Bundle/f:entry/f:resource/f:Medication">
				<farmaceutisch_product id="{nf:convert2NCName(./../../f:fullUrl/@value)}" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.4.260">
					<xsl:for-each select="./f:code/f:coding">
						<product_code codeSystem="{replace(./f:system/@value, 'urn:oid:', '')}" displayName="./display@value" codeSystemName="G-Standaard PRK" conceptId="2.16.840.1.113883.2.4.3.11.60.20.77.2.4.261"/>
					</xsl:for-each>
				</farmaceutisch_product>
			</xsl:for-each>

			<!--xxxwim: TODO    		
    		<xsl:for-each select="ancestor::f:Bundle/f:entry/f:fullUrl/f:....">
    		| ancestor::f:Bundle/f:entry/esource/PractitionerRole/specialty
    		</xsl:for-each>-->

			<xsl:for-each select="f:Bundle/f:entry/f:resource/f:PractitionerRole/f:practitioner/f:reference">
				<!-- requester verwijst naar PractitionerRole, zoek het doel (Practitioner) bij deze referentie (practitioner/reference) om de zorgverlener bouwsteen te kunnen maken-->
				<xsl:variable name="referenceAtValue" select="string(@value)"/>
				<xsl:variable name="PractitioneridentifierAtValue" select="//f:entry/f:fullUrl[./@value eq $referenceAtValue]/../f:resource/f:Practitioner/f:identifier/f:value/@value"/>
				<xsl:variable name="PractitionerRole" select="./../.."/>

				<!-- xxxwim remove: -->
				<!--				<xsl:message>
	<xsl:value-of select="name($PractitionerRole)"/>
</xsl:message>-->

				<zorgverlener id="{nf:convert2NCName($PractitioneridentifierAtValue)}">
					<zorgverlener_identificatienummer value="{$PractitioneridentifierAtValue}"
						root="{replace(//f:entry/f:fullUrl[./@value eq $referenceAtValue]/../f:resource/f:Practitioner/f:id/@value, '-.*', '')   }"/>
					<naamgegevens comment="">
						<voornamen value=""/>
						<geslachtsnaam comment="">
							<voorvoegsels value=""/>
							<achternaam value=""/>
						</geslachtsnaam>
					</naamgegevens>
					<specialisme codeSystem="{replace($PractitionerRole/f:specialty/f:coding/f:system/@value, 'urn:oid:', '')}" codeSystemVersion="{$PractitionerRole/f:specialty/f:coding/f:version/@value}"
						displayName="{$PractitionerRole/f:specialty/f:coding/f:display/@value}" code="{$PractitionerRole/f:specialty/f:coding/f:code/@value}"/>
					<zorgaanbieder>
						<!-- de referentie naar bouwsteen zorgaanbieder-->
						<zorgaanbieder datatype="reference" value="{nf:convert2NCName($PractitionerRole/f:organization/f:reference/@value)}"/>
					</zorgaanbieder>
				</zorgverlener>
			</xsl:for-each>
			
			

			<xsl:for-each select="f:Bundle/f:entry/f:resource/f:Organization">
				<xsl:variable name="entryFullURrlAtValue" select="./../../f:fullUrl/@value"/>
				<!--				<xsl:variable name="PractitioneridentifierAtValue" select="//f:entry/f:fullUrl[./@value eq $referenceAtValue]/../f:resource/f:Practitioner/f:identifier/f:value/@value"/>
				<xsl:variable name="PractitionerRole" select="./../.."/>-->
				<!-- xxxwim remove: -->
				<xsl:message>
					<xsl:value-of select="$entryFullURrlAtValue"/>
				</xsl:message>
				<zorgaanbieder id="{nf:convert2NCName($entryFullURrlAtValue)}">
					<!--{nf:compareCI('012:3ccc')}-->
					<zorgaanbieder_identificatienummer value="{./f:identifier/f:value/@value}" root="2.16.528.1.1007.3.3"/>
					<organisatie_naam value="{./f:name/@value}"/>
					<adresgegevens comment="">
						<straat value="{./f:address/f:line/f:extension[@url eq 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName']/f:valueString/@value}"/>
						<huisnummer value="{./f:address/f:line/f:extension[@url eq 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber']/f:valueString/@value}"/>
						<postcode value="{./f:address/f:postalCode/@value}"/>
						<woonplaats value="{./f:address/f:city/@value}"/>

						<adres_soort value="" code="{./f:address/f:extension[@url eq 'http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType']/f:valueCodeableConcept/f:coding/f:code/@value}"
							codeSystem="2.16.840.1.113883.5.1119" displayName="Werkadres"/>
					</adresgegevens>
				</zorgaanbieder>
			</xsl:for-each>

		</xsl:variable>


		<adaxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="../ada_schemas/ada_beschikbaarstellen_medicatiegegevens.xsd">
			<meta status="new" created-by="generated" last-update-by="generated" creation-date="{current-dateTime()}" last-update-date="{current-dateTime()}"/>
			<data>
				<beschikbaarstellen_medicatiegegevens app="mp-mp920" shortName="beschikbaarstellen_medicatiegegevens" formName="medicatiegegevens" transactionRef="2.16.840.1.113883.2.4.3.11.60.20.77.4.172"
					transactionEffectiveDate="2021-04-02T09:33:39" prefix="mp-" language="nl-NL">
					<xsl:attribute name="title">Generated from HL7 FHIR medicatiegegevens 9.0.7 xml</xsl:attribute>
					<xsl:attribute name="id">DUMMY</xsl:attribute>

					<xsl:choose>
						<xsl:when
							test="count(f:Bundle/f:entry/f:resource/f:Patient) ge 2 or count(distinct-values(f:Bundle/f:entry/f:resource/(f:MedicationRequest | f:MedicationDispense | f:MedicationStatement)/f:subject/f:reference/@value)) ge 2">
							<xsl:message terminate="yes">Multiple Patients and/or subject references found. Please check.</xsl:message>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="f:Bundle/f:entry/f:resource/f:Patient" mode="nl-core-Patient"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each-group select="f:Bundle/f:entry/f:resource/(f:MedicationRequest | f:MedicationDispense | f:MedicationStatement)"
						group-by="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PharmaceuticalTreatment.Identifier']/f:valueIdentifier/concat(f:system/@value, f:value/@value)">
						<medicamenteuze_behandeling>
							<identificatie>
								<xsl:attribute name="value" select="f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PharmaceuticalTreatment.Identifier']/f:valueIdentifier/f:value/@value"/>
								<xsl:attribute name="root" select="local:getOid(f:extension[@url = 'http://nictiz.nl/fhir/StructureDefinition/ext-PharmaceuticalTreatment.Identifier']/f:valueIdentifier/f:system/@value)"/>
							</identificatie>
							<!-- medicatieafspraak -->
							<xsl:apply-templates select="current-group()[self::f:MedicationRequest/f:category/f:coding/f:code/@value = '16076005']" mode="nl-core-MedicationAgreement"/>
							<!-- verstrekkingsverzoek -->
							<!--                            <xsl:apply-templates select="current-group()[self::f:MedicationRequest/f:category/f:coding/f:code/@value='52711000146108']" mode="zib-DispenseRequest-2.2"/>-->
							<!-- toedieningsafspraak -->
							<xsl:apply-templates select="current-group()[self::f:MedicationDispense/f:category/f:coding/f:code/@value = '422037009']" mode="nl-core-AdministrationAgreement"/>
							<!-- verstrekking -->
							<!--                            <xsl:apply-templates select="current-group()[self::f:MedicationDispense/f:category/f:coding/f:code/@value='373784005']" mode="zib-Dispense-2.2"/>-->
							<!-- medicatie_gebruik -->
							<!--                            <xsl:apply-templates select="current-group()[self::f:MedicationStatement/f:category/f:coding/f:code/@value='6']" mode="zib-MedicationUse-2.2"/>-->
						</medicamenteuze_behandeling>
					</xsl:for-each-group>
					<!--xxxwim bouwstenen -->
					<bouwstenen>
						<xsl:for-each select="$bouwstenen">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</bouwstenen>

				</beschikbaarstellen_medicatiegegevens>
			</data>
		</adaxml>
	</xsl:template>

</xsl:stylesheet>
