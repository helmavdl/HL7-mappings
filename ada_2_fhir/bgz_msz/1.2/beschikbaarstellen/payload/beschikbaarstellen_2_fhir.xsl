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

<xsl:stylesheet exclude-result-prefixes="#all" xmlns:nf="http://www.nictiz.nl/functions" xmlns:f="http://hl7.org/fhir" xmlns:util="urn:hl7:utilities" xmlns="http://hl7.org/fhir" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- import because we want to be able to override the param for macAddress for UUID generation and the param for referById -->
    <xsl:import href="../../../../zibs2017/payload/package-2.2.x.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Author:</xd:b> Nictiz</xd:p>
            <!--<xd:p><xd:b>Purpose:</xd:b> This XSL was created to facilitate mapping from ADA to HL7 FHIR STU3 profiles for BgZ.</xd:p>-->
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>
    <!-- If the desired output is to be a Bundle, then a self link string of type url is required. 
         See: https://www.hl7.org/fhir/stu3/search.html#conformance -->
    <xsl:param name="bundleSelfLink" as="xs:string?"/>
    <!-- This is a required parameter and matches the [base] of a FHIR server. Expects *not* to end in / so we can make fullUrls like ${baseUrl}/Observation/[id] -->
    <!--<xsl:param name="baseUrl" as="xs:string"/>-->
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>
    <!-- parameter to determine whether to refer by resource/id -->
    <!-- should be false when there is no FHIR server available to retrieve the resources -->
    <xsl:param name="referById" as="xs:boolean" select="true()"/>
    <!-- if false produces a Bundle. if true produces separate resources -->
    <xsl:param name="separateResources" as="xs:boolean" select="$referById"/>
    
    <!-- OID separated list of oids like 2.16.840.1.113883.2.4.6.3 (bsn) to mask in output -->
    <xsl:param name="mask-ids" select="(:$oidBurgerservicenummer:)''" as="xs:string"/>
    
    <xsl:variable name="usecase">bgz-msz</xsl:variable>
    
    <xd:doc>
        <xd:desc>Start conversion. This conversion tries to account for all zibs in BgZ MSZ "beschikbaarstellen" in one go. Either build a FHIR Bundle of type searchset per zib, or build individual files.</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:variable name="commonEntries" as="element(f:entry)*">
            <xsl:choose>
                <xsl:when test="bundle/*/local-name() = 'advance_directive'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $vaccinations/f:entry, $labObservations/f:entry"/>
                </xsl:when>
                <xsl:when test="bundle/*/local-name() = 'laboratory_test_result'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $advanceDirectives/f:entry, $vaccinations/f:entry"/>
                </xsl:when>
                <xsl:when test="bundle/*/local-name() = 'medical_device'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $advanceDirectives/f:entry, $vaccinations/f:entry, $labObservations/f:entry"/>
                </xsl:when>
                <xsl:when test="bundle/*/local-name() = 'problem'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $advanceDirectives/f:entry, $vaccinations/f:entry, $labObservations/f:entry"/>
                </xsl:when>
                <xsl:when test="bundle/*/local-name() = 'procedure'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $advanceDirectives/f:entry, $vaccinations/f:entry, $labObservations/f:entry"/>
                </xsl:when>
                <xsl:when test="bundle/*/local-name() = 'vaccination'">
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $advanceDirectives/f:entry, $labObservations/f:entry"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$patients/f:entry, $practitioners/f:entry, $organizations/f:entry, $practitionerRoles/f:entry, $relatedPersons/f:entry, $problems/f:entry, $procedures/f:entry, $procedureRequests/f:entry, $medicalDevices/f:entry, $medicalDeviceProducts/f:entry, $advanceDirectives/f:entry, $vaccinations/f:entry, $labObservations/f:entry"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="bouwstenen" as="element(f:entry)*">
            <xsl:for-each select="bundle/*">
                <xsl:variable name="adaPatient" select="hcimroot/subject/patient/patient"/>
                <xsl:variable name="patientIdentifier" select="$adaPatient/patient_identification_number/@value"/>
                <xsl:variable name="patientName">
                    <xsl:choose>
                        <xsl:when test="$patientIdentifier = 999999151">
                            <xsl:value-of select="'patA'"/>
                        </xsl:when>
                        <xsl:when test="$patientIdentifier = 999900092">
                            <xsl:value-of select="'patB'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'patX'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!--Zibs that result in only a single resource, or  resources that have no special conditions-->
                <xsl:if test="local-name() = ('advance_directive', 'alcohol_use', 'alert', 'allergy_intolerance', 'blood_pressure', 'body_height', 'body_weight', 'drug_use', 'encounter', 'functional_or_mental_status', 'living_situation', 'nutrition_advice', 'payer', 'problem', 'tobacco_use', 'treatment_directive')">
                    <entry xmlns="http://hl7.org/fhir">
                        <xsl:if test="local-name() = 'advance_directive'">
                            <fullUrl value="{concat('zib-AdvanceDirective-', $usecase, '-', $patientName, '-advdir', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-AdvanceDirective-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-advdir', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'alcohol_use'">
                            <fullUrl value="{concat('zib-AlcoholUse-', $usecase, '-', $patientName, '-alcohol', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-AlcoholUse-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-alcohol', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'alert'">
                            <fullUrl value="{concat('zib-Alert-', $usecase, '-', $patientName, '-alert', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-Alert-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-alert', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'allergy_intolerance'">
                            <fullUrl value="{concat('zib-AllergyIntolerance-', $usecase, '-', $patientName, '-allergy', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-AllergyIntolerance-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-allergy', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'blood_pressure'">
                            <fullUrl value="{concat('zib-BloodPressure-', $usecase, '-', $patientName, '-bloodpressure', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-BloodPressure-3.0">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-bloodpressure', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'body_height'">
                            <fullUrl value="{concat('zib-BodyHeight-', $usecase, '-', $patientName, '-bodyheight', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-BodyHeight-2.x">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-bodyheight', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'body_weight'">
                            <fullUrl value="{concat('zib-BodyWeight-', $usecase, '-', $patientName, '-bodyweight', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-BodyWeight-2.x">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-bodyweight', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'drug_use'">
                            <fullUrl value="{concat('zib-DrugUse-', $usecase, '-', $patientName, '-druguse', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-DrugUse-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-druguse', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'encounter'">
                            <fullUrl value="{concat('zib-Encounter-', $usecase, '-', $patientName, '-encounter', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-Encounter-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-encounter', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'functional_or_mental_status'">
                            <fullUrl value="{concat('zib-FunctionalOrMentalStatus-', $usecase, '-', $patientName, '-funcment', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-FunctionalOrMentalStatus-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-funcment', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'living_situation'">
                            <fullUrl value="{concat('zib-LivingSituation-', $usecase, '-', $patientName, '-living', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-LivingSituation-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-living', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'nutrition_advice'">
                            <fullUrl value="{concat('zib-NutritionAdvice-', $usecase, '-', $patientName, '-nutrition', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-NutritionAdvice-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-nutrition', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'payer'">
                            <fullUrl value="{concat('zib-Payer-', $usecase, '-', $patientName, '-payer', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-Payer-2.0">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-payer', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'problem'">
                            <fullUrl value="{concat('zib-Problem-', $usecase, '-', $patientName, '-problem', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-Problem-3.0">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-problem', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'tobacco_use'">
                            <fullUrl value="{concat('zib-TobaccoUse-', $usecase, '-', $patientName, '-tobacco', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-TobaccoUse-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-tobacco', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <xsl:if test="local-name() = 'treatment_directive'">
                            <fullUrl value="{concat('zib-TreatmentDirective-', $usecase, '-', $patientName, '-treatmentdir', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-TreatmentDirective-2.2">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-treatmentdir', position())"/>
                                </xsl:call-template>
                            </resource>
                        </xsl:if>
                        <search>
                            <mode value="match"/>
                        </search>
                    </entry>
                </xsl:if>
                
                <!--Additional resources or resources with special conditions-->                
                <xsl:if test="local-name() = 'laboratory_test_result'">
                    <xsl:if test="panel_or_battery[@code]">
                        <entry>
                            <fullUrl value="{concat('zib-LaboratoryTestResult-PanelObservation-', $usecase, '-', $patientName, '-labresult', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-LaboratoryTestResult-PanelObservation-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-labresult', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:if>
                    
                    <xsl:for-each select="laboratory_test">
                        <entry>
                            <fullUrl value="{concat('zib-LaboratoryTestResult-Observation-', $usecase, '-', $patientName, '-labresult', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-LaboratoryTestResult-Observation-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-labresult', string(count(../preceding-sibling::laboratory_test_result) + 1), '-', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:for-each>
                    
                    <xsl:for-each select="specimen">
                        <entry>
                            <fullUrl value="{concat('zib-LaboratoryTestResult-Specimen-', $usecase, '-', $patientName, '-labresult', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-LaboratoryTestResult-Specimen-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-labresult', string(count(../preceding-sibling::laboratory_test_result) + 1), '-', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:for-each> 
                </xsl:if>
                
                <xsl:if test="local-name() = 'medical_device'">
                    <entry>
                        <fullUrl value="{concat('zib-MedicalDevice-', $usecase, '-', $patientName, '-medDevice', position())}"/>
                        <resource>
                            <xsl:call-template name="zib-MedicalDevice-2.2">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                <xsl:with-param name="logicalId" select="concat($patientName, '-medDevice', position())"/>
                            </xsl:call-template>
                        </resource>
                        <search>
                            <mode value="match"/>
                        </search>
                    </entry>
                    
                    <entry>
                        <fullUrl value="{concat('zib-MedicalDeviceProduct-', $usecase, '-', $patientName, '-medDevice', position())}"/>
                        <resource>
                            <xsl:call-template name="zib-MedicalDeviceProduct-2.2">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                <xsl:with-param name="logicalId" select="concat($patientName, '-medDevice', position())"/>
                            </xsl:call-template>
                        </resource>
                        <search>
                            <mode value="match"/>
                        </search>
                    </entry>
                </xsl:if>
                
                <xsl:if test="local-name() = 'procedure'">
                    <xsl:if test="nf:isPast((verrichting_start_datum | procedure_start_date)/@value)">
                        <entry>
                            <fullUrl value="{concat('zib-Procedure-', $usecase, '-', $patientName, '-procedure', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-Procedure-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-procedure', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:if>
                    <xsl:if test="nf:isFuture((verrichting_start_datum | procedure_start_date)/@value) or aanvrager | requester">
                        <entry>
                            <fullUrl value="{concat('zib-ProcedureRequest-', $usecase, '-', $patientName, '-procedure', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-ProcedureRequest-2.1">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-procedure', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:if>
                </xsl:if>
                
                <xsl:if test="local-name() = 'vaccination'">
                    <entry>
                        <fullUrl value="{concat('zib-Vaccination-', $usecase, '-', $patientName, '-vaccin', position())}"/>
                        <resource>
                            <xsl:call-template name="zib-Vaccination-2.1">
                                <xsl:with-param name="in" select="."/>
                                <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                <xsl:with-param name="logicalId" select="concat($patientName, '-vaccin', position())"/>
                            </xsl:call-template>
                        </resource>
                        <search>
                            <mode value="match"/>
                        </search>
                    </entry>
                    
                    <xsl:if test="(gewenste_datum_hervaccinatie | prefered_date_for_revaccination)[@value]">
                        <entry>
                            <fullUrl value="{concat('zib-VaccinationRecommendation-', $usecase, '-', $patientName, '-vaccin', position())}"/>
                            <resource>
                                <xsl:call-template name="zib-VaccinationRecommendation-2.0">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="adaPatient" select="$adaPatient" as="element()"/>
                                    <xsl:with-param name="logicalId" select="concat($patientName, '-vaccin', position())"/>
                                </xsl:call-template>
                            </resource>
                            <search>
                                <mode value="match"/>
                            </search>
                        </entry>
                    </xsl:if>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="entries" as="element(f:entry)*">
            <xsl:copy-of select="$bouwstenen"/>
            <xsl:copy-of select="$commonEntries"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$separateResources">
                <xsl:for-each select="$entries">
                    <xsl:result-document href="../fhir_instance_resources/{f:resource/f:*/f:id/@value}.xml">
                        <xsl:copy-of select="f:resource/f:*"/>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="../fhir_instance_bundles/{tokenize(base-uri(.), '/')[last()]}">
                    <xsl:processing-instruction name="xml-model">href="http://hl7.org/fhir/STU3/bundle.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                    <Bundle xsl:exclude-result-prefixes="#all" xmlns="http://hl7.org/fhir" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://hl7.org/fhir http://hl7.org/fhir/STU3/fhir-all.xsd">
                        <id value="{nf:get-uuid(*[1])}"/>
                        <type value="searchset"/>
                        <total value="{count($bouwstenen)}"/>
                        <xsl:choose>
                            <xsl:when test="$bundleSelfLink[not(. = '')]">
                                <link>
                                    <relation value="self"/>
                                    <url value="{$bundleSelfLink}"/>
                                </link>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="util:logMessage">
                                    <xsl:with-param name="level" select="$logWARN"/>
                                    <xsl:with-param name="msg">Parameter bundleSelfLink is empty, but server SHALL return the parameters that were actually used to process the search.</xsl:with-param>
                                    <xsl:with-param name="terminate" select="false()"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="$entries"/>
                    </Bundle>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>