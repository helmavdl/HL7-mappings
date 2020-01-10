<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (c) Nictiz

This program is free software; you can redistribute it and/or modify it under the terms of the
GNU Lesser General Public License as published by the Free Software Foundation; either version
2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:hl7="urn:hl7-org:v3" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:local="urn:fhir:stu3:functions" xmlns:nf="http://www.nictiz.nl/functions" xmlns:nff="http://www.nictiz.nl/fhir-functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:import href="../../hl7/hl7_2_ada_hl7_include.xsl"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:strip-space elements="*"/>
    <xsl:param name="referById" as="xs:boolean" select="false()"/>
    <!-- pass an appropriate macAddress to ensure uniqueness of the UUID -->
    <!-- 02-00-00-00-00-00 may not be used in a production situation -->
    <xsl:param name="macAddress">02-00-00-00-00-00</xsl:param>

    <xsl:param name="language" as="xs:string?">nl-NL</xsl:param>
    <!-- Optional. Used to find conceptId attributes values for elements. Should contain the whole ADA schema -->
    <xsl:param name="schema" as="node()*"/>

    <xsl:variable name="elmContactPerson">
        <xsl:choose>
            <xsl:when test="$language = 'en-US'">contact_person</xsl:when>
            <xsl:otherwise>contactpersoon</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="elmHealthcareProvider">
        <xsl:choose>
            <xsl:when test="$language = 'en-US'">healthcare_provider</xsl:when>
            <xsl:otherwise>zorgaanbieder</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="elmHealthProfessional">
        <xsl:choose>
            <xsl:when test="$language = 'en-US'">health_professional</xsl:when>
            <xsl:otherwise>zorgverlener</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="elmPatient">
        <xsl:choose>
            <xsl:when test="$language = 'en-US'">patient</xsl:when>
            <xsl:otherwise>patient</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- variable which contains all information needed to create ada problem (reference) for transaction beschikbaarstellen_icavertaling -->
    <xsl:variable name="patients" as="element()*">
        <xsl:variable name="schema" select="$schema"/>
        <xsl:variable name="schemaFragment"/>
        <!-- each condition has patient, but those must be identical according to standard, 
                let's assume that's true and only evaluate the first patient we find -->
        <xsl:variable name="patient" select="(//hl7:patient)[1]"/>

        <patients>
            <xsl:for-each select="$patient">
                <patient_information>
                    <!-- the actual ada patient -->
                    <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.1_20180601000000">
                        <xsl:with-param name="schema" select="$schema"/>
                        <xsl:with-param name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schema, $elmPatient))"/>
                    </xsl:call-template>
                </patient_information>
            </xsl:for-each>
        </patients>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Handle a HL7 stuff to create an ada zibRoot HCIM</xd:desc>
        <xd:param name="schemaFragment">Optional for generating ada conceptId's. XSD Schema complexType for ada parent of zibroot</xd:param>
    </xd:doc>
    <xsl:template name="HL7element2Zibroot" match="hl7:*" mode="HL7element2Zibroot">
        <xsl:param name="schemaFragment" as="element(xs:complexType)?"/>
        <!-- multi language support for ada element names -->
        <xsl:variable name="elmZibroot">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">hcimroot</xsl:when>
                <xsl:otherwise>zibroot</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootIdentification">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">identification_number</xsl:when>
                <xsl:otherwise>identificatienummer</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootInformationSource">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">information_source</xsl:when>
                <xsl:otherwise>informatiebron</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootInformationSourcePatient">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">patient_as_information_source</xsl:when>
                <xsl:otherwise>patient_als_bron</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootInformationSourceContact">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">related_person_as_information_source</xsl:when>
                <xsl:otherwise>betrokkene_als_bron</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootAuthor">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">author</xsl:when>
                <xsl:otherwise>auteur</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootAuthorPatient">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">patient_as_author</xsl:when>
                <xsl:otherwise>patient_als_auteur</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootAuthorHealthProfessional">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">health_professional_as_author</xsl:when>
                <xsl:otherwise>zorgverlener_als_auteur</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootSubject">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">subject</xsl:when>
                <xsl:otherwise>onderwerp</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmZibrootDateTime">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">date_time</xsl:when>
                <xsl:otherwise>datum_tijd</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$elmZibroot}">
            <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibroot))"/>
            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>

            <!-- identification number -->
            <xsl:for-each select="hl7:id">
                <xsl:call-template name="handleII">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootIdentification)))"/>
                    <xsl:with-param name="elemName" select="$elmZibrootIdentification"/>
                </xsl:call-template>
            </xsl:for-each>

            <!-- informant -->
            <!-- in theory there may be more than one informant, but we want maximum one, we take the first one -->
            <xsl:for-each select="hl7:informant[1]">
                <xsl:element name="{$elmZibrootInformationSource}">
                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootInformationSource))"/>
                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>

                    <xsl:choose>
                        <xsl:when test="hl7:patient">
                            <xsl:element name="{$elmZibrootInformationSourcePatient}">
                                <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootInformationSourcePatient))"/>
                                <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                <xsl:element name="{$elmPatient}">
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmPatient)))"/>
                                    <xsl:attribute name="value" select="$patients/patient_information/*[local-name() = $elmPatient]/@id"/>
                                    <xsl:attribute name="datatype">reference</xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!-- zorgverlener can be in hl7:assignedPerson or hl7:assignedEntity -->
                        <xsl:when test="hl7:assignedPerson | hl7:assignedEntity">
                            <xsl:for-each select="hl7:assignedPerson | hl7:assignedEntity">
                                <xsl:variable name="ref" select="generate-id(.)"/>
                                <!-- create the element for the reference -->
                                <xsl:element name="{$elmHealthProfessional}">
                                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthProfessional))"/>
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <!-- create the element for the reference -->
                                    <xsl:element name="{$elmHealthProfessional}">
                                        <xsl:attribute name="value" select="$ref"/>
                                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthProfessional)))"/>
                                        <xsl:attribute name="datatype">reference</xsl:attribute>
                                    </xsl:element>
                                    <!-- output the actual healthcare professional here as well, we will move it to appropriate location in ada xml later -->
                                    <xsl:call-template name="HandleHealthProfessional">
                                        <xsl:with-param name="schema" select="$schema"/>
                                        <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="hl7:responsibleParty">
                            <xsl:for-each select="hl7:responsibleParty">
                                <xsl:variable name="ref" select="generate-id(.)"/>
                                <!-- create the element for the reference -->
                                <xsl:element name="{$elmZibrootInformationSourceContact}">
                                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootInformationSourceContact))"/>
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <!-- create the element for the reference -->
                                    <xsl:element name="{$elmContactPerson}">
                                        <xsl:attribute name="value" select="$ref"/>
                                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmContactPerson)))"/>
                                        <xsl:attribute name="datatype">reference</xsl:attribute>
                                    </xsl:element>
                                    <!-- output the actual contactpoint here as well, we will move it to apropriate location in ada xml later -->
                                    <xsl:call-template name="HandleContactPerson">
                                        <xsl:with-param name="adaId" select="$ref"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>

            <!-- author -->
            <!-- may be only one author in zibroot, could theoretically encounter both author and participant in HL7 -->
            <xsl:variable name="hl7Author">
                <xsl:choose>
                    <xsl:when test="hl7:author">
                        <xsl:sequence select="hl7:author"/>
                    </xsl:when>
                    <xsl:when test="hl7:participant[@typeCode = 'RESP']">
                        <xsl:sequence select="hl7:participant[@typeCode = 'RESP']"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="$hl7Author/*">
                <xsl:element name="{$elmZibrootAuthor}">
                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootAuthor))"/>
                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>

                    <xsl:choose>
                        <xsl:when test="hl7:patient">
                            <xsl:element name="{$elmZibrootAuthorPatient}">
                                <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootAuthorPatient))"/>
                                <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                <xsl:element name="{$elmPatient}">
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmPatient)))"/>
                                    <xsl:attribute name="value" select="$patients/patient_information/*[local-name() = $elmPatient]/@id"/>
                                    <xsl:attribute name="datatype">reference</xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:when>
                        <!-- healthprofessional as author -->
                        <xsl:when test="hl7:assignedPerson | hl7:assignedAuthor | hl7:participantRole">
                            <xsl:for-each select="hl7:assignedPerson | hl7:assignedAuthor | hl7:participantRole">
                                <xsl:element name="{$elmZibrootAuthorHealthProfessional}">
                                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootAuthorHealthProfessional))"/>
                                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                                    <xsl:variable name="ref" select="generate-id(.)"/>
                                    <!-- create the element for the reference -->
                                    <xsl:element name="{$elmHealthProfessional}">
                                        <xsl:attribute name="value" select="$ref"/>
                                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthProfessional)))"/>
                                        <xsl:attribute name="datatype">reference</xsl:attribute>
                                    </xsl:element>
                                    <!-- output the actual healthcare professional here as well, we will move it to apropriate location in ada xml later -->
                                    <xsl:call-template name="HandleHealthProfessional">
                                        <xsl:with-param name="adaId" select="$ref"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- related person as author not in HL7v3 ICA template 2.16.840.1.113883.2.4.3.11.60.20.77.10.111 -->
                        <!-- no mapping needed -->
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>

            <!-- subject, always patient in HL7v3 ICA -->
            <xsl:for-each select="hl7:subject">
                <xsl:element name="{$elmZibrootSubject}">
                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootSubject))"/>
                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                    <xsl:element name="{$elmPatient}">
                        <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmPatient))"/>
                        <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                        <!-- create the element for the reference -->
                        <xsl:element name="{$elmPatient}">
                            <xsl:attribute name="value" select="$patients/patient_information/patient/@id"/>
                            <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmPatient)))"/>
                            <xsl:attribute name="datatype">reference</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>

            <!-- date time -->
            <!-- NOTE TODO: issue ZIB-784, this mapping may be wrong...  -->
            <xsl:for-each select="hl7:author/hl7:time">
                <xsl:call-template name="handleTS">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmZibrootDateTime)))"/>
                    <xsl:with-param name="elemName" select="$elmZibrootDateTime"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>

    <xd:doc>
        <xd:desc>Create ada contact_point using an hl7 element</xd:desc>
        <xd:param name="adaId">Optional parameter to specify the ada id for this ada element. Defaults to a generate-id of context element</xd:param>
        <xd:param name="schema">Optional. Used to find conceptId attributes values for elements. Should contain the whole ADA schema</xd:param>
        <xd:param name="schemaFragment">Optional for generating ada conceptId's. XSD Schema complexType for ada transaction</xd:param>
    </xd:doc>
    <xsl:template name="HandleContactPerson" match="hl7:responsibleParty" mode="HandleContactPerson">
        <xsl:param name="adaId" as="xs:string?" select="generate-id(.)"/>
        <xsl:param name="schema" as="node()*" select="$schema"/>
        <xsl:param name="schemaFragment" as="element(xs:complexType)?"/>

        <xsl:element name="{$elmContactPerson}">
            <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmContactPerson))"/>
            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
            <xsl:attribute name="id" select="$adaId"/>

            <xsl:call-template name="handleENtoNameInformation">
                <xsl:with-param name="in" select="hl7:agentPerson/hl7:name"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>

            <xsl:call-template name="handleTELtoContactInformation">
                <xsl:with-param name="in" select="hl7:telecom"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>

            <xsl:call-template name="handleADtoAddressInformation">
                <xsl:with-param name="in" select="hl7:addr"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>

        </xsl:element>
    </xsl:template>



    <xd:doc>
        <xd:desc>Converts the contents of an assignedPerson / assignedEntity a to zib Health Professional (zorgverlener)</xd:desc>
        <xd:param name="adaId">Optional parameter to specify the ada id for this ada element. Defaults to a generate-id of context element</xd:param>
        <xd:param name="schema">Optional. Used to find conceptId attributes values for elements. Should contain the whole ADA schema</xd:param>
        <xd:param name="schemaFragment">Optional for generating ada conceptId's. XSD Schema complexType for ada parent of current element to be outputted.</xd:param>
    </xd:doc>
    <xsl:template name="HandleHealthProfessional" match="hl7:assignedPerson | hl7:assignedAuthor | hl7:participantRole" mode="assignedPerson2HealthProfessional">
        <xsl:param name="adaId" as="xs:string?" select="generate-id(.)"/>
        <xsl:param name="schema" as="node()*" select="$schema"/>
        <xsl:param name="schemaFragment" as="element(xs:complexType)?"/>

        <xsl:variable name="typeCode">
            <xsl:choose>
                <xsl:when test="../@typeCode">
                    <xsl:value-of select="../@typeCode"/>
                </xsl:when>
                <xsl:when test="../local-name() = 'author'">AUT</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <!-- language specific ada element names -->
        <xsl:variable name="elmHealthProfessionalIdentificationNumber">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">health_professional_identification_number</xsl:when>
                <xsl:otherwise>zorgverlener_identificatienummer</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmSpecialism">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">specialty</xsl:when>
                <xsl:otherwise>specialisme</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$elmHealthProfessional}">
            <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthProfessional))"/>
            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
            <xsl:attribute name="id" select="$adaId"/>

            <!-- identification number -->
            <xsl:for-each select="hl7:id">
                <xsl:call-template name="handleII">
                    <xsl:with-param name="in" select="."/>
                    <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthProfessionalIdentificationNumber)))"/>
                    <xsl:with-param name="elemName" select="$elmHealthProfessionalIdentificationNumber"/>
                </xsl:call-template>
            </xsl:for-each>
            <!-- name information -->
            <xsl:call-template name="handleENtoNameInformation">
                <xsl:with-param name="in" select="./hl7:assignedPerson/hl7:name"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>

            <!-- Specialism -->
            <xsl:call-template name="handleCV">
                <xsl:with-param name="in" select="hl7:code"/>
                <xsl:with-param name="elemName" select="$elmSpecialism"/>
            </xsl:call-template>

            <!-- address information -->
            <xsl:call-template name="handleADtoAddressInformation">
                <xsl:with-param name="in" select="hl7:addr"/>
                <xsl:with-param name="language" select="$language"/>
            </xsl:call-template>

            <!-- contact details -->
            <xsl:call-template name="handleTELtoContactInformation">
                <xsl:with-param name="in" select="hl7:telecom"/>
                <xsl:with-param name="language" select="$language"/>
            </xsl:call-template>

            <!-- zorgaanbieder -->
            <xsl:for-each select="hl7:Organization | hl7:representedOrganization">
                <xsl:element name="{$elmHealthcareProvider}">
                    <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProvider))"/>
                    <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>
                    <xsl:variable name="ref" select="generate-id(.)"/>
                    <!-- create the element for the reference -->
                    <xsl:element name="{$elmHealthcareProvider}">
                        <xsl:attribute name="value" select="$ref"/>
                        <xsl:copy-of select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProvider)))"/>
                        <xsl:attribute name="datatype">reference</xsl:attribute>
                    </xsl:element>
                    <!-- output the actual organization here as well, we will take it out later -->
                    <xsl:call-template name="HandleOrganization">
                        <xsl:with-param name="adaId" select="$ref"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>


            <xsl:variable name="elmName">
                <xsl:choose>
                    <xsl:when test="$language = 'en-US'">health_professional_role</xsl:when>
                    <xsl:otherwise>zorgverleners_rol</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$typeCode = 'AUT'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Author</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'RESP'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Responsible Party</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'REF'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Referrer</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'PRF'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Performer</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'SPRF'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Secondary Performer</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'CON'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Consultant</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode = 'ATND'">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code" select="$typeCode"/>
                        <xsl:attribute name="codeSystem" select="$oidHL7ParticipationType"/>
                        <xsl:attribute name="displayName">Attender</xsl:attribute>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$typeCode">
                    <xsl:element name="{$elmName}">
                        <xsl:attribute name="code">OTH</xsl:attribute>
                        <xsl:attribute name="codeSystem" select="$oidHL7NullFlavor"/>
                        <xsl:attribute name="displayName">Other</xsl:attribute>
                        <xsl:attribute name="originalText" select="$typeCode"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>


        </xsl:element>

    </xsl:template>

    <xd:doc>
        <xd:desc>Create ada healthcare_provider using hl7:Organization</xd:desc>
        <xd:param name="adaId">Optional parameter to specify the ada id for this ada element. Defaults to a generate-id of context element</xd:param>
        <xd:param name="schema">Optional. Used to find conceptId attributes values for elements. Should contain the whole ADA schema</xd:param>
        <xd:param name="schemaFragment">Optional for generating ada conceptId's. XSD Schema complexType for ada parent of this concept</xd:param>
    </xd:doc>
    <xsl:template name="HandleOrganization" match="hl7:Organization" mode="HandleOrganization">
        <xsl:param name="adaId" as="xs:string?" select="generate-id(.)"/>
        <xsl:param name="schema" as="node()*" select="$schema"/>
        <xsl:param name="schemaFragment" as="element(xs:complexType)?"/>
        <!-- ada language aware element names -->
        <xsl:variable name="elmHealthcareProvider">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">healthcare_provider</xsl:when>
                <xsl:otherwise>zorgaanbieder</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmHealthcareProviderIdentificationNumber">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">healthcare_provider_identification_number</xsl:when>
                <xsl:otherwise>zorgaanbieder_identificatienummer</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmHealthcareProviderName">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">organization_name</xsl:when>
                <xsl:otherwise>organisatie_naam</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="elmHealthcareProviderType">
            <xsl:choose>
                <xsl:when test="$language = 'en-US'">organization_type</xsl:when>
                <xsl:otherwise>organisatie_type</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$elmHealthcareProvider}">
            <xsl:attribute name="id" select="$adaId"/>
            <xsl:variable name="schemaFragment" select="nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProvider))"/>
            <xsl:copy-of select="nf:getADAComplexTypeConceptId($schemaFragment)"/>

            <!-- id is required -->
            <xsl:call-template name="handleII">
                <xsl:with-param name="in" select="hl7:id"/>
                <xsl:with-param name="elemName" select="$elmHealthcareProviderIdentificationNumber"/>
                <xsl:with-param name="nullIfMissing">NI</xsl:with-param>
                <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProviderIdentificationNumber)))"/>
            </xsl:call-template>
            <xsl:call-template name="handleST">
                <xsl:with-param name="in" select="(hl7:name | hl7:desc)[1]"/>
                <xsl:with-param name="elemName" select="$elmHealthcareProviderName"/>
                <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProviderName)))"/>
            </xsl:call-template>
            <xsl:call-template name="handleTELtoContactInformation">
                <xsl:with-param name="in" select="hl7:telecom"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>
            <xsl:call-template name="handleADtoAddressInformation">
                <xsl:with-param name="in" select="hl7:addr"/>
                <xsl:with-param name="language" select="$language"/>
                <xsl:with-param name="schema" select="$schema"/>
                <xsl:with-param name="schemaFragment" select="$schemaFragment"/>
            </xsl:call-template>
            <xsl:call-template name="handleCV">
                <xsl:with-param name="in" select="hl7:code"/>
                <xsl:with-param name="elemName" select="$elmHealthcareProviderType"/>
                <xsl:with-param name="conceptId" select="nf:getADAComplexTypeConceptId(nf:getADAComplexType($schema, nf:getADAComplexTypeName($schemaFragment, $elmHealthcareProviderType)))"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>



</xsl:stylesheet>
