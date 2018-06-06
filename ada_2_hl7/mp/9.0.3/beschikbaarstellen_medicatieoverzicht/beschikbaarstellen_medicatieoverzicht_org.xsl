<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:hl7-org:v3" xmlns:hl7="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nf="http://www.nictiz.nl/functions"
    version="2.0">
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#default"/>
    <!--<xsl:include href="../../../hl7/hl7_include.xsl"/>-->
    <xsl:include href="../mp_include.xsl"/>
    <xsl:include href="../../../zib1bbr/zib1bbr_include.xsl"/>
    <xsl:include href="../../../naw/naw_include.xsl"/>
    <xsl:template match="/">
        <xsl:call-template name="Medicatieoverzicht_90">
            <xsl:with-param name="patient" select="//beschikbaarstellen_medicatieoverzicht/patient"/>
            <xsl:with-param name="mbh" select="//beschikbaarstellen_medicatieoverzicht/medicamenteuze_behandeling"/>
            <xsl:with-param name="docGeg" select="//beschikbaarstellen_medicatieoverzicht/documentgegevens"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="Medicatieoverzicht_90">
        <xsl:param name="patient"/>
        <xsl:param name="mbh"/>
        <xsl:param name="docGeg"/>

        <xsl:processing-instruction name="xml-model">href="file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schematron_closed_warnings/mp-MP90_mo.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>

        <organizer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:hl7-org:v3"
            xmlns:cda="urn:hl7-org:v3" xmlns:hl7nl="urn:hl7-nl:v3"
            xmlns:pharm="urn:ihe:pharm:medication"
            xsi:schemaLocation="urn:hl7-org:v3 file:/C:/SVN/AORTA/branches/Onderhoud_Mp_v90/XML/schemas/organizer.xsd"
            classCode="CLUSTER" moodCode="EVN">
            <templateId root="2.16.840.1.113883.2.4.3.11.60.20.77.10.9132"/>
            <code code="129" displayName="Medicatieoverzicht"
                codeSystem="2.16.840.1.113883.2.4.3.11.60.20.77.4"
                codeSystemName="ART DECOR transacties"/>
            <statusCode nullFlavor="NI"/>

            <!-- Documentdatum -->
            <xsl:call-template name="makeEffectiveTime">
                <xsl:with-param name="effectiveTime" select="$docGeg/documentdatum"/>
            </xsl:call-template>

            <!-- Patient -->
            <xsl:for-each select="$patient">
                <xsl:call-template
                    name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9119_20160710204856">
                    <xsl:with-param name="patient" select="."/>
                </xsl:call-template>
                <!-- Vanaf volgende publicatie het ZIB template gaan gebruiken: -->
                <!--<xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.3.10.3_20170602000000">
                    <xsl:with-param name="patient" select="."/>
                </xsl:call-template>-->
            </xsl:for-each>

            <!-- Auteur (=samenstellende organisatie van hele overzicht) -->
            <xsl:for-each select="$docGeg/auteur">
                <xsl:call-template
                    name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9171_20170522091920"/>
            </xsl:for-each>

            <!-- Verificatie patient -->
            <xsl:for-each select="$docGeg/verificatie_patient">
                <xsl:call-template
                    name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9179_20170523115538"/>
            </xsl:for-each>

            <!-- Verificatie zorgverlener -->
            <xsl:for-each select="$docGeg/verificatie_zorgverlener">
                <xsl:call-template
                    name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9180_20170523115753"/>
            </xsl:for-each>

            <xsl:for-each select="$mbh">
                <!-- Medicatieafspraak -->
                <xsl:for-each select="./medicatieafspraak">
                    <component typeCode="COMP">
                        <xsl:call-template
                            name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9148_20160725130413">
                            <xsl:with-param name="ma" select="."/>
                        </xsl:call-template>
                    </component>
                </xsl:for-each>
                <!-- Toedieningsafspraak -->
                <xsl:for-each select="./toedieningsafspraak">
                    <component typeCode="COMP">
                        <xsl:call-template
                            name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9152_20160726163318">
                            <xsl:with-param name="ta" select="."/>
                        </xsl:call-template>
                    </component>
                </xsl:for-each>
                <!-- Medicatiegebruik -->
                <xsl:for-each select="./medicatiegebruik">
                    <component typeCode="COMP">
                        <xsl:call-template
                            name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9154_20160726181533">
                            <xsl:with-param name="gb" select="."/>
                        </xsl:call-template>
                    </component>
                </xsl:for-each>
            </xsl:for-each>
        </organizer>
    </xsl:template>
    
</xsl:stylesheet>
