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
        <xd:desc>
            <xd:p>Converts ADA TimeInterval to FHIR datetype Period or Duration, depending on the situation and conforming to different profiles. See the documentation on the templates.</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc>
        <xd:desc>
            <xd:p>If needed, create the Period part from ADA TimeInterval input. If the input doesn't contain neither the StartDateTime or EndDateTime concept, output is suppressed. Normally, the output will take the form of the ext-TimeInterval.Period extension, unless <xd:ref name="wrapIn" type="parameter"/> is given.</xd:p>
            <xd:p>Please note: the input precision of the start and/or end date is not strictly adhered to; the start- en end date will be either a full date or a full date with time.</xd:p>
        </xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="wrapIn">Wrap the output in this element. If absent, the output will take the form of the ext-TimeInterval.Period extension.</xd:param>
    </xd:doc>
    <xsl:template name="ext-TimeInterval.Period" as="element()*">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="wrapIn" as="xs:string" select="''"/>

        <xsl:for-each select="$in">
            <xsl:if test="start_datum_tijd[@value != ''] or eind_datum_tijd[@value != ''] or tijds_duur[@value != '' or @unit != '']">
                <xsl:choose>
                    <!-- If no wrapIn is given, write out the extension element and iteratively call this template. -->
                    <xsl:when test="$wrapIn = ''">
                        <extension url="{$urlExtTimeIntervalPeriod}">
                            <xsl:call-template name="ext-TimeInterval.Period">
                                <xsl:with-param name="wrapIn">valuePeriod</xsl:with-param>
                            </xsl:call-template>
                        </extension>
                    </xsl:when>

                    <xsl:otherwise>
                        <!-- Convert input to xs datatypes -->
                        <!-- this does not support T-dates -->
                        <xsl:variable name="startDateTime" select="
                                if (start_datum_tijd[@value]) then
                                    nf:timestamp-to-dateTime(start_datum_tijd/@value)
                                else
                                    false()"/>
                        <xsl:variable name="endDateTime" select="
                                if (eind_datum_tijd[@value]) then
                                    nf:timestamp-to-dateTime(eind_datum_tijd/@value)
                                else
                                    false()"/>
                        <xsl:variable name="duration" select="
                                if (tijds_duur[@value]) then
                                    nf:quantity-to-xsDuration(tijds_duur)
                                else
                                    false()"/>

                        <!-- Calculate the "picture" to format the date. Only handle two cases of precisions: dates (year,
                             month, day) and dateTimes (with second precision. -->
                        <xsl:variable name="picture">
                            <xsl:choose>
                                <xsl:when test="
                                        start_datum_tijd/@value castable as xs:date or
                                        concat(start_datum_tijd/@value, ':00') castable as xs:date or
                                        eind_datum_tijd/@value castable as xs:date or
                                        concat(eind_datum_tijd/@value, ':00') castable as xs:date">[Y0001]-[M01]-[D01]</xsl:when>
                                <xsl:otherwise>[Y0001]-[M01]-[D01]T[H01]:[m01]:00[Z]</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <!-- Get start from input or calculate it from end and duration -->
                        <xsl:variable name="start">
                            <xsl:choose>
                                <xsl:when test="start_datum_tijd[@value]">
                                    <!-- commented out, does not support T-dates -->
                                    <!--<xsl:value-of select="format-dateTime($startDateTime, $picture)"/>-->
                                    <xsl:variable name="startTmp">
                                        <xsl:call-template name="format2FHIRDate">
                                            <xsl:with-param name="dateTime" select="start_datum_tijd/@value"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:value-of select="string-join($startTmp, '')"/>
                                </xsl:when>
                                <!-- AWE do not calculate startdate if not given -->
                                <!--<xsl:when test="eind_datum_tijd[@value] and tijds_duur[@value and @unit]">
                                    <!-\- TODO FIXME: support for T-date  -\->
                                    <xsl:value-of select="format-dateTime($endDateTime - $duration, $picture)"/>
                                </xsl:when>-->
                                <xsl:otherwise>
                                    <xsl:value-of select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <!-- Get end from input or calculate it from start and duration -->
                        <xsl:variable name="end" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="eind_datum_tijd[@value]">
                                    <!-- commented out, does not support T-dates -->
                                    <!--                                    <xsl:value-of select="format-dateTime($endDateTime, $picture)"/>-->
                                    <xsl:variable name="startTmp">
                                        <xsl:call-template name="format2FHIRDate">
                                            <xsl:with-param name="dateTime" select="eind_datum_tijd/@value"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:value-of select="string-join($startTmp, '')"/>
                                </xsl:when>
                                <!-- AWE do not calculate enddate if not given -->
                               <!-- <xsl:when test="start_datum_tijd[@value] and tijds_duur[@value and @unit]">
                                    <xsl:value-of select="format-dateTime($startDateTime + $duration, $picture)"/>
                                </xsl:when>-->
                                <xsl:otherwise>
                                    <xsl:value-of select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <!-- Write out the element, if we have any input, or if only a duration is known -->
                        <xsl:if test="string-join($start, '') or $end or $in/tijds_duur">
                            <xsl:element name="{$wrapIn}">
                                <xsl:call-template name="ext-TimeInterval.Duration"/>
                                <xsl:if test="string-join($start, '')">
                                    <start value="{$start}"/>
                                </xsl:if>
                                <xsl:if test="$end">
                                    <end value="{$end}"/>
                                </xsl:if>
                            </xsl:element>
                        </xsl:if>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>If needed, create the Duration part from ADA TimeInterval input. If the input doesn't contain the Duration concept or if the TimeInterval can be expressed as a Period, output is suppressed. Normally, the output will take the form of the ext-TimeInterval.Duration extension, unless <xd:ref name="wrapIn" type="parameter"/> is given.</xd:desc>
        <xd:param name="in">ADA element as input. Defaults to self.</xd:param>
        <xd:param name="wrapIn">Wrap the output in this element. If absent, the output will take the form of the ext-TimeInterval-Duration extension.</xd:param>
    </xd:doc>
    <xsl:template name="ext-TimeInterval.Duration" as="element()?">
        <xsl:param name="in" as="element()?" select="."/>
        <xsl:param name="wrapIn" as="xs:string?"/>

        <xsl:for-each select="$in">
            <xsl:if test="tijds_duur[@value | @unit]">
                <xsl:choose>
                    <!-- If no wrapIn is given, write out the extension element and iteratively call this template. -->
                    <xsl:when test="$wrapIn != ''">
                        <xsl:element name="{$wrapIn}">
                            <xsl:call-template name="hoeveelheid-to-Duration">
                                <xsl:with-param name="in" select="tijds_duur"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <extension url="http://nictiz.nl/fhir/StructureDefinition/ext-TimeInterval.Duration">
                            <xsl:call-template name="ext-TimeInterval.Duration">
                                <xsl:with-param name="wrapIn">valueDuration</xsl:with-param>
                            </xsl:call-template>
                        </extension>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
