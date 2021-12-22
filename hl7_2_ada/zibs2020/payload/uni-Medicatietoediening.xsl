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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:hl7="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xd:doc>
        <xd:desc> Medicatietoediening MP 9 2.0</xd:desc>
        <xd:param name="in">HL7 medication administration</xd:param>
    </xd:doc>
    <xsl:template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9373_20210616162231" match="hl7:substanceAdministration" mode="HandleMTD92">
        <xsl:param name="in" select="."/>
        <!-- medicatietoediening -->
        <xsl:for-each select="$in">
            <medicatietoediening>

                <!-- identificatie -->
                <xsl:for-each select="hl7:id">
                    <xsl:call-template name="handleII">
                        <xsl:with-param name="elemName">identificatie</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- toedienings_product -->
                <xsl:for-each select="hl7:consumable/hl7:manufacturedProduct/hl7:manufacturedMaterial">
                    <toedienings_product>
                        <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.20.77.10.9362_20210602154632">
                            <xsl:with-param name="product-hl7" select="."/>
                            <xsl:with-param name="generateId" select="true()"/>
                        </xsl:call-template>
                    </toedienings_product>
                </xsl:for-each>

                <!-- toedienings_datum_tijd -->
                <xsl:for-each select="hl7:effectiveTime[@value | @nullFlavor]">
                    <xsl:call-template name="handleTS">
                        <xsl:with-param name="elemName">toedienings_datum_tijd</xsl:with-param>
                        <xsl:with-param name="datatype">datetime</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- afgesproken_datum_tijd -->
                <xsl:for-each select="hl7:entryRelationship/hl7:substanceAdministration[@moodCode = 'RQO']/hl7:effectiveTime[@value | @nullFlavor]">
                    <xsl:call-template name="handleTS">
                        <xsl:with-param name="elemName">afgesproken_datum_tijd</xsl:with-param>
                        <xsl:with-param name="datatype">datetime</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- geannuleerd_indicator -->
                <xsl:for-each select="hl7:statusCode">
                    <geannuleerd_indicator value="{@code='nullified'}"/>
                </xsl:for-each>

                <!-- toegediende_hoeveelheid -->
                <xsl:for-each select="hl7:doseQuantity/hl7:center[@value | @nullFlavor]">
                    <toegediende_hoeveelheid>
                        <aantal value="{(hl7:translation[@codeSystem = $oidGStandaardBST902THES2]/@value)[1]}"/>
                        <xsl:call-template name="handleCV">
                            <xsl:with-param name="in" select="(hl7:translation[@codeSystem = $oidGStandaardBST902THES2])[1]"/>
                            <xsl:with-param name="elemName">eenheid</xsl:with-param>
                        </xsl:call-template>
                    </toegediende_hoeveelheid>
                </xsl:for-each>

                <!-- afgesproken_hoeveelheid -->
                <xsl:for-each select="hl7:entryRelationship/hl7:substanceAdministration[@moodCode = 'RQO']/hl7:doseQuantity/hl7:center[@value | @nullFlavor]">
                    <afgesproken_hoeveelheid>
                        <aantal value="{(hl7:translation[@codeSystem = $oidGStandaardBST902THES2]/@value)[1]}"/>
                        <xsl:call-template name="handleCV">
                            <xsl:with-param name="in" select="(hl7:translation[@codeSystem = $oidGStandaardBST902THES2])[1]"/>
                            <xsl:with-param name="elemName">eenheid</xsl:with-param>
                        </xsl:call-template>
                    </afgesproken_hoeveelheid>
                </xsl:for-each>

                <!-- volgens_afspraak_indicator -->
                <xsl:for-each select="hl7:entryRelationship/hl7:observation[hl7:code[@code = '8'][@codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.5.2'] or hl7:code[@code = '112221000146107'][@codeSystem = $oidSNOMEDCT]]/hl7:value">
                    <xsl:call-template name="handleBL">
                        <xsl:with-param name="elemName">volgens_afspraak_indicator</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- toedieningsweg -->
                <xsl:for-each select="hl7:routeCode">
                    <xsl:variable name="elemName">toedieningsweg</xsl:variable>
                    <xsl:call-template name="handleCV">
                        <xsl:with-param name="elemName" select="$elemName"/>
                    </xsl:call-template>
                </xsl:for-each>

                <!-- toedieningssnelheid -->
                <xsl:call-template name="_toedieningssnelheid92">
                    <xsl:with-param name="inHl7" select="hl7:rateQuantity"/>
                </xsl:call-template>

                <!-- prik_plak_locatie -->
                <xsl:for-each select="hl7:approachSiteCode/hl7:originalText">
                    <prik_plak_locatie value="{text()}"/>
                </xsl:for-each>

                <!-- relatie_medicatieafspraak -->
                <xsl:for-each select="hl7:entryRelationship/*[hl7:code/@code = $maCode]/hl7:id[@extension | @root | @nullFlavor]">
                    <relatie_medicatieafspraak>
                        <xsl:call-template name="handleII">
                            <xsl:with-param name="elemName">identificatie</xsl:with-param>
                        </xsl:call-template>
                    </relatie_medicatieafspraak>
                </xsl:for-each>

                <!-- relatie_toedieningsafspraak -->
                <xsl:for-each select="hl7:entryRelationship/*[hl7:code/@code = $taCode]/hl7:id[@extension | @root | @nullFlavor]">
                    <relatie_toedieningsafspraak>
                        <xsl:call-template name="handleII">
                            <xsl:with-param name="elemName">identificatie</xsl:with-param>
                        </xsl:call-template>
                    </relatie_toedieningsafspraak>
                </xsl:for-each>

                <!-- relatie_wisselend_doseerschema -->
                <xsl:for-each select="hl7:entryRelationship/*[hl7:code/@code = $wdsCode]/hl7:id[@extension | @root | @nullFlavor]">
                    <relatie_wisselend_doseerschema>
                        <xsl:call-template name="handleII">
                            <xsl:with-param name="elemName">identificatie</xsl:with-param>
                        </xsl:call-template>
                    </relatie_wisselend_doseerschema>
                </xsl:for-each>

                <!-- huisartsen relaties -->
                <xsl:call-template name="_huisartsenRelaties"/>

                <!-- toediener -->
                <xsl:for-each select="hl7:performer">
                    <toediener>

                        <!-- toediener_is_zorgverlener -->
                        <xsl:for-each select=".[not(hl7:assignedEntity/hl7:code[@codeSystem = '2.16.840.1.113883.2.4.3.11.22.472' or @codeSystem = '2.16.840.1.113883.2.4.3.11.60.40.4.23.1'])][not(hl7:assignedEntity[hl7:code/@code = 'ONESELF'])]">
                            <!-- double nested zorgverlener in dataset -->
                            <zorgverlener>
                                <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.43_20210701">
                                    <xsl:with-param name="in-hl7" select="."/>
                                    <xsl:with-param name="generateId" select="true()"/>
                                </xsl:call-template>
                            </zorgverlener>
                        </xsl:for-each>

                        <!-- toediener_is_patient -->
                        <xsl:for-each select="hl7:assignedEntity[hl7:code/@code = 'ONESELF']">
                            <patient>
                                <toediener_is_patient value="true"/>
                            </patient>
                        </xsl:for-each>

                        <!-- toediener mantelzorger -->
                        <xsl:for-each select="hl7:assignedEntity[hl7:code[@codeSystem = '2.16.840.1.113883.2.4.3.11.22.472' or @codeSystem = '2.16.840.1.113883.2.4.3.11.60.40.4.23.1']][not(hl7:code/@code = 'ONESELF')]">
                            <mantelzorger>
                                <xsl:call-template name="template_2.16.840.1.113883.2.4.3.11.60.121.10.35_20210701">
                                    <xsl:with-param name="in-hl7" select="."/>
                                    <xsl:with-param name="generateId" select="true()"/>
                                </xsl:call-template>
                            </mantelzorger>
                        </xsl:for-each>
                    </toediener>
                </xsl:for-each>

                <!-- medicatie_toediening_reden_van_afwijken -->
                <xsl:call-template name="handleCV">
                    <xsl:with-param name="in" select="hl7:entryRelationship/hl7:observation[hl7:code[@code = '153631000146105'][@codeSystem = $oidSNOMEDCT]]/hl7:value"/>
                    <xsl:with-param name="elemName">medicatie_toediening_reden_van_afwijken</xsl:with-param>
                </xsl:call-template>

                <!-- medicatie_toediening_status, nullified zit in geannuleerd_indicator -->
                <xsl:for-each select="hl7:statusCode[@code ne 'nullified']">
                    <medicatie_toediening_status code="@code" codeSystem="{$hl7ActStatusMap[@hl7Code=@code]/@codeSystem}" displayName="{$hl7ActStatusMap[@hl7Code=@code]/@displayName}"/>
                </xsl:for-each>

                <!-- toelichting -->
                <xsl:for-each select="hl7:entryRelationship/hl7:act[hl7:code[@code = '48767-8'][@codeSystem = $oidLOINC]]/hl7:text">
                    <xsl:variable name="elemName">toelichting</xsl:variable>
                    <xsl:element name="{$elemName}">
                        <xsl:attribute name="value" select="text()"/>
                    </xsl:element>
                </xsl:for-each>
            </medicatietoediening>
        </xsl:for-each>

    </xsl:template>



</xsl:stylesheet>
