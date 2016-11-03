<?xml version="1.0" encoding="utf-8" ?>
<!--
	## XSLTLint.xslt
	
	Tests an XSLT file for some common (and frankly, embarrassing) errors.
-->
<!DOCTYPE xsl:stylesheet [
	<!ENTITY LF "&#x0a;">
	<!ENTITY TAB "&#x09;">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:make="http://exslt.org/common"
	exclude-result-prefixes="make"
>

	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />

	<xsl:key name="namedTemplatesIndex" match="xsl:template" use="@name" />
	<xsl:key name="matchTemplatesIndex" match="xsl:template" use="@match" />

	<!-- Global variables -->
	<xsl:variable name="apos">&apos;</xsl:variable>
	<xsl:variable name="quot">&quot;</xsl:variable>
	<xsl:variable name="LF" xml:space="preserve">&LF;&LF;</xsl:variable>

	<xsl:variable name="ns-prefixes-RTF">
		<xsl:for-each select="/*/namespace::*">
			<ns prefix="{local-name()}" url="{.}" />
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="ns-prefixes" select="make:node-set($ns-prefixes-RTF)/ns" />
	<xsl:variable name="no-go-chars" select="concat($apos, $quot, '/(;)=&amp;&lt;&gt;#€%!?+^`´@*\')" />
	
	<xsl:template match="/">
		<!--
		Start by testing some special cases
		-->
		<!-- Undeclared namespaces -->
		<xsl:apply-templates select="//@select[substring-before(., ':')][not(substring-before(., '::'))]" mode="undeclared-ns-prefix" />
		
		<!-- Now process the various elements in the stylesheet -->
		<xsl:apply-templates select="xsl:*" />
		
	</xsl:template>
	
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
	Or it could actually exist in an included/imported file.
	-->
	<xsl:template match="xsl:call-template">
		<xsl:variable name="template" select="@name" />
		<xsl:variable name="includes" select="/xsl:stylesheet/*[self::xsl:include or self::xsl:import]" />

		<xsl:if test="not(key('namedTemplatesIndex', $template))">
			<xsl:choose>
				<xsl:when test="$includes">
					<xsl:if test="not(document($includes/@href, /)//xsl:template[@name = $template])">
						<xsl:call-template name="error">
							<xsl:with-param name="message" select="concat('No template named &quot;', $template, '&quot; exists, yet it', $apos, 's being called somewhere. ')" />
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="error">
						<xsl:with-param name="message" select="concat('No template named &quot;', $template, '&quot; exists, yet it', $apos, 's being called somewhere. ')" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:if test="key('matchTemplatesIndex', $template)">
			<xsl:call-template name="error">
				<xsl:with-param name="message" select="'There is however, a *match template* defined with this name, so looks like a #snippetfail'" />
				<xsl:with-param name="linefeed" select="false()" />
			</xsl:call-template>
		</xsl:if>
		
		<!-- Check for misplaced `<xsl:param>` (where it should have been `<xsl:with-param>`) -->
		<xsl:if test="xsl:param">
			<xsl:call-template name="error">
				<xsl:with-param name="message" select="concat('A call to &quot;', $template, '&quot; contains misplaced `&lt;xsl:param&gt;` (you probably mean `&lt;xsl:with-param&gt;`).')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!--
	Check for namespace-prefixes that haven't been declared
	-->
	<xsl:template match="@select" mode="undeclared-ns-prefix">
		<xsl:variable name="prefix" select="substring-before(., ':')" />
		
		<!--
		Ideally, this should obviously be "properly" parsed, but we can eliminate a lot of false positives
		just by doing a little filtering - throw away all characters that shouldn't be used in a prefix
		and check if the string is still (probably) the same... 
		-->
		<xsl:if test="string-length($prefix) = string-length(translate($prefix, $no-go-chars, ''))">
			<!-- Go through the declared prefixes to find a match -->
			<xsl:if test="not($ns-prefixes[@prefix = $prefix])">
				<xsl:call-template name="error">
					<xsl:with-param name="message" select="concat('An undeclared namespace prefix (', $prefix, ':) is being used.')" />
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
