<?xml version="1.0" encoding="utf-8" ?>
<!--
	## XSLTLint.xslt
	
	Tests an XSLT file for some common (and frankly, embarrassing) errors.
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />

	<xsl:key name="namedTemplatesIndex" match="xsl:template" use="@name" />
	<xsl:key name="matchTemplatesIndex" match="xsl:template" use="@match" />

	<!-- Global variables -->
	<xsl:variable name="apos">&apos;</xsl:variable>
	<xsl:variable name="LF" xml:space="preserve">

</xsl:variable>
	
	<xsl:template match="xsl:*">
		<xsl:apply-templates select="xsl:*" />
	</xsl:template>

	<!--
	Checks for variable declarations including the dollar-sign (it happens)
	-->
	<xsl:template match="xsl:variable[starts-with(@name, '$')] | xsl:param[starts-with(@name, '$')]">
		<xsl:call-template name="error">
			<xsl:with-param name="message" select="concat('A variable name (', @name, ') was declared starting with a $ symbol.')" />
		</xsl:call-template>
	</xsl:template>

	<!--
	Test if we're accidentally calling a template that doesn't exist.
	It may actually be that it's defined as a match template instead.
	-->
	<xsl:template match="xsl:call-template">
		<xsl:variable name="template" select="@name" />

		<xsl:if test="not(key('namedTemplatesIndex', $template))">
			<xsl:call-template name="error">
				<xsl:with-param name="message" select="concat('No template named &quot;', $template, '&quot; exists, yet it', $apos, 's being called somewhere. ')" />
			</xsl:call-template>
			<xsl:if test="key('matchTemplatesIndex', $template)">
				<xsl:call-template name="error">
					<xsl:with-param name="message" select="'There is however, a *match template* defined with this name, so looks like a #snippetfail'" />
					<xsl:with-param name="linefeed" select="false()" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	
	<!--
	Output template for generating the error messages
	 -->
	<xsl:template name="error">
		<xsl:param name="message" />
		<xsl:param name="linefeed" select="true()" />
		<xsl:if test="$linefeed"><xsl:value-of select="$LF" /></xsl:if>
		<xsl:value-of select="$message" />
	</xsl:template>
	
</xsl:stylesheet>
