<!---cfdev01 has a different datasource name for the rss DB.--->
<cfif FindNoCase( 'cfdev01' , cgi.server_name) gt 0 > 	
	<cfset ds = 'rss_cfauxsql03'>
<cfelse>
	<cfset ds = 'rss'>
</cfif>

<cfset TICKET = createObject("component","global.parature.ticket") />
<cfset TICKET.SANDBOX = useSandbox />
<cfset accountData = TICKET.call('Account', accID)>