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
        <xd:desc>Converts ada voedingsadvies to FHIR Observation conforming to profile nl-core-NutritionAdvice</xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>Create an nl-core-NutritionAdvice instance as an Observation FHIR instance from ada voedingsadvies element.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="patient">Optional ADA instance or ADA reference element for the patient.</xd:param>
    </xd:doc>
    <xsl:template match="voedingsadvies" name="nl-core-NutritionAdvice" mode="nl-core-NutritionAdvice" as="element(f:NutritionOrder)?">
        <xsl:param name="in" select="." as="element()?"/>
        <xsl:param name="patient" select="patient/*" as="element()?"/>
        
        <xsl:for-each select="$in">
            <NutritionOrder>
                <xsl:call-template name="insertLogicalId"/>
                <meta>
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/nl-core-NutritionAdvice"/>
                </meta>
                <xsl:for-each select="probleem">
                    <extension url="http://hl7.org/fhir/StructureDefinition/workflow-reasonReference">
                        <xsl:call-template name="makeReference">
                            <xsl:with-param name="in" select="probleem"/>
                            <xsl:with-param name="profile" select="'nl-core-Problem'"/>
                        </xsl:call-template>
                    </extension>
                </xsl:for-each>
                <status value="final"/>
                <intent value="order"/>
                <xsl:call-template name="makeReference">
                    <xsl:with-param name="in" select="$patient"/>
                    <xsl:with-param name="wrapIn" select="'patient'"/>
                </xsl:call-template>
                <!--No suitable field to map to dateTime is present in the ada instance, hence current-dateTime is used instead. See https://github.com/Nictiz/Nictiz-R4-zib2020/issues/179.-->
               <dateTime>
                   <xsl:value-of select="current-dateTime()"/>
               </dateTime>
                <oralDiet>
                    <xsl:for-each select="dieet_type">
                        <type>
                            <text>
                                <xsl:call-template name="string-to-string">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </text>
                        </type>
                    </xsl:for-each>
                    <!--No general mapping possible for consistentie, as it depends on the type of food; thus the mapping for solid food is used in all cases. See https://github.com/Nictiz/Nictiz-R4-zib2020/issues/179.-->
                    <xsl:for-each select="consistentie">
                        <texture>
                            <modifier>
                                <text>
                                    <xsl:call-template name="string-to-string">
                                        <xsl:with-param name="in" select="."/>
                                    </xsl:call-template>
                                </text>
                            </modifier>
                        </texture>
                        <!--<fluidConsistencyType>
                            <text>
                                <xsl:call-template name="string-to-string">
                                    <xsl:with-param name="in" select="."/>
                                </xsl:call-template>
                            </text>
                        </fluidConsistencyType>-->
                    </xsl:for-each>
                </oralDiet>
                <xsl:for-each select="toelichting">
                    <note>
                        <text>
                            <xsl:call-template name="string-to-string">
                                <xsl:with-param name="in" select="."/>
                            </xsl:call-template>
                        </text>
                    </note>
                </xsl:for-each>
            </NutritionOrder>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>