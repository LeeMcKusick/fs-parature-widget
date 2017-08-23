<!---cfdev01 has a different datasource name for the rss DB.--->
<cfif FindNoCase( 'cfdev01' , cgi.server_name) gt 0 >
	<cfset ds = 'rss_cfauxsql03'>
<cfelse>
	<cfset ds = 'rss'>
</cfif>
<cfset useSandbox = false>


<!DOCTYPE html>
<html>
<head>
    <title>Finalsite Support Tools</title>
	<link type="text/css" rel="stylesheet" href="ui/css/custom-theme/jquery-ui-1.8.18.custom.css" />
	<link type="text/css" rel="stylesheet" href="ui/css/widget.css" />
	<link type="text/css" rel="stylesheet" href="ui/chosen/chosen.css" />


	<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
	<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
	<script src="ui/jquery-ui/jquery-ui.min.js"></script>
	<!---<script type="text/javascript" src="ZeroClipboard.js"></script>--->
	<script type="text/javascript" src="ui/js/jquery-replacetext-min.js"></script>
	<script type="text/javascript" src="ui/chosen/chosen.jquery.min.js"></script>


	<script src="ui/js/scripts.js?5262016"></script>
</head>
<body>

	<div id="tabs">
		<ul>
			<li><a href="#tabs-1">Home</a></li>
			<li><a href="#tabs-2">Account</a></li>

			<li><a href="#tabs-3">Client</a></li>
			<!---
			<li><a href="#tabs-3">Modules</a></li>
			<li><a href="#tabs-4">Tickets</a></li>
			--->
			<li><a href="#tabs-5">Tools</a></li>
			<li><a href="#tabs-6">DNS</a></li>

		</ul>

	<cfoutput>
		<div id="tabs-1">
			<!---
			<div id="copyNameContainer">
				<h1 class="clientName">---</h1>
				<img id="genderSymbol" src="icons/FemaleSymbol.png" />
			</div>

			<h3 class="accountName">---</h3>
			--->
			<table>
				<tbody>
					<tr><td class="tableLabel">Location:</td><td><span class="state"></span>, <span class="country">---</span> (<span class="timeZone"></span>)</td></tr>
					<tr><td class="tableLabel">Server:</td><td><span id="server"><b>---</b></span> (<span class="keyword">---</span>)</span></td></tr>

					<tr><td class="tableLabel">URL:</td><td><a id="siteURL" href="http://finalsite.com" target="_blank">finalsite.com</a> | <a id="adminURL" href="http://finalsite.com/admin/fs" target="_blank"><button>admin/fs</button></a></span></td></tr>

					<tr><td class="tableLabel">Age (BH):</td><td><span id="age">---</span></td></tr>
					<tr><td class="tableLabel">Customer ID:</td><td><span class="customerID">---</span></td></tr>
					<tr><td class="tableLabel">Tags:</td>
					<td>
						<span class="tag" id="composerTag">Composer</span>
						<span class="tag" id="redesignTag"><a class="redesignLink" href="http://keyword.redesign.finalsite.com/admin/fs" target="_blank">Composer Redesign</a></span>
						<span class="tag" id="themeTag">Theme Site</span>
						<span class="tag" id="cdnDisabledTag">CDN Disabled</span>
						<span class="tag" id="lowDiskSpaceTag">Low Disk Space</span>
						<span class="tag" id="acceleratorTag">Akamai Accelerator</span>
						<span class="tag" id="associationTag">Association</span>
						<span class="tag" id="sisTag">SIS</span>
						<span class="tag" id="applyTag"><a class="applyLink" href="http://keyword.finalsiteapply.com/" target="_blank">Apply</a></span>
					</td></tr>
				</tbody>
			</table>



			<br>
			<div id="parajiraLinks">
				<a id="parajiraBugLink" href="http://staff.finalsite.com/custom/parajira/" target="_blank"><button>Create Bug</button></a> |
				<a id="parajiraERQLink" href="http://staff.finalsite.com/custom/parajira/" target="_blank"><button>Create ERQ</button></a>
			</div>

			<br>

			<button class="copyLink" id="copyNum"></button>
			<button class="copyLink" id="copyGit"></button>

			<!--- ADDED BY BLAKE 2015-08-16 FOR QUICK UPDATES BY TEAM MEMBERS
            ASYNCRONOUSLY LOADS TICKET UPDATE VIEW --->
			<div id="ticket_update">
				<div style="margin:10px">
					...loading quick update...
				</div>
			</div>

		</div>


		<div id="tabs-2">
			<h3 class="accountName">---</h3>
			<table>
				<tbody>
					<tr><td class="tableLabel">Address:</td><td><span id="address">---</span><br><span id="city">---</span>, <span class="state">---</span>, <span id="zip">---</span>, <span class="country">---</span></td></tr>
					<tr><td class="tableLabel">Project Manager:</td><td><span id="projectManager">---</span></td></tr>
					<tr><td class="tableLabel">Client Success Manager:</td><td><span class="clientSuccessManager">---</span></td></tr>
					<tr><td class="tableLabel">Happiness:</td><td><span class="happiness"></span></td></tr>
					<tr><td class="tableLabel">Disk Space:</td><td><span id="diskSpace">---</span></td></tr>
					<tr><td class="tableLabel">CDN Enabled?</td><td><span id="cdn">---</span></td></tr>
					<tr><td class="tableLabel">Accelerator?</td><td><span id="accelerator">---</span></td></tr>
					<tr><td class="tableLabel">Google Analytics ID</td><td><span id="googleAccountID">---</span></td></tr>
					<tr><td class="tableLabel">Parature ID:</td><td><span id="paratureID">---</span></td></tr>

				</tbody>
			</table>

			<h3>Internal Notes</h3>
			<div id="internalNotes">None entered.</div>
		</div>


		<div id="tabs-3">
			<table>
				<tbody>
					<h1 class="clientName">---</h1>
					<tr><td class="tableLabel">School:</td><td><span class="accountName">---</span></td></tr>
					<tr><td class="tableLabel">Position/Title:</td><td><span class="position">---</span></td></tr>
					<tr><td class="tableLabel">Phone</td><td><span class="phone">---</span></td></tr>
					<tr><td class="tableLabel">FS Admin ID:</td><td><span class="finalsiteAdminID">---</span></td></tr>
					<tr><td class="tableLabel">FS Admin Username:</td><td><span class="finalsiteAdminUsername">---</span></td></tr>
					<tr><td class="tableLabel">FS Admin Group:</td><td><span class="finalsiteAdminGroup">---</span></td></tr>
					<tr><td class="tableLabel">VIP?</td><td><span class="vip">---</span></td></tr>
					<tr><td class="tableLabel">Parature Account Role:</td><td><span class="role">---</span></td></tr>
				</tbody>
			</table>
		</div>


		<div id="tabs-5">

			<h3>Tools</h3>
			<a href="##" id="appVariablesLink" target="_blank">AppVariables</a>

			<h3>Database Restores</h3>
			<ul class="indented">
				<li><a href="http://cfdev03/devtools/restore/?sqlserver=CFSQL16" id="dbRestoreLinkDaily" target="_blank">Daily for Server</a></li>
				<li><a href="http://cfdev03/devtools/restore/?sqlserver=CFSQL16&backuptype=hourly" target="_blank" id="dbRestoreLinkHourly">Hourly for Server</a></li>
			</ul>

			<h3>Support Details</h3>
			<a href="http://www.supportdetails.com" id="supportDetailsLink" target="_blank">http://www.supportdetails.com</a>

			<h3>Clear Coldfusion Server Cache</h3>
			<a href="http://cfaux01/dectools/clearcache" id="clearCacheLink" target="_blank">Clear Cache</a>

			<h3>Site Errors</h3>
			<a href="http://cfaux01/devtools/errors/" target="_blank" id="siteErrorLink">Site Errors</a>
		</div>

		<div id="tabs-6">
			<p>The A record for <b><span class="publicURL"></span></b> must point to <b><span class="redirectIP">184.X.X.X</span></b>.</p>
			<p>The CNAME for <b>www.<span class="publicURL"></span></b> must point to <b><span class="keyword">schoolname</span>.finalsite.com</b>. Please do NOT use an A record for www.<span class="publicURL"></span>.</p>
			<p>Any additional subdomains used for your website must use a CNAME that points to <span class="keyword">schoolname</span>.finalsite.com.</p>
			<p>Any additional domains that point to your Finalsite website should follow the above protocol.</p>

			</ul>
			<br/>
			<h3>Client Template:</h3>


			<p>We will use <b><span class="publicURL"></span></b> as your primary site URL and as the SSL certificate identity. Please use the instructions below to configure the DNS records for this domain, as well as any other hosts/subdomains you may want to create.</p>
			<p>There are two updates that you need to perform to your DNS record: one is in relation to the domain name's main A record, the other is to the www CNAME record. A records only point to IP addresses. CNAME records (also known as alias records) point to other hostnames.
			<p>
				<b>A Record</b></p>
				<p><ul class="indented">
					<li>Change the A record for your root domain (<b><span class="publicURL"></span></b>) to be <b><span class="redirectIP">184.X.X.X</span></b></li>
				</ul>
			</p>
			<p>
				<b>CNAME Record</b></p>
				<p><ul class="indented">
					<li>Locate the www record for your domain and change it to a CNAME record that points to <b><span class="keyword">schoolname</span>.finalsite.com.</b></li>
				</ul>
			</p>
			<p>(Please note that some domain name providers, such as Network Solutions, will suggest that an A record for www be added instead of a CNAME record. You will need to first remove this A record if it exists, and create the CNAME record.)</p>
			<p>Also, if there are internal and/or private DNS servers at your facilities that provide addresses for other resources within your domain (Active Directory, etc), these will also need to be updated at the same time.</p>
		</div>

	</div>
	</cfoutput>

	<br><br>

	<div id="serverData"></div>


	<div id="loadingDiv" style="display:none !important"></div>
	<!---<cfdump var="#a#">--->


<!---
<cfquery name="getCustomerInfo" datasource="#ds#">
	SELECT      keyid, parature_customerid, sla, customer_email, customer_phone, firstname, lastname, finalsite_adminid, parature_accountid, parature_accountname
	FROM            parature_account
	WHERE parature_customerid = <cfqueryparam value="#URL.customerID#">
</cfquery>
<p>#getCustomerInfo.parature_accountname#</p>
--->

<!---

<cfdump var="#getCustomerInfo#">
--->

<body>
<html>
