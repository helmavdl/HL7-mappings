<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:nf="http://www.nictiz.nl/functions" xmlns:uuid="http://www.uuid.org" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:import href="ada_2_ada_mp.xsl"/>
    <xsl:import href="../../../util/uuid.xsl"/>
    <xsl:import href="../../../util/mp-functions.xsl"/>
    <xsl:import href="../../../util/datetime.xsl"/>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:param name="schemaFileString" as="xs:string?">../mp/9.0.7/beschikbaarstellen_medicatiegegevens/ada_schemas/beschikbaarstellen_medicatiegegevens.xsd</xsl:param>

    <xd:doc>
        <xd:desc>Start template</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:apply-templates select="." mode="ada920_2_907"/>
    </xsl:template>

    <xd:doc>
        <xd:desc> add schema, should be overridden from a calling use case specific xslt </xd:desc>
    </xd:doc>
    <xsl:template match="adaxml" mode="ada920_2_907">
        <xsl:variable name="noConceptIdAdaXml">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="#current"/>
                <xsl:attribute name="xsi:noNamespaceSchemaLocation">../../../9.0.7/<xsl:value-of select="data/*/local-name()"/>/ada_schemas/ada_<xsl:value-of select="data/*/local-name()"/>.xsd</xsl:attribute>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:variable>
        <!-- step two, some of the elements unfortunately have different names which are not consistent over the dataset -->
        <xsl:variable name="noConceptIdAdaXmlStep2">
            <xsl:apply-templates select="$noConceptIdAdaXml" mode="ada920_2_907_step2"/>
        </xsl:variable>

        <!-- move this to outside of default XSLT, not needed for conversion to FHIR or HL7v3 -->
        <xsl:apply-templates select="$noConceptIdAdaXmlStep2" mode="addConceptId"/>
    </xsl:template>


    <xd:doc>
        <xd:desc> update top level element </xd:desc>
    </xd:doc>
    <xsl:template match="adaxml/data/*" mode="ada920_2_907">
        <xsl:copy>
            <!-- bestaande attributen kopiëren -->
            <xsl:apply-templates select="@*" mode="#current"/>
            <!-- app en formName attribuut alsnog overschrijven -->
            <xsl:attribute name="app">mp-mp907</xsl:attribute>
            <xsl:variable name="mapTrans" select="$mapTransaction[@usecase = local-name(current())]/mp907"/>
            <!-- transaction attributes -->
            <xsl:attribute name="formName" select="$mapTrans/@formName"/>
            <xsl:attribute name="transactionRef" select="$mapTrans/@transactionRef"/>
            <xsl:attribute name="transactionEffectiveDate" select="$mapTrans/@transactionEffectiveDate"/>

            <xsl:apply-templates select="patient | medicamenteuze_behandeling" mode="#current"/>

            <xsl:apply-templates select="documentgegevens | voorstelgegevens" mode="#current"/>

        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handle references</xd:desc>
    </xd:doc>
    <xsl:template match="*[@datatype = 'reference'][@value]" mode="ada920_2_907">
        <!-- find the corresponding element with the contents and copy that instead -->
        <xsl:apply-templates select="ancestor::data/*//*[@id = current()/@value]" mode="#current"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handle references, output @id in adaextension as this is not known in 907 ada xsd, but still useful for transformation</xd:desc>
    </xd:doc>
    <xsl:template match="*[not(@app)][@id]" mode="ada920_2_907">
        <xsl:variable name="elementName" select="replace(local-name(), 'farmaceutisch_', '')"/>
        <xsl:element name="{$elementName}">
            <xsl:apply-templates select="node()" mode="#current"/>
            <adaextension>
                <reference_id value="{@id}"/>
            </adaextension>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc>Add double nesting for naamgegevens</xd:desc>
    </xd:doc>
    <xsl:template match="zorgverlener/naamgegevens" mode="ada920_2_907">
        <xsl:copy>
            <naamgegevens>
                <xsl:apply-templates select="*" mode="#current"/>
            </naamgegevens>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Remove double nesting for zorgverlener/zorgaanbieder[zorgaanbieder] and criterium[criterium]</xd:desc>
    </xd:doc>
    <xsl:template match="zorgverlener/zorgaanbieder[zorgaanbieder] | criterium[criterium]" mode="ada920_2_907">
        <xsl:apply-templates select="*" mode="#current"/>
    </xsl:template>



    <xd:doc>
        <xd:desc>Gebruiksinstructie/HerhaalperiodeCyclischSchema/@unit=dag (920)
            Gebruiksinstructie/HerhaalperiodeCyclischSchema/@unit=d (907)
        </xd:desc>
    </xd:doc>
    <xsl:template match="herhaalperiode_cyclisch_schema" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="unit">
                <xsl:value-of select="replace(@unit, '^dag$', 'd')"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc> handling for verstrekkingsverzoek, so with proper 907 conceptId. Mostly different order in elements. </xd:desc>
    </xd:doc>
    <xsl:template match="verstrekkingsverzoek" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="identificatie | verstrekkingsverzoek_datum_tijd | verstrekkingsverzoek_datum | auteur" mode="#current"/>
            <xsl:apply-templates select="te_verstrekken_hoeveelheid" mode="#current"/>
            <xsl:apply-templates select="aantal_herhalingen" mode="#current"/>
            <xsl:apply-templates select="te_verstrekken_geneesmiddel" mode="#current"/>
            <!-- the rest, except what was already done and the elements not supported in 907, such as relatie_contact/relatie_zorgepisode and financiele_indicatiecode -->
            <xsl:apply-templates select="*[not(self::identificatie | self::verstrekkingsverzoek_datum_tijd | self::verstrekkingsverzoek_datum | self::auteur | self::te_verstrekken_hoeveelheid | self::aantal_herhalingen | self::te_verstrekken_geneesmiddel | self::financiele_indicatiecode | self::relatie_contact | self::relatie_zorgepisode)]" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>handling for toedieningsafspraak</xd:desc>
    </xd:doc>
    <xsl:template match="toedieningsafspraak" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="gebruiksperiode/(start_datum_tijd | eind_datum_tijd)" mode="#current"/>
            <xsl:apply-templates select="identificatie | toedieningsafspraak_datum_tijd" mode="#current"/>
            <xsl:apply-templates select="gebruiksperiode/tijds_duur" mode="#current"/>
            <!-- distributievorm not present in 907 -->
            <xsl:apply-templates select="*[not(self::identificatie | self::toedieningsafspraak_datum_tijd | self::gebruiksperiode | self::distributievorm)]" mode="#current"/>
            <xsl:if test="not(relatie_medicatieafspraak/identificatie[@value | @root | @nullFlavor])">
                <!-- relatie_naar_medicatieafspraak is 1..1 R in 907 let's output a nullFlavor -->
                <relatie_naar_medicatieafspraak>
                    <identificatie nullFlavor="NI"/>
                </relatie_naar_medicatieafspraak>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>handling for toedieningsafspraak aanvullende_informatie</xd:desc>
    </xd:doc>
    <xsl:template match="toedieningsafspraak_aanvullende_informatie" mode="ada920_2_907">
        <!-- string to code -->
        <aanvullende_informatie code="OTH" codeSystem="{$oidHL7NullFlavor}" displayName="{$hl7NullFlavorMap[@hl7NullFlavor='OTH']/@displayName}" originalText="{@value}"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>handling for verstrekking aanvullende_informatie</xd:desc>
    </xd:doc>
    <xsl:template match="verstrekking/aanvullende_informatie" mode="ada920_2_907">
        <medicatieverstrekking_aanvullende_informatie>
            <xsl:apply-templates select="@* | node()" mode="ada920_2_907"/>
        </medicatieverstrekking_aanvullende_informatie>
    </xsl:template>


    <xd:doc>
        <xd:desc> handling for verstrekking, mostly different order in elements. </xd:desc>
    </xd:doc>
    <xsl:template match="medicatieverstrekking" mode="ada920_2_907">
        <verstrekking>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </verstrekking>
    </xsl:template>

    <xd:doc>
        <xd:desc> gebruiksperiode/start_datum_tijd </xd:desc>
    </xd:doc>
    <xsl:template match="gebruiksperiode/start_datum_tijd" mode="ada920_2_907">
        <gebruiksperiode_start>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </gebruiksperiode_start>
    </xsl:template>

    <xd:doc>
        <xd:desc> gebruiksperiode/eind_datum_tijd </xd:desc>
    </xd:doc>
    <xsl:template match="gebruiksperiode/eind_datum_tijd" mode="ada920_2_907">
        <gebruiksperiode_eind>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </gebruiksperiode_eind>
    </xsl:template>

    <xd:doc>
        <xd:desc> gebruiksperiode/tijds_duur </xd:desc>
    </xd:doc>
    <xsl:template match="gebruiksperiode/tijds_duur" mode="ada920_2_907">
        <gebruiksperiode>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </gebruiksperiode>
    </xsl:template>


    <xd:doc>
        <xd:desc>datatype has been updated from dateTime to time</xd:desc>
    </xd:doc>
    <xsl:template match="toedientijd" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:attribute name="datatype">datetime</xsl:attribute>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="@value castable as xs:dateTime">
                        <xsl:value-of select="@value"/>
                    </xsl:when>
                    <xsl:when test="@value castable as xs:time">
                        <xsl:value-of select="concat('1970-01-01T', @value)"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@value, 'T')">
                        <xsl:value-of select="replace(@value, '.+\{(.+)\}', '$1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>handling for verstrekkingsverzoek/verbruiksperiode, different concept naming from zibs 2020</xd:desc>
    </xd:doc>
    <xsl:template match="verstrekkingsverzoek/verbruiksperiode" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>

            <xsl:for-each select="start_datum_tijd[@value | @nullFlavor]">
                <ingangsdatum>
                    <xsl:apply-templates select="@*" mode="#current"/>
                </ingangsdatum>
            </xsl:for-each>
            <xsl:for-each select="eind_datum_tijd[@value | @nullFlavor]">
                <einddatum>
                    <xsl:apply-templates select="@*" mode="#current"/>
                </einddatum>
            </xsl:for-each>
            <xsl:for-each select="tijds_duur[@value | @unit | @nullFlavor]">
                <duur>
                    <xsl:apply-templates select="@*" mode="#current"/>
                </duur>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:desc>move lichaamslengte en lichaamsgewicht </xd:desc>
    </xd:doc>
    <xsl:template match="lichaamslengte | lichaamsgewicht" mode="ada920_2_907"/>

    <xd:doc>
        <xd:desc> afspraakdatumdatum van MP9 2.0 naar 9.0.7 </xd:desc>
    </xd:doc>
    <xsl:template match="(medicatieafspraak_datum_tijd | toedieningsafspraak_datum_tijd)" mode="ada920_2_907">
        <xsl:element name="afspraakdatum">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> datum van MP9 2.0 naar 9.0.7 </xd:desc>
    </xd:doc>
    <xsl:template match="verstrekkingsverzoek_datum_tijd | verstrekkingsverzoek_datum | medicatieverstrekkings_datum_tijd" mode="ada920_2_907">
        <xsl:element name="datum">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> datum van MP9 2.0 naar 9.0.7 </xd:desc>
    </xd:doc>
    <xsl:template match="aanschrijf_datum" mode="ada920_2_907">
        <xsl:element name="aanschrijfdatum">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> replacement of terminology codes for reden wijzigen staken </xd:desc>
    </xd:doc>
    <xsl:template match="reden_wijzigen_of_staken | reden_wijzigen_of_stoppen_gebruik" mode="ada920_2_907">
        <xsl:copy>
            <!-- do not copy @value, because it is a silly ada UI attribute for coded elements, for which we also cannot really predict the appropriate content that ada -->
            <xsl:apply-templates select="@*[not(name() = 'value')]" mode="#current"/>
            <xsl:for-each select="$mapRedenwijzigenstaken[mp920[@code = current()/@code][@codeSystem = current()/@codeSystem]][mp907]">
                <xsl:copy-of select="mp907/@*"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc> handling for doseerinstructie, mostly different order in elements. </xd:desc>
    </xd:doc>
    <xsl:template match="doseerinstructie" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="volgnummer" mode="#current"/>
            <xsl:apply-templates select="doseerduur" mode="#current"/>
            <xsl:apply-templates select="*[not(self::doseerduur | self::volgnummer)]" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="criterium[parent::criterium]" mode="ada920_2_907">
        <xsl:copy>
            <code>
                <xsl:apply-templates select="@*" mode="#current"/>
            </code>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>handling for toedieningsafspraak reden_afspraak</xd:desc>
    </xd:doc>
    <xsl:template match="toedieningsafspraak_reden_wijzigen_of_staken" mode="ada920_2_907">
        <!-- change of code datatype to string -->
        <reden_afspraak>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="string-length(@originalText) gt 0">
                        <xsl:value-of select="@originalText"/>
                    </xsl:when>
                    <xsl:when test="string-length(@displayName) gt 0">
                        <xsl:value-of select="@displayName"/>
                    </xsl:when>
                    <xsl:when test="string-length(@code) gt 0">
                        <xsl:value-of select="string-join(@code | @codeSystem, '|')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </reden_afspraak>
    </xsl:template>

    <xd:doc>
        <xd:desc>no tijds_duur in 907</xd:desc>
    </xd:doc>
    <xsl:template match="toedieningsduur/tijds_duur" mode="ada920_2_907">
        <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handle toedieningsschema, order of elements. We do have ada schema with is_flexibel, but in different order </xd:desc>
    </xd:doc>
    <xsl:template match="toedieningsschema" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="is_flexibel" mode="#current"/>
            <xsl:apply-templates select="node()[not(self::is_flexibel)]" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="medicatiegebruik_datum_tijd" mode="ada920_2_907">
        <registratiedatum>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </registratiedatum>
    </xsl:template>

    <xd:doc>
        <xd:desc> stoptype van MP9 2.0 naar 9.0.7 </xd:desc>
    </xd:doc>
    <xsl:template match="(medicatieafspraak | toedieningsafspraak | medicatiegebruik | medicatie_gebruik)/*[contains(replace(local-name(), '_', ''), 'stoptype')]" mode="ada920_2_907">
        <stoptype>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </stoptype>
    </xsl:template>

    <xd:doc>
        <xd:desc>gebruiksproduct</xd:desc>
    </xd:doc>
    <xsl:template match="gebruiksproduct" mode="ada920_2_907">
        <gebruiks_product>
            <xsl:apply-templates select="*" mode="#current"/>
        </gebruiks_product>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handle the medicatiegebruik/informant/persoon. TODO</xd:desc>
    </xd:doc>
    <xsl:template match="informant/persoon" mode="ada920_2_907">
        <!-- special handling for thuiszorg, because in 920 a thuiszorg professional is conveyed using zorgverlener see issue https://bits.nictiz.nl/browse/ZIB-1075 -->
        <xsl:choose>
            <xsl:when test="rol_of_functie[@code = '2'][@codeSystem = '2.16.840.1.113883.2.4.3.11.60.20.77.5.4']">
                <informant_is_zorgverlener>
                    <zorgverlener datatype="reference" value="{@referenceId}"/>
                </informant_is_zorgverlener>
            </xsl:when>
            <xsl:otherwise>
                <!-- simply output contactpersoon using reference -->
                <xsl:copy>
                    <contactpersoon datatype="reference" value="{@referenceId}"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Handle contactpersoon rol</xd:desc>
    </xd:doc>
    <xsl:template match="rol_of_functie" mode="ada920_2_907">
        <rol>
            <!-- do not copy @value, because it is a silly ada UI attribute for coded elements, for which we also cannot really predict the appropriate content that ada -->
            <xsl:apply-templates select="@*[not(name() = 'value')]" mode="#current"/>
            <xsl:for-each select="$mapRedenwijzigenstaken[mp907[@code = current()/@code][@codeSystem = current()/@codeSystem]][mp920]">
                <xsl:copy-of select="mp920/@*"/>
            </xsl:for-each>
        </rol>
    </xsl:template>

    <xd:doc>
        <xd:desc> ordering update ingredient </xd:desc>
    </xd:doc>
    <xsl:template match="ingredient" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="sterkte" mode="#current"/>
            <xsl:apply-templates select="ingredient_code" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>  some more brilliant name changes in zibs 2020 </xd:desc>
    </xd:doc>
    <xsl:template match="ingredient_hoeveelheid" mode="ada920_2_907">
        <hoeveelheid_ingredient>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </hoeveelheid_ingredient>
    </xsl:template>
    <xd:doc>
        <xd:desc>  some more brilliant name changes in zibs 2020 </xd:desc>
    </xd:doc>
    <xsl:template match="product_hoeveelheid" mode="ada920_2_907">
        <hoeveelheid_product>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </hoeveelheid_product>
    </xsl:template>

    <xd:doc>
        <xd:desc> relaties, add 'naar_' </xd:desc>
    </xd:doc>
    <xsl:template match="relatie_medicatieafspraak | relatie_verstrekkingsverzoek" mode="ada920_2_907">
        <xsl:element name="{replace(local-name(), '(relatie_)(.+)', 'relatie_naar_$2')}">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc>relaties in medicatiegebruik</xd:desc>
    </xd:doc>
    <xsl:template match="medicatiegebruik" mode="ada920_2_907">
        <medicatie_gebruik>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="gebruiksperiode/(start_datum_tijd | eind_datum_tijd)" mode="#current"/>
            <xsl:apply-templates select="identificatie | medicatiegebruik_datum_tijd | gebruik_indicator | volgens_afspraak_indicator | medicatie_gebruik_stop_type | gebruiksperiode/tijds_duur | gebruiksproduct | gebruiksinstructie" mode="#current"/>
            <xsl:if test="relatie_medicatieafspraak | relatie_toedieningsafspraak">
                <gerelateerde_afspraak>
                    <xsl:for-each select="relatie_medicatieafspraak/identificatie[@value | @root]">
                        <identificatie_medicatieafspraak>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_medicatieafspraak>
                    </xsl:for-each>
                    <xsl:for-each select="relatie_toedieningsafspraak/identificatie[@value | @root]">
                        <identificatie_toedieningsafspraak>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_toedieningsafspraak>
                    </xsl:for-each>
                </gerelateerde_afspraak>
            </xsl:if>
            <!-- the rest, except what was already done and the elements not supported in 907, such as relatie_contact/relatie_zorgepisode -->
            <xsl:apply-templates select="relatie_medicatieverstrekking | voorschrijver | informant | auteur | reden_gebruik | reden_wijzigen_of_stoppen_gebruik | toelichting" mode="#current"/>
        </medicatie_gebruik>
    </xsl:template>

    <xd:doc>
        <xd:desc>Medicatieafspraak, handle order of elements, gebruiksperiode, relaties.</xd:desc>
    </xd:doc>
    <xsl:template match="medicatieafspraak" mode="ada920_2_907">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="gebruiksperiode/(start_datum_tijd | eind_datum_tijd)" mode="#current"/>
            <xsl:apply-templates select="identificatie | medicatieafspraak_datum_tijd" mode="#current"/>
            <xsl:apply-templates select="gebruiksperiode/tijds_duur | geannuleerd_indicator | medicatieafspraak_stop_type" mode="#current"/>
            <xsl:if test="relatie_medicatieafspraak | relatie_toedieningsafspraak | relatie_medicatiegebruik">
                <relatie_naar_afspraak_of_gebruik>
                    <xsl:for-each select="relatie_medicatieafspraak/identificatie[@value | @root]">
                        <xsl:apply-templates select="." mode="#current"/>
                    </xsl:for-each>
                    <xsl:for-each select="relatie_toedieningsafspraak/identificatie[@value | @root]">
                        <identificatie_23288>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_23288>
                    </xsl:for-each>
                    <xsl:for-each select="relatie_medicatiegebruik/identificatie[@value | @root]">
                        <identificatie_23289>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_23289>
                    </xsl:for-each>
                </relatie_naar_afspraak_of_gebruik>
            </xsl:if>
            <xsl:if test="relatie_contact | relatie_zorgepisode">
                <relaties_ketenzorg>
                    <xsl:for-each select="relatie_contact/identificatie[@value | @root]">
                        <identificatie_contactmoment>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_contactmoment>
                    </xsl:for-each>
                    <xsl:for-each select="relatie_zorgepisode/identificatie[@value | @root]">
                        <identificatie_episode>
                            <xsl:apply-templates select="@*" mode="#current"/>
                        </identificatie_episode>
                    </xsl:for-each>
                </relaties_ketenzorg>
            </xsl:if>
            <xsl:apply-templates select="*[not(self::identificatie | self::medicatieafspraak_datum_tijd | self::gebruiksperiode | self::geannuleerd_indicator | self::medicatieafspraak_stop_type | self::relatie_medicatieafspraak | self::relatie_toedieningsafspraak | self::relatie_medicatiegebruik | self::relatie_contact | self::relatie_zorgepisode)]" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Wisselend doseerschema, bestaat niet in 907. Medicatietoediening wordt in geen enkele transactie gebruikt in 907</xd:desc>
    </xd:doc>
    <xsl:template match="wisselend_doseerschema | medicatietoediening" mode="ada920_2_907"/>

    <xd:doc>
        <xd:desc> relaties </xd:desc>
    </xd:doc>
    <xsl:template match="relatie_medicatieverstrekking[*]" mode="ada920_2_907">
        <xsl:for-each select="identificatie">
            <gerelateerde_verstrekking>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="#current"/>
                </xsl:copy>
            </gerelateerde_verstrekking>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc> minimum_waarde </xd:desc>
    </xd:doc>
    <xsl:template match="minimum_waarde" mode="ada920_2_907">
        <min>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </min>
    </xsl:template>
    <xd:doc>
        <xd:desc>nominale_waarde</xd:desc>
    </xd:doc>
    <xsl:template match="nominale_waarde" mode="ada920_2_907">
        <vaste_waarde>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </vaste_waarde>
    </xsl:template>
    <xd:doc>
        <xd:desc>maximum_waarde</xd:desc>
    </xd:doc>
    <xsl:template match="maximum_waarde" mode="ada920_2_907">
        <max>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </max>
    </xsl:template>


    <xd:doc>
        <xd:desc> zorgverlener_identificatie_nummer </xd:desc>
    </xd:doc>
    <xsl:template match="zorgverlener_identificatienummer[not(ancestor::medicatieafspraak/voorschrijver)]" mode="ada920_2_907_step2">
        <xsl:element name="zorgverlener_identificatie_nummer">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> zorgaanbieder_identificatie_nummer </xd:desc>
    </xd:doc>
    <xsl:template match="zorgaanbieder_identificatienummer[not(ancestor::medicatieafspraak/voorschrijver or ancestor::beoogd_verstrekker)]" mode="ada920_2_907_step2">
        <xsl:element name="zorgaanbieder_identificatie_nummer">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> naamgegevens -> zorgverlener_naam </xd:desc>
    </xd:doc>
    <xsl:template match="medicatie_gebruik/auteur/auteur_is_zorgverlener/zorgverlener/naamgegevens | medicatie_gebruik/informant/informant_is_zorgverlener/zorgverlener/naamgegevens" mode="ada920_2_907_step2">
        <xsl:element name="zorgverlener_naam">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xd:doc>
        <xd:desc> double nesting </xd:desc>
    </xd:doc>
    <xsl:template match="medicatie_gebruik/auteur/auteur_is_zorgverlener/zorgverlener/zorgaanbieder | medicatie_gebruik/informant/informant_is_zorgverlener/zorgverlener/zorgaanbieder" mode="ada920_2_907_step2">
        <xsl:copy>
            <xsl:element name="zorgaanbieder">
                <xsl:apply-templates select="@* | node()" mode="#current"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc> no conceptIds, no value (local for ada gui) for coded elements, only comments for groups </xd:desc>
    </xd:doc>
    <xsl:template match="@conceptId | *[@code]/@value | toedieningsduur/@comment" mode="ada920_2_907"/>


    <xd:doc>
        <xd:desc> Kopieer verder alles 1-op-1 </xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()" mode="ada920_2_907 ada920_2_907_step2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
