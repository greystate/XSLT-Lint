<?xml version="1.0" encoding="utf-8" ?>
<!--
	## bad-one.xslt

	Contains lots of wrong-doings as a test-file for the `XSLTLint.xslt` file.

-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

	<xsl:param name="currentPageId" />
	<xsl:param name="currentPage" select="//*[@id = $currentPageId]" />
	<xsl:variable name="$siteRoot" select="$currentPage/ancestor-or-self::Website" />

	<!-- This references an undeclared namespace-prefix -->
	<xsl:variable name="data" select="make:node-set($siteRoot)" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="$currentPage" />
		
		<!-- These references undeclared variables/params -->
		<xsl:value-of select="$not-a-variable" />
		<xsl:if test="$not-a-variable-either"><!-- Do something --></xsl:if>
		
		<!-- This one IS declared so shouldn't throw an error -->
		<xsl:value-of select="$currentPageId" />
		
		<!-- This calls a non-existing template -->
		<xsl:call-template name="output1" />
		
		<!-- This calls a template that is wrongly declared as a match template -->
		<xsl:call-template name="output2" />
		
		<!-- This performs a call using param instead of with-param -->
		<xsl:call-template name="output3">
			<xsl:param name="today" select="'2006-01-01'" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="output2">
		<p>Output</p>
	</xsl:template>

	<xsl:template name="output3">
		<xsl:param name="today" />
	</xsl:template>

</xsl:stylesheet>
