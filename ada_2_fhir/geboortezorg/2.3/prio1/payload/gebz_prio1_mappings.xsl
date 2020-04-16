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
<xsl:stylesheet exclude-result-prefixes="#all" xmlns:date="http://exslt.org/dates-and-times"
    extension-element-prefixes="date" xmlns="http://hl7.org/fhir" xmlns:f="http://hl7.org/fhir" xmlns:local="urn:fhir:stu3:functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>  
    
    <xd:doc>
        <xd:desc>Mapping of ADA geboortezorg concepts to profiles.</xd:desc>
        <xd:param name="in">Node to consider in the creation of an Observation resource</xd:param>
    </xd:doc>
    <xsl:template name="bc-profile" match="graviditeit | pariteit | pariteit_voor_deze_zwangerschap | a_terme_datum | wijze_einde_zwangerschap | datum_einde_zwangerschap" as="element()">      
        <xsl:variable name="elementName" select="name(.)"/>
                
        <xsl:for-each select=".">            
            <xsl:choose>
                <xsl:when test="$elementName='graviditeit'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-Gravidity"/>
                </xsl:when>
                <xsl:when test="$elementName='pariteit' or $elementName='pariteit_voor_deze_zwangerschap'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-Parity"/>
                </xsl:when>
                <xsl:when test="$elementName='a_terme_datum'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-Pregnancy-DueDate"/>
                </xsl:when>
                <xsl:when test="$elementName='wijze_einde_zwangerschap' or $elementName='datum_einde_zwangerschap'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-PregnancyObservation"/>
                </xsl:when>
                <xsl:when test="$elementName='tijdstip_begin_actieve_ontsluiting' or $elementName='hoeveelheid_bloedverlies' or $elementName='conditie_perineum_postpartum'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-DeliveryObservation"/>
                </xsl:when>
                <xsl:when test="$elementName='tijdstip_actief_meepersen' or $elementName='type_partus'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-BirthObservation"/>
                </xsl:when> 
                <xsl:when test="$elementName='apgarscore_na_5_min'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/zib-ApgarScore"/>
                </xsl:when> 
                <xsl:when test="$elementName='geboortegewicht'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-BirthWeight"/>
                </xsl:when> 
                <xsl:when test="$elementName='bevalling'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-DeliveryProcedure"/>
                </xsl:when> 
                <xsl:when test="$elementName='vaginale_kunstverlossing'">
                    <profile value="http://nictiz.nl/fhir/StructureDefinition/bc-ObstetricProcedure"/>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="bc-observation-coding" match="graviditeit | pariteit | pariteit_voor_deze_zwangerschap | a_terme_datum | wijze_einde_zwangerschap | datum_einde_zwangerschap" as="element()">      
        <xsl:variable name="elementName" select="name(.)"/>
        <xsl:for-each select="."> 
            <coding>
            <xsl:choose>
                <xsl:when test="$elementName='graviditeit'">
                    <system value="http://loinc.org"/>
                    <code value="11996-6"/>
                    <display value="Gravidity"/>
                </xsl:when>
                <xsl:when test="$elementName='pariteit' or $elementName='pariteit_voor_deze_zwangerschap'">
                    <system value="http://loinc.org"/>
                    <code value="11977-6"/>
                    <display value="Parity"/>
                </xsl:when>
                <xsl:when test="$elementName='a_terme_datum'">
                    <system value="http://loinc.org"/>
                    <code value="11778-8"/>
                    <display value="Deliv date Clin est"/>
                </xsl:when>
                <xsl:when test="$elementName='wijze_einde_zwangerschap'">
                    <system value="urn:oid:2.16.840.1.113883.2.4.4.13"/>
                    <code value="EindeZw"/>
                    <display value="Wijze einde zwangerschap"/>
                </xsl:when>
                <xsl:when test="$elementName='datum_einde_zwangerschap'">
                    <system value="http://snomed.info/sct"/>
                    <code value="118951000146109"/>
                    <display value="Date of end of pregnancy (observable entity)"/>
                </xsl:when>
                <xsl:when test="$elementName='tijdstip_begin_actieve_ontsluiting'">
                    <system value="http://snomed.info/sct"/>
                    <code value="249120008"/>
                    <display value="Onset of labor first stage (observable entity)"/>
                </xsl:when>
                <xsl:when test="$elementName='hoeveelheid_bloedverlies'">            
                    <system value="http://snomed.info/sct"/>
                    <code value="364332008"/>
                    <display value="Blood loss in labour"/>
                </xsl:when>
                <xsl:when test="$elementName='conditie_perineum_postpartum'">
                    <system value="http://snomed.info/sct"/>
                    <code value="364297003"/>
                    <display value="Female perineum observable (observable entity)"/>
                </xsl:when>
                <xsl:when test="$elementName='tijdstip_actief_meepersen'">
                    <system value="http://snomed.info/sct"/>
                    <code value="249163006"/>
                    <display value="Onset of pushing (in labor) (observable entity)"/>
                </xsl:when> 
                <xsl:when test="$elementName='type_partus'">
                    <system value="http://snomed.info/sct"/>
                    <code value="364336006"/>
                    <display value="Pattern of delivery (observable entity)"/>
                </xsl:when> 
                <xsl:when test="$elementName='apgarscore_na_5_min'">
                    <system value="http://loinc.org"/>
                    <code value="9274-2"/>
                    <display value="5 minute Apgar Score"/>
                </xsl:when> 
                <xsl:when test="$elementName='geboortegewicht'">
                    <system value="http://loinc.org"/>
                    <code value="8339-4"/>
                    <display value="Birth weight Measured"/>
                </xsl:when> 
            </xsl:choose>
            </coding>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="bc-procedure-coding" match="bevalling | vaginale_kunstverlossing" as="element()">      
        <xsl:variable name="elementName" select="name(.)"/>
        <xsl:for-each select="."> 
            <coding>
                <xsl:choose>
                    <xsl:when test="$elementName='bevalling'">
                        <system value='http://snomed.info/sct'/>
                        <code value='236973005'/>
                        <display value='Delivery procedure (procedure)'/>
                    </xsl:when>
                    <xsl:when test="$elementName='vaginale_kunstverlossing'">
                        <system value='http://snomed.info/sct'/>
                        <code value='3311000146109'/>
                        <display value='Vaginale kunstverlossing'/>
                    </xsl:when>
                </xsl:choose>
            </coding>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="any-to-date" match="/">
        <xsl:variable name="dateValue">
            <xsl:call-template name="format-date"></xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(string(.) castable as xs:dateTime)">
                <valueDateTime value="{$dateValue}"/>
            </xsl:when>
            <xsl:otherwise>
                <valueDate value="{$dateValue}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="format-date" match="/">
<!--        <xsl:param name="fhirType" select="'choice[x]'"/>-->
        <xsl:variable name="operator" select="substring(@value,2,1)"/>
        <xsl:variable name="time" select="substring-before(substring-after(@value,'{'),'}')"/>
        <xsl:variable name="pattern">
            <xsl:choose>
                <xsl:when test="$time!=''">        
                    <xsl:value-of select="substring-after(substring-before(@value,'{'),$operator)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after(@value,$operator)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="date" select="current-date()-xs:dayTimeDuration(concat('P',$pattern))"/>
            <xsl:choose>
                <xsl:when test="$time!=''">        
                    <xsl:value-of select="concat(format-date($date,'[M]-[D]-[Y]'),'T',$time,':00+01:00')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date"/>
                </xsl:otherwise>            
            </xsl:choose>
        
<!--        <xsl:choose>
            <xsl:when test="$time!='' and $fhirType='choice[x]'"> 
                <valueDateTime value="{$value}"/>
            </xsl:when>
            <xsl:when test="$time!='' and $fhirType='period.start'"> 
                <start value = "{$value}"/>
            </xsl:when>
            <xsl:otherwise>
                <valueDate value="{$date}"/>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
