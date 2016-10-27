<?xml version="1.0" encoding="utf-8" ?>
<!--
	## bad-one.xslt
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
		<xsl:call-template name="output1" />
		<xsl:call-template name="output2" />
	</xsl:template>
	
	<xsl:template match="output2">
		<p>Output</p>
	</xsl:template>

</xsl:stylesheet>
