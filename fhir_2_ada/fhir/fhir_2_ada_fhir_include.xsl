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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://hl7.org/fhir"
    xmlns:local="urn:fhir:stu3:functions"
    xmlns:nf="http://www.nictiz.nl/functions" 
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../../util/constants.xsl"/>
    <xsl:import href="../../util/datetime.xsl"/>
    
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xd:doc>
        <xd:desc>Transforms FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#code">@value</xd:a> to ada code element</xd:desc>
        <xd:param name="value">The FHIR @value</xd:param>
        <xd:param name="codeMap">Array of map elements to be used to map input FHIR codes to output ADA codes.</xd:param>
    </xd:doc>
    <xsl:template name="code-to-code" as="attribute()+">
        <xsl:param name="value" as="attribute(value)" select="."/>
        <xsl:param name="codeMap" as="element()*"/>
               
        <xsl:variable name="out" as="element()">
            <xsl:choose>
                <xsl:when test="$codeMap[@inValue = $value]">
                    <xsl:copy-of select="$codeMap[@inValue = $value]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:attribute name="code" select="$out/@code"/>
        <xsl:attribute name="codeSystem" select="$out/@codeSystem"/>
        <xsl:if test="$out/@displayName">
            <xsl:attribute name="displayName" select="$out/@displayName"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Transforms FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#CodeableConcept">CodeableConcept contents</xd:a> to ada code element.</xd:desc>
        <xd:param name="in">the FHIR CodeableConcept element</xd:param>
        <xd:param name="inElementName">Optionally provide the element name, default = coding. In extensions it is valueCoding.</xd:param>
    </xd:doc>
    <xsl:template name="CodeableConcept-to-code" as="attribute()*">
        <xsl:param name="in" as="element()?"/>
        <xsl:param name="inElementName" as="xs:string?">coding</xsl:param>
        
        <xsl:call-template name="Coding-to-code">
            <xsl:with-param name="in" select="$in/f:*[local-name()=$inElementName]"/>
        </xsl:call-template>
        <xsl:if test="normalize-space($in/f:text//text())">
            <xsl:attribute name="originalText" select="$in/f:text//text()"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Transforms FHIR <xd:a href="http://hl7.org/fhir/STU3/datatypes.html#Coding">Coding contents</xd:a> to ada code element</xd:desc>
        <xd:param name="in">the FHIR Coding contents</xd:param>
    </xd:doc>
    <xsl:template name="Coding-to-code" as="attribute()*">
        <xsl:param name="in" as="element()?" select="."/>

        <xsl:variable name="oid" select="local:getOid($in/f:system/@value)"/>
        <xsl:variable name="codeSystemName" select="local:getDisplayName($oid)"/>
        <xsl:attribute name="code" select="$in/f:code/@value"/>
        <xsl:if test="$oid">
            <xsl:attribute name="codeSystem" select="$oid"/>
        </xsl:if>
        <xsl:if test="not($codeSystemName=$oid)">
            <xsl:attribute name="codeSystemName" select="$codeSystemName"/>
        </xsl:if>
        <xsl:if test="$in/f:display/@value">
            <xsl:attribute name="displayName" select="replace($in/f:display/@value, '(^\s+)|(\s+$)', '')"></xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Formats FHIR date(Time) or ada normal or relativeDate(time) based on input precision</xd:desc>
        <xd:param name="dateTime">Input FHIR date(Time)</xd:param>
        <xd:param name="precision">Determines the precision of the output. Precision of minutes outputs seconds as '00'</xd:param>
        <xd:param name="dateT">Optional parameter. The T-date for which a relativeDate must be calculated. If not given a Touchstone like parameterised string is outputted</xd:param>
    </xd:doc>
    <xsl:template name="format2ADADate">
        <xsl:param name="dateTime" as="xs:string?"/>
        <xsl:param name="precision">second</xsl:param>
        <xsl:param name="dateT" as="xs:date?"/>
        
        <xsl:variable name="picture" as="xs:string?">
            <xsl:choose>
                <xsl:when test="upper-case($precision) = ('DAY', 'DAG', 'DAYS', 'DAGEN', 'D')">[Y0001]-[M01]-[D01]</xsl:when>
                <xsl:when test="upper-case($precision) = ('MINUTE', 'MINUUT', 'MINUTES', 'MINUTEN', 'MIN', 'M')">[Y0001]-[M01]-[D01]T[H01]:[m01]:00[Z]</xsl:when>
                <xsl:otherwise>[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($dateTime) castable as xs:dateTime">
                <xsl:value-of select="format-dateTime(xs:dateTime(nf:add-Amsterdam-timezone-to-dateTimeString(normalize-space($dateTime))), $picture)"/>
            </xsl:when>
            <xsl:when test="concat(normalize-space($dateTime), ':00') castable as xs:dateTime">
                <xsl:value-of select="format-dateTime(xs:dateTime(nf:add-Amsterdam-timezone-to-dateTimeString(concat(normalize-space($dateTime), ':00'))), $picture)"/>
            </xsl:when>
            <xsl:when test="normalize-space($dateTime) castable as xs:date">
                <xsl:value-of select="format-date(xs:date(normalize-space($dateTime)), '[Y0001]-[M01]-[D01]')"/>
            </xsl:when>
            <!-- there may be a relative date(time) like "${DATE, T, D, -20}T12:34:45+02:00" in the input -->
            <xsl:when test="matches($dateTime, '\$\{DATE, T, [YMD], ([+\-]\d+(\.\d+)?)\}')">
                <xsl:variable name="sign">
                    <xsl:variable name="temp" select="replace($dateTime, '\$\{DATE, T, [YMD], (([+\-])\d+(\.\d+)?)\}.*', '$2')"/>
                    <xsl:choose>
                        <xsl:when test="string-length($temp) gt 0">
                            <xsl:value-of select="$temp"/>
                        </xsl:when>
                        <!-- default -->
                        <xsl:otherwise>+</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="amount">
                    <xsl:variable name="temp" select="replace($dateTime, '\$\{DATE, T, [YMD], ([+\-](\d+(\.\d+)?))\}.*', '$2')"/>
                    <xsl:choose>
                        <xsl:when test="string-length($temp) gt 0">
                            <xsl:value-of select="$temp"/>
                        </xsl:when>
                        <!-- default -->
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="yearMonthDay">
                    <xsl:variable name="temp" select="replace($dateTime, '\$\{DATE, T, ([YMD]), ([+\-](\d+(\.\d+)?))\}.*', '$1')"/>
                    <xsl:choose>
                        <xsl:when test="string-length($temp) gt 0">
                            <xsl:value-of select="$temp"/>
                        </xsl:when>
                        <!-- default -->
                        <xsl:otherwise>D</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="timePart" select="replace($dateTime, '\$\{DATE, T, ([YMD]), ([+\-](\d+(\.\d+)?))\}T(.+)[+\-].*', '$5')"/>
                <xsl:variable name="time">
                    <xsl:choose>
                        <xsl:when test="string-length($timePart) = 5">
                            <!-- time given in minutes, let's add 0 seconds -->
                            <xsl:value-of select="concat($timePart, ':00')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$timePart"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$dateT castable as xs:date">
                        <xsl:variable name="newDate" select="nf:calculate-t-date($dateTime, $dateT)"/>
                        <xsl:choose>
                            <xsl:when test="$newDate castable as xs:dateTime">
                                <!-- in an ada relative datetime the timezone is not permitted (or known), let's add the timezon -->
                                <xsl:value-of select="nf:add-Amsterdam-timezone-to-dateTimeString($newDate)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$newDate"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('T',$sign,$amount,$yearMonthDay)"/>
                        <xsl:if test="$time castable as xs:time">
                            <!-- Neglects timezone. Impact? -->
                            <xsl:value-of select="concat('{', $time, '}')"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- let's try if the input is HL7 date or dateTime, should not be since input is ada -->
                <xsl:variable name="newDateTime" select="replace(concat(normalize-space($dateTime), '00000000000000'), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', '$1-$2-$3T$4:$5:$6')"/>
                <xsl:variable name="newDate" select="replace(normalize-space($dateTime), '^(\d{4})(\d{2})(\d{2})', '$1-$2-$3')"/>
                <xsl:choose>
                    <xsl:when test="$newDateTime castable as xs:dateTime">
                        <xsl:value-of select="format-dateTime(xs:dateTime($newDateTime), $picture)"/>
                    </xsl:when>
                    <xsl:when test="$newDate castable as xs:date">
                        <xsl:value-of select="format-date(xs:date($newDateTime), '[Y0001]-[M01]-[D01]')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$dateTime"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Get the ada OID from FHIR System URI</xd:desc>
        <xd:param name="uri">input FHIR System URI</xd:param>
    </xd:doc>
    <xsl:function name="local:getOid" as="xs:string?">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$oidMap[@uri = $uri][@oid]">
                <xsl:value-of select="$oidMap[@uri = $uri]/@oid"/>
            </xsl:when>
            <xsl:when test="starts-with($uri,'urn:oid:')">
                <xsl:value-of select="substring-after($uri,'urn:oid:')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri"/>
                <xsl:message>WARNING: local:getOid() expects a FHIR System URI, but got "<xsl:value-of select="$uri"/>"</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Get the ada displayName from input OID</xd:desc>
        <xd:param name="oid">input OID from ada</xd:param>
    </xd:doc>
    <xsl:function name="local:getDisplayName" as="xs:string?">
        <xsl:param name="oid" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$oidMap[@oid = $oid][@displayName]">
                <xsl:value-of select="$oidMap[@oid = $oid]/@displayName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$oid"/>
                <xsl:message>WARNING: local:getDisplayName() expects an OID, but got "<xsl:value-of select="$oid"/>" OR cannot find the matching displayName</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Identity transformation</xd:desc>
    </xd:doc>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Remove comments</xd:desc>
    </xd:doc>
    <xsl:template match="comment()"/>
    
    <xd:doc>
        <xd:desc>Throw process if an unhandled FHIR element is matched.</xd:desc>
    </xd:doc>
    <xsl:template match="f:*" mode="#all">
        <xsl:message terminate="yes">Unhandled FHIR element: <xsl:value-of select="local-name()"/></xsl:message>
    </xsl:template>
    
</xsl:stylesheet>