<?xml version="1.0" encoding="UTF-8"?>
<ctl:package xmlns:ctl="http://www.occamlab.com/ctl" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tns="http://www.opengis.net/cite/nsg/wmts"
  xmlns:saxon="http://saxon.sf.net/" 
  xmlns:tec="java:com.occamlab.te.TECore" 
  xmlns:tng="java:org.opengeospatial.cite.wmts10.nsg.WmtsNSGTestNGController">

  <ctl:function name="tns:run-ets-${ets-code}">
    <ctl:param name="testRunArgs">A Document node containing test run arguments (as XML properties).</ctl:param>
    <ctl:param name="outputDir">The directory in which the test results will be written.</ctl:param>
    <ctl:return>The test results as a Source object (root node).</ctl:return>
    <ctl:description>Runs the NSG WMTS 1.0 (${version}) test suite.</ctl:description>
    <ctl:code>
      <xsl:variable name="controller" select="tng:new($outputDir)" />
      <xsl:copy-of select="tng:doTestRun($controller, $testRunArgs)" />
    </ctl:code>
  </ctl:function>

  <ctl:suite name="tns:ets-${ets-code}-${version}">
    <ctl:title>NSG WMTS 1.0 Conformance Test Suite</ctl:title>
    <ctl:description>Checks NSG WMTS 1.0 implementations for conformance to NSG WMTS 1.0</ctl:description>
    <ctl:starting-test>tns:Main</ctl:starting-test>
  </ctl:suite>

  <ctl:test name="tns:Main">
    <ctl:assertion>The test subject satisfies all applicable constraints.</ctl:assertion>
    <ctl:code>
      <xsl:variable name="form-data">
        <ctl:form method="POST" width="800" height="600" xmlns="http://www.w3.org/1999/xhtml">
          <h2>NSG WMTS 1.0 Conformance Test Suite</h2>
          <div style="background:#F0FF88" bgcolor="#F0FF88">
            <fieldset style="background:#ccffff">
              <legend
                style="font-family: sans-serif; color: #000099; 
			   background-color:#F0F8FF; border-style: solid; border-width: medium; padding:4px">
                Implementation under test
              </legend>
              <p>
                <label for="wmts-uri">
                  <h4 style="margin-bottom: 0.5em">Location of WMTS ServiceMetadata Capabilities document (http: or file: URI)</h4>
                </label>
                <input id="wmts-uri" name="wmts-uri" size="96" type="text" value="" />
              </p>
            </fieldset>
          </div>
          <p>
            <input class="form-button" type="submit" value="Start" />
            |
            <input class="form-button" type="reset" value="Clear" />
          </p>
        </ctl:form>
      </xsl:variable>
      <xsl:variable name="test-run-props">
        <properties version="1.0">
          <entry key="wmts">
            <xsl:value-of select="normalize-space($form-data/values/value[@key='wmts-uri'])" />
          </entry>
        </properties>
      </xsl:variable>
      <xsl:variable name="testRunDir">
        <xsl:value-of select="tec:getTestRunDirectory($te:core)" />
      </xsl:variable>
      <xsl:variable name="test-results">
        <ctl:call-function name="tns:run-ets-${ets-code}">
          <ctl:with-param name="testRunArgs" select="$test-run-props" />
          <ctl:with-param name="outputDir" select="$testRunDir" />
        </ctl:call-function>
      </xsl:variable>
      <xsl:call-template name="tns:testng-report">
        <xsl:with-param name="results" select="$test-results" />
        <xsl:with-param name="outputDir" select="$testRunDir" />
      </xsl:call-template>
      <xsl:variable name="summary-xsl" select="tec:findXMLResource($te:core, '/testng-summary.xsl')" />
      <ctl:message>
        <xsl:value-of select="saxon:transform(saxon:compile-stylesheet($summary-xsl), $test-results)" />
        See detailed test report in the TE_BASE/users/
        <xsl:value-of select="concat(substring-after($testRunDir, 'users/'), '/html/')" />
        directory.
      </ctl:message>
      <xsl:if test="xs:integer($test-results/testng-results/@failed) gt 0">
        <xsl:for-each select="$test-results//test-method[@status='FAIL' and @description='prerequisite']">
          <ctl:message>
            Test prerequisite
            <xsl:value-of select="./@name" />
            failed:
            <xsl:value-of select=".//message" />
          </ctl:message>
        </xsl:for-each>
        <xsl:for-each select="$test-results//test-method[@status='FAIL' and not(@is-config='true')]">
          <ctl:message>
            Test method
            <xsl:value-of select="./@name" />
            :
            <xsl:value-of select=".//message" />
          </ctl:message>
        </xsl:for-each>
        <ctl:fail />
      </xsl:if>
    </ctl:code>
  </ctl:test>

  <xsl:template name="tns:testng-report">
    <xsl:param name="results" />
    <xsl:param name="outputDir" />
    <xsl:variable name="stylesheet" select="tec:findXMLResource($te:core, '/testng-report.xsl')" />
    <xsl:variable name="reporter" select="saxon:compile-stylesheet($stylesheet)" />
    <xsl:variable name="report-params" as="node()*">
      <xsl:element name="testNgXslt.outputDir">
        <xsl:value-of select="concat($outputDir, '/html')" />
      </xsl:element>
    </xsl:variable>
    <xsl:copy-of select="saxon:transform($reporter, $results, $report-params)" />
  </xsl:template>
</ctl:package>