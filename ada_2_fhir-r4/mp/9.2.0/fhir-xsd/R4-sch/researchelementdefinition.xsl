<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:f="http://hl7.org/fhir" xmlns:h="http://www.w3.org/1999/xhtml" version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->

   <axsl:param name="archiveDirParameter"/>
   <axsl:param name="archiveNameParameter"/>
   <axsl:param name="fileNameParameter"/>
   <axsl:param name="fileDirParameter"/>
   <axsl:variable name="document-uri">
      <axsl:value-of select="document-uri(/)"/>
   </axsl:variable>

<!--PHASES-->


<!--PROLOG-->

   <axsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>

<!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->

   <axsl:template match="*" mode="schematron-select-full-path">
      <axsl:apply-templates select="." mode="schematron-get-full-path"/>
   </axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->

   <axsl:template match="*" mode="schematron-get-full-path">
      <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <axsl:text>/</axsl:text>
      <axsl:choose>
         <axsl:when test="namespace-uri()=''">
            <axsl:value-of select="name()"/>
         </axsl:when>
         <axsl:otherwise>
            <axsl:text>*:</axsl:text>
            <axsl:value-of select="local-name()"/>
            <axsl:text>[namespace-uri()='</axsl:text>
            <axsl:value-of select="namespace-uri()"/>
            <axsl:text>']</axsl:text>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <axsl:text>[</axsl:text>
      <axsl:value-of select="1+ $preceding"/>
      <axsl:text>]</axsl:text>
   </axsl:template>
   <axsl:template match="@*" mode="schematron-get-full-path">
      <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <axsl:text>/</axsl:text>
      <axsl:choose>
         <axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/>
         </axsl:when>
         <axsl:otherwise>
            <axsl:text>@*[local-name()='</axsl:text>
            <axsl:value-of select="local-name()"/>
            <axsl:text>' and namespace-uri()='</axsl:text>
            <axsl:value-of select="namespace-uri()"/>
            <axsl:text>']</axsl:text>
         </axsl:otherwise>
      </axsl:choose>
   </axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->

   <axsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <axsl:for-each select="ancestor-or-self::*">
         <axsl:text>/</axsl:text>
         <axsl:value-of select="name(.)"/>
         <axsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <axsl:text>[</axsl:text>
            <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <axsl:text>]</axsl:text>
         </axsl:if>
      </axsl:for-each>
      <axsl:if test="not(self::*)">
         <axsl:text/>/@<axsl:value-of select="name(.)"/>
      </axsl:if>
   </axsl:template><!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->

   <axsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <axsl:for-each select="ancestor-or-self::*">
         <axsl:text>/</axsl:text>
         <axsl:value-of select="name(.)"/>
         <axsl:if test="parent::*">
            <axsl:text>[</axsl:text>
            <axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <axsl:text>]</axsl:text>
         </axsl:if>
      </axsl:for-each>
      <axsl:if test="not(self::*)">
         <axsl:text/>/@<axsl:value-of select="name(.)"/>
      </axsl:if>
   </axsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->

   <axsl:template match="/" mode="generate-id-from-path"/>
   <axsl:template match="text()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </axsl:template>
   <axsl:template match="comment()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </axsl:template>
   <axsl:template match="processing-instruction()" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </axsl:template>
   <axsl:template match="@*" mode="generate-id-from-path">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:value-of select="concat('.@', name())"/>
   </axsl:template>
   <axsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <axsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <axsl:text>.</axsl:text>
      <axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </axsl:template>

<!--MODE: GENERATE-ID-2 -->

   <axsl:template match="/" mode="generate-id-2">U</axsl:template>
   <axsl:template match="*" mode="generate-id-2" priority="2">
      <axsl:text>U</axsl:text>
      <axsl:number level="multiple" count="*"/>
   </axsl:template>
   <axsl:template match="node()" mode="generate-id-2">
      <axsl:text>U.</axsl:text>
      <axsl:number level="multiple" count="*"/>
      <axsl:text>n</axsl:text>
      <axsl:number count="node()"/>
   </axsl:template>
   <axsl:template match="@*" mode="generate-id-2">
      <axsl:text>U.</axsl:text>
      <axsl:number level="multiple" count="*"/>
      <axsl:text>_</axsl:text>
      <axsl:value-of select="string-length(local-name(.))"/>
      <axsl:text>_</axsl:text>
      <axsl:value-of select="translate(name(),':','.')"/>
   </axsl:template><!--Strip characters-->
   <axsl:template match="text()" priority="-1"/>

<!--SCHEMA SETUP-->

   <axsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <axsl:comment>
            <axsl:value-of select="$archiveDirParameter"/>   
		 <axsl:value-of select="$archiveNameParameter"/>  
		 <axsl:value-of select="$fileNameParameter"/>  
		 <axsl:value-of select="$fileDirParameter"/>
         </axsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://hl7.org/fhir" prefix="f"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xhtml" prefix="h"/>
         <svrl:active-pattern>
            <axsl:attribute name="document">
               <axsl:value-of select="document-uri(/)"/>
            </axsl:attribute>
            <axsl:attribute name="name">Global</axsl:attribute>
            <axsl:apply-templates/>
         </svrl:active-pattern>
         <axsl:apply-templates select="/" mode="M2"/>
         <svrl:active-pattern>
            <axsl:attribute name="document">
               <axsl:value-of select="document-uri(/)"/>
            </axsl:attribute>
            <axsl:attribute name="name">Global 1</axsl:attribute>
            <axsl:apply-templates/>
         </svrl:active-pattern>
         <axsl:apply-templates select="/" mode="M3"/>
         <svrl:active-pattern>
            <axsl:attribute name="document">
               <axsl:value-of select="document-uri(/)"/>
            </axsl:attribute>
            <axsl:attribute name="name">ResearchElementDefinition</axsl:attribute>
            <axsl:apply-templates/>
         </svrl:active-pattern>
         <axsl:apply-templates select="/" mode="M4"/>
      </svrl:schematron-output>
   </axsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN Global-->

   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Global</svrl:text>

	<!--RULE -->

   <axsl:template match="f:extension" priority="1001" mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:extension"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), 'value')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), 'value')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ext-1: Must have either extensions or value[x], not both</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M2"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:modifierExtension" priority="1000" mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:modifierExtension"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), 'value')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(f:extension)!=exists(f:*[starts-with(local-name(.), 'value')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ext-1: Must have either extensions or value[x], not both</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M2"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M2"/>
   <axsl:template match="@*|node()" priority="-2" mode="M2">
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M2"/>
   </axsl:template>

<!--PATTERN Global 1-->

   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Global 1</svrl:text>

	<!--RULE -->

   <axsl:template match="f:*" priority="1000" mode="M3">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:*"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="@value|f:*|h:div"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value|f:*|h:div">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>global-1: All FHIR elements must have a @value or children</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M3"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M3"/>
   <axsl:template match="@*|node()" priority="-2" mode="M3">
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M3"/>
   </axsl:template>

<!--PATTERN ResearchElementDefinition-->

   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">ResearchElementDefinition</svrl:text>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition" priority="1058" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(parent::f:contained and f:contained)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(parent::f:contained and f:contained)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>dom-2: If the resource is contained in another resource, it SHALL NOT contain nested Resources</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:contained/*/f:meta/f:versionId)) and not(exists(f:contained/*/f:meta/f:lastUpdated))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>dom-4: If a resource is contained in another resource, it SHALL NOT have a meta.versionId or a meta.lastUpdated</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(for $id in f:contained/*/f:id/@value return $id[not(parent::*/descendant::f:reference/@value=concat('#', $id/*/id/@value) or descendant::f:reference[@value='#'])]))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(for $id in f:contained/*/f:id/@value return $id[not(parent::*/descendant::f:reference/@value=concat('#', $id/*/id/@value) or descendant::f:reference[@value='#'])]))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>dom-3: If the resource is contained in another resource, it SHALL be referred to from elsewhere in the resource or SHALL refer to the containing resource</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:contained/*/f:meta/f:security))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:contained/*/f:meta/f:security))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>dom-5: If a resource is contained in another resource, it SHALL NOT have a security label</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:text/h:div" priority="1057" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:text/h:div"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(descendant-or-self::*[not(local-name(.)=('a', 'abbr', 'acronym', 'b', 'big', 'blockquote', 'br', 'caption', 'cite', 'code', 'col', 'colgroup', 'dd', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 'samp', 'small', 'span', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'ul', 'var'))]) and not(descendant-or-self::*/@*[not(name(.)=('abbr', 'accesskey', 'align', 'alt', 'axis', 'bgcolor', 'border', 'cellhalign', 'cellpadding', 'cellspacing', 'cellvalign', 'char', 'charoff', 'charset', 'cite', 'class', 'colspan', 'compact', 'coords', 'dir', 'frame', 'headers', 'height', 'href', 'hreflang', 'hspace', 'id', 'lang', 'longdesc', 'name', 'nowrap', 'rel', 'rev', 'rowspan', 'rules', 'scope', 'shape', 'span', 'src', 'start', 'style', 'summary', 'tabindex', 'title', 'type', 'valign', 'value', 'vspace', 'width'))])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(descendant-or-self::*[not(local-name(.)=('a', 'abbr', 'acronym', 'b', 'big', 'blockquote', 'br', 'caption', 'cite', 'code', 'col', 'colgroup', 'dd', 'dfn', 'div', 'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i', 'img', 'li', 'ol', 'p', 'pre', 'q', 'samp', 'small', 'span', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'ul', 'var'))]) and not(descendant-or-self::*/@*[not(name(.)=('abbr', 'accesskey', 'align', 'alt', 'axis', 'bgcolor', 'border', 'cellhalign', 'cellpadding', 'cellspacing', 'cellvalign', 'char', 'charoff', 'charset', 'cite', 'class', 'colspan', 'compact', 'coords', 'dir', 'frame', 'headers', 'height', 'href', 'hreflang', 'hspace', 'id', 'lang', 'longdesc', 'name', 'nowrap', 'rel', 'rev', 'rowspan', 'rules', 'scope', 'shape', 'span', 'src', 'start', 'style', 'summary', 'tabindex', 'title', 'type', 'valign', 'value', 'vspace', 'width'))])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>txt-1: The narrative SHALL contain only the basic html formatting elements and attributes described in chapters 7-11 (except section 4 of chapter 9) and 15 of the HTML 4.0 standard, &lt;a&gt; elements (either name or href), images and internally contained style attributes</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="descendant::text()[normalize-space(.)!=''] or descendant::h:img[@src]"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="descendant::text()[normalize-space(.)!=''] or descendant::h:img[@src]">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>txt-2: The narrative SHALL have some non-whitespace content</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:identifier/f:period" priority="1056" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:identifier/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:identifier/f:assigner" priority="1055" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:identifier/f:assigner"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:subjectReference" priority="1054" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:subjectReference"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:subjectReference/f:identifier/f:period" priority="1053" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:subjectReference/f:identifier/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:subjectReference/f:identifier/f:assigner" priority="1052" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:subjectReference/f:identifier/f:assigner"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:contact/f:telecom" priority="1051" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:contact/f:telecom"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:value)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:value)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>cpt-2: A system is required if a value is provided.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:contact/f:telecom/f:period" priority="1050" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:contact/f:telecom/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueQuantity" priority="1049" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueQuantity"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueRange" priority="1048" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueRange"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>rng-2: If present, low SHALL have a lower value than high</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueRange/f:low" priority="1047" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueRange/f:low"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueRange/f:high" priority="1046" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueRange/f:high"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueReference" priority="1045" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueReference"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueReference/f:identifier/f:period" priority="1044" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueReference/f:identifier/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:useContext/f:valueReference/f:identifier/f:assigner" priority="1043" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:useContext/f:valueReference/f:identifier/f:assigner"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:effectivePeriod" priority="1042" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:effectivePeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:author/f:telecom" priority="1041" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:author/f:telecom"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:value)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:value)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>cpt-2: A system is required if a value is provided.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:author/f:telecom/f:period" priority="1040" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:author/f:telecom/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:editor/f:telecom" priority="1039" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:editor/f:telecom"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:value)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:value)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>cpt-2: A system is required if a value is provided.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:editor/f:telecom/f:period" priority="1038" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:editor/f:telecom/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:reviewer/f:telecom" priority="1037" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:reviewer/f:telecom"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:value)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:value)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>cpt-2: A system is required if a value is provided.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:reviewer/f:telecom/f:period" priority="1036" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:reviewer/f:telecom/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:endorser/f:telecom" priority="1035" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:endorser/f:telecom"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:value)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:value)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>cpt-2: A system is required if a value is provided.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:endorser/f:telecom/f:period" priority="1034" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:endorser/f:telecom/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:relatedArtifact/f:document" priority="1033" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:relatedArtifact/f:document"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:data)) or exists(f:contentType)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:data)) or exists(f:contentType)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>att-1: If the Attachment has data, it SHALL have a contentType</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionExpression" priority="1032" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionExpression"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="exists(f:expression) or exists(f:reference)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(f:expression) or exists(f:reference)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>exp-1: An expression or a reference must be provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference" priority="1031" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference/f:identifier/f:period" priority="1030" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference/f:identifier/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference/f:identifier/f:assigner" priority="1029" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:subjectReference/f:identifier/f:assigner"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:codeFilter" priority="1028" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:codeFilter"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(exists(f:path) and not(exists(f:searchParam))) or (not(exists(f:path)) and exists(f:searchParam))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(exists(f:path) and not(exists(f:searchParam))) or (not(exists(f:path)) and exists(f:searchParam))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drq-1: Either a path or a searchParam must be provided, but not both</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter" priority="1027" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(exists(f:path) and not(exists(f:searchParam))) or (not(exists(f:path)) and exists(f:searchParam))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(exists(f:path) and not(exists(f:searchParam))) or (not(exists(f:path)) and exists(f:searchParam))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drq-2: Either a path or a searchParam must be provided, but not both</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter/f:valuePeriod" priority="1026" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter/f:valuePeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter/f:valueDuration" priority="1025" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:definitionDataRequirement/f:dateFilter/f:valueDuration"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueQuantity" priority="1024" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueQuantity"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange" priority="1023" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>rng-2: If present, low SHALL have a lower value than high</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange/f:low" priority="1022" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange/f:low"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange/f:high" priority="1021" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueRange/f:high"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference" priority="1020" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference/f:identifier/f:period" priority="1019" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference/f:identifier/f:period"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference/f:identifier/f:assigner" priority="1018" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:usageContext/f:valueReference/f:identifier/f:assigner"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(starts-with(f:reference/@value, '#')) or exists(ancestor::*[self::f:entry or self::f:parameter]/f:resource/f:*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')]|/*/f:contained/f:*[f:id/@value=substring-after(current()/f:reference/@value, '#')])">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>ref-1: SHALL have a contained resource if a local reference is provided</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectivePeriod" priority="1017" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectivePeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveDuration" priority="1016" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveDuration"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat" priority="1015" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:offset)) or exists(f:when)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:offset)) or exists(f:when)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-9: If there's an offset, there must be a when (and not C, CM, CD, CV)</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="f:period/@value &gt;= 0 or not(f:period/@value)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="f:period/@value &gt;= 0 or not(f:period/@value)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-5: period SHALL be a non-negative value</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:periodMax)) or exists(f:period)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:periodMax)) or exists(f:period)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-6: If there's a periodMax, there must be a period</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:durationMax)) or exists(f:duration)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:durationMax)) or exists(f:duration)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-7: If there's a durationMax, there must be a duration</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:countMax)) or exists(f:count)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:countMax)) or exists(f:count)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-8: If there's a countMax, there must be a count</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:duration)) or exists(f:durationUnit)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:duration)) or exists(f:durationUnit)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-1: if there's a duration, there needs to be duration units</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:timeOfDay)) or not(exists(f:when))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:timeOfDay)) or not(exists(f:when))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-10: If there's a timeOfDay, there cannot be a when, or vice versa</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:period)) or exists(f:periodUnit)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:period)) or exists(f:periodUnit)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-2: if there's a period, there needs to be period units</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="f:duration/@value &gt;= 0 or not(f:duration/@value)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="f:duration/@value &gt;= 0 or not(f:duration/@value)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-4: duration SHALL be a non-negative value</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsDuration" priority="1014" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsDuration"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange" priority="1013" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>rng-2: If present, low SHALL have a lower value than high</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange/f:low" priority="1012" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange/f:low"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange/f:high" priority="1011" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsRange/f:high"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsPeriod" priority="1010" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTiming/f:repeat/f:boundsPeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTimeFromStart" priority="1009" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:studyEffectiveTimeFromStart"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectivePeriod" priority="1008" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectivePeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveDuration" priority="1007" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveDuration"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat" priority="1006" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:offset)) or exists(f:when)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:offset)) or exists(f:when)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-9: If there's an offset, there must be a when (and not C, CM, CD, CV)</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="f:period/@value &gt;= 0 or not(f:period/@value)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="f:period/@value &gt;= 0 or not(f:period/@value)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-5: period SHALL be a non-negative value</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:periodMax)) or exists(f:period)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:periodMax)) or exists(f:period)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-6: If there's a periodMax, there must be a period</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:durationMax)) or exists(f:duration)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:durationMax)) or exists(f:duration)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-7: If there's a durationMax, there must be a duration</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:countMax)) or exists(f:count)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:countMax)) or exists(f:count)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-8: If there's a countMax, there must be a count</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:duration)) or exists(f:durationUnit)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:duration)) or exists(f:durationUnit)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-1: if there's a duration, there needs to be duration units</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:timeOfDay)) or not(exists(f:when))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:timeOfDay)) or not(exists(f:when))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-10: If there's a timeOfDay, there cannot be a when, or vice versa</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:period)) or exists(f:periodUnit)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:period)) or exists(f:periodUnit)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-2: if there's a period, there needs to be period units</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="f:duration/@value &gt;= 0 or not(f:duration/@value)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="f:duration/@value &gt;= 0 or not(f:duration/@value)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>tim-4: duration SHALL be a non-negative value</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsDuration" priority="1005" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsDuration"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange" priority="1004" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:low/f:value/@value)) or not(exists(f:high/f:value/@value)) or (number(f:low/f:value/@value) &lt;= number(f:high/f:value/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>rng-2: If present, low SHALL have a lower value than high</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange/f:low" priority="1003" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange/f:low"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange/f:high" priority="1002" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsRange/f:high"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:code)) or exists(f:system)"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:code)) or exists(f:system)">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>qty-3: If a code for the unit is present, the system SHALL also be present</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsPeriod" priority="1001" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTiming/f:repeat/f:boundsPeriod"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists(f:start/@value)) or not(exists(f:end/@value)) or (xs:dateTime(f:start/@value) &lt;= xs:dateTime(f:end/@value))">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>per-1: If present, start SHALL have a lower value than end</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>

	<!--RULE -->

   <axsl:template match="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTimeFromStart" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="f:ResearchElementDefinition/f:characteristic/f:participantEffectiveTimeFromStart"/>

		<!--ASSERT -->

      <axsl:choose>
         <axsl:when test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')"/>
         <axsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="(f:code or not(f:value)) and (not(exists(f:system)) or f:system/@value='http://unitsofmeasure.org')">
               <axsl:attribute name="location">
                  <axsl:apply-templates select="." mode="schematron-select-full-path"/>
               </axsl:attribute>
               <svrl:text>drt-1: There SHALL be a code if there is a value and it SHALL be an expression of time.  If system is present, it SHALL be UCUM.</svrl:text>
            </svrl:failed-assert>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M4"/>
   <axsl:template match="@*|node()" priority="-2" mode="M4">
      <axsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </axsl:template>
</axsl:stylesheet>