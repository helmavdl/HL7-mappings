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
    xmlns:uuid="http://www.uuid.org"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>Converts ADA behandeldoel to FHIR resource conforming to profile nl-core-TreatmentObjective</xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Create a nl-core-behandeldoel instance as a Goal FHIR instance from ADA behandeldoel.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="subject">Optional ADA instance or ADA reference element for the patient</xd:param>
        <xd:param name="problem">Optional ADA instance or ADA reference element for Problem</xd:param>
        <xd:param name="functionalOrMentalStatus">Optional ADA instance or ADA reference element for FunctionalOrMentalStatus </xd:param>
    </xd:doc>
    <xsl:template match="behandeldoel" name="nl-core-TreatmentObjective" mode="nl-core-TreatmentObjective" as="element(f:Goal)">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="subject" select="patient/*" as="element()?"/>
        <xsl:param name="problem" select="probleem/*" as="element()?"/>
        <xsl:param name="functionalOrMentalStatus" select="nf:resolveAdaInstance(gewenste_gezondheidstoestand/functionele_of_mentale_status, $in)" as="element()?"/>
        
        <xsl:for-each select="$in">
            <Goal>
                <xsl:call-template name="insertLogicalId"/>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-TreatmentObjective"/>
                </meta>
                
                <!-- No zib concept can be mapped (implicitly). Therefore the default value will be set to _active_. -->
                <lifecycleStatus value="active"/>
                
                <xsl:for-each select="gewenst_zorgresultaat">
                    <description>
                        <text>
                            <xsl:call-template name="string-to-string">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </text>
                    </description>
                </xsl:for-each>
                <xsl:for-each select="$functionalOrMentalStatus">
                    <description>
                        <text>
                            <xsl:variable name="parts" as="item()*">
                                <xsl:if test="status_naam/@displayName">
                                    <xsl:value-of select="concat('Gewenste gezondheidstoestand: ', status_naam/@displayName)"/>
                                </xsl:if>
                                <xsl:if test="status_waarde/@displayName">
                                    <xsl:value-of select="concat('specifiek doel: ', status_waarde/@displayName)"/>
                                </xsl:if>
                                <xsl:if test="status_datum/@value">
                                    <xsl:value-of select="concat('per ', status_datum/@value)"/>
                                </xsl:if>
                            </xsl:variable>
                            <xsl:attribute name="value" select="string-join($parts[. != ''], ', ')"/>
                        </text>
                    </description>
                </xsl:for-each>
                
                <xsl:for-each select="$subject">
                    <xsl:call-template name="makeReference">
                        <xsl:with-param name="in" select="$subject"/>
                        <xsl:with-param name="wrapIn" select="'subject'"/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <xsl:for-each select="$functionalOrMentalStatus">
                    <target>
                        <xsl:for-each select="nf:resolveAdaInstance(hulpmiddel/medisch_hulpmiddel, $in)">
                            <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-TreatmentObjective.MedicalDevice">
                                <valueReference>
                                    <xsl:call-template name="makeReference">
                                        <xsl:with-param name="in" select="."/>
                                        <xsl:with-param name="profile" select="'nl-core-MedicalDevice'"/>
                                    </xsl:call-template>
                                </valueReference>
                            </extension>
                        </xsl:for-each>
                        
                        <xsl:for-each select="status_naam">
                            <measure>
                                <xsl:call-template name="code-to-CodeableConcept">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </measure>
                        </xsl:for-each>
                        <xsl:for-each select="status_waarde">
                            <detailCodeableConcept>
                                <xsl:call-template name="code-to-CodeableConcept">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </detailCodeableConcept>
                        </xsl:for-each>
                        <xsl:for-each select="status_datum">
                            <dueDate>
                                <xsl:call-template name="date-to-datetime">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </dueDate>
                        </xsl:for-each>
                    </target>                   
                </xsl:for-each>
                
                <xsl:for-each select="probleem">
                    <xsl:call-template name="makeReference">
                        <xsl:with-param name="in" select="$problem"/>
                        <xsl:with-param name="profile" select="'nl-core-Problem'"/>
                        <xsl:with-param name="wrapIn" select="'addresses'"/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <xsl:for-each select="$functionalOrMentalStatus">
                    <xsl:for-each select="toelichting">
                        <note>
                            <text value="{normalize-space(@value)}"/>
                        </note>
                    </xsl:for-each>
                </xsl:for-each>
            </Goal>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>Template to generate a display that can be shown when referencing this instance.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="functionalOrMentalStatus">Optional ADA instance or ADA reference element for FunctionalOrMentalStatus </xd:param>
    </xd:doc>
    <xsl:template match="behandeldoel" mode="_generateDisplay">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="functionalOrMentalStatus" select="nf:resolveAdaInstance(gewenste_gezondheidstoestand/functionele_of_mentale_status, $in)" as="element()?"/>
        <xsl:variable name="parts" as="xs:string*">
            <xsl:text>Behandeldoel</xsl:text>
            <xsl:for-each select="$functionalOrMentalStatus">
                <xsl:if test="status_naam/@displayName">
                    <xsl:value-of select="concat('Gewenste gezondheidstoestand: ', status_naam/@displayName)"/>
                </xsl:if>
                <xsl:if test="status_waarde/@displayName">
                    <xsl:value-of select="concat('specifiek doel: ', status_waarde/@displayName)"/>
                </xsl:if>
                <xsl:if test="status_datum/@value">
                    <xsl:value-of select="concat('per ', status_datum/@value)"/>
                </xsl:if>
            </xsl:for-each>
            
            <xsl:for-each select="gewenst_zorgresultaat">
                <xsl:value-of select="concat('Gewenst zorgresultaat: ', @value)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($parts[. != ''], ', ')"/>
    </xsl:template>
</xsl:stylesheet>
