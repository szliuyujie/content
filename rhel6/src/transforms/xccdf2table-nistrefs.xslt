<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1">

<!-- this style sheet expects parameter $profile, which is the id of the Profile to be shown -->

	<xsl:template match="/">
		<html>
		<head>
			<title><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></title>
		</head>
		<body>
			<br/>
			<br/>
			<div style="text-align: center; font-size: x-large; font-weight:bold"><xsl:value-of select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:title" /></div>
			<br/>
			<br/>
			<xsl:apply-templates select="cdf:Benchmark"/>
		</body>
		</html>
	</xsl:template>


	<xsl:template match="cdf:Benchmark">
		<style type="text/css">
		table
		{
			border-collapse:collapse;
		}
		table,th, td
		{
			border: 1px solid black;
			vertical-align: top;
			padding: 3px;
		}
		thead
		{
			display: table-header-group;
			font-weight: bold;
		}
		</style>
		<table>
			<thead>
				<td>CCE ID</td>
				<td>Rule Title</td>
				<td>Description</td>
				<td>Rationale</td>
				<td>Variable Setting</td>
				<td>NIST 800-53 Mapping</td>
			</thead>

		<xsl:call-template name="profileplate">
			<xsl:with-param name="profileid" select="$profile" />
		</xsl:call-template>
		</table>
	</xsl:template>

	<!-- recursively-called, to handle Profile "extends" behavior -->
	<xsl:template match="cdf:Profile" name="profileplate">
		<xsl:param name="profileid" />
		<xsl:comment> Entered Profile: <xsl:value-of select="$profileid" />	 </xsl:comment>

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profileid]">
		<xsl:if test="@extends">
			<xsl:variable name="extendedprofile" select="@extends" />
			<xsl:call-template name="profileplate">
				<xsl:with-param name="profileid" select="$extendedprofile" />
			</xsl:call-template>
		</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profileid]/cdf:select">
			<xsl:variable name="idrefer" select="@idref" />
			<xsl:variable name="enabletest" select="@selected" />
			<xsl:for-each select="/cdf:Benchmark/cdf:Group">
				<xsl:call-template name="groupplate">
					<xsl:with-param name="idreference" select="$idrefer" />
					<xsl:with-param name="enabletest" select="$enabletest" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="cdf:Group" name="groupplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />

		<!-- Group cdf:title -->
		<xsl:for-each select="cdf:Group">
			<xsl:call-template name="groupplate">
				<xsl:with-param name="idreference" select="$idreference" />
				<xsl:with-param name="enabletest" select="$enabletest" />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="cdf:Rule">
			<xsl:call-template name="ruleplate">
				<xsl:with-param name="idreference" select="$idreference" />
				<xsl:with-param name="enabletest" select="$enabletest" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="cdf:Rule" name="ruleplate">
		<xsl:param name="idreference" />
		<xsl:param name="enabletest" />
		<xsl:if test="@id=$idreference and $enabletest='true'">
		<tr>
			<td> <xsl:value-of select="cdf:ident" /></td>
			<td> <xsl:value-of select="cdf:title" /></td>
			<td> <xsl:copy-of select="cdf:description"/> </td>
			<td> <xsl:value-of select="cdf:rationale"/> </td>
			<td> <!-- TODO: print refine-value from profile associated with rule --> </td>
			<!-- select the desired reference via href attribute.  here, NIST. -->
			<td> 
<!--			<xsl:apply-templates select="cdf:reference[@href=http://csrc.nist.gov/publications/nistpubs/800-53-Rev3/sp800-53-rev3-final-errata.pdf]"/>-->
			<xsl:apply-templates select="cdf:reference"/>
			</td> 

		</tr>
		</xsl:if>
	</xsl:template>


	<xsl:template match="cdf:check">
		<xsl:for-each select="cdf:check-export">
			<xsl:variable name="rulevar" select="@value-id" />
				<!--<xsl:value-of select="$rulevar" />:-->
				<xsl:for-each select="/cdf:Benchmark/cdf:Profile[@id=$profile]/cdf:refine-value">
					<xsl:if test="@idref=$rulevar">
						<xsl:value-of select="@selector" />
					</xsl:if>
				</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="cdf:reference">
		<!-- adjust for the desired reference here -->
		<xsl:value-of select="." />
	</xsl:template>

</xsl:stylesheet>
