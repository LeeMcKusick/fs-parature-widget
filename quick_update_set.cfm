<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!---

        CREATED: BLAKE EDDINS

        THIS IS THE QUICK TICKET UPDATE SET VIEW.  IT CONSUMES THE DATA
        FROM THE QUICK UPDATE GET VIEW AND PASSES TO PARATURE FOR UPDATE.

                                                                             --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->

<cfset ticket = createObject("component", "ticket") />
<cfset ticket.sandbox = false />

<cfparam name="url.priority_select" default="" />
<cfparam name="url.team_select" default="" />
<cfparam name="url.snoozed_until" default="" />
<cfparam name="url.email" default="" />
<cfparam name="url.cc_list" default="" />
<cfparam name="url.upsell_opportunity" default="" />

<cfset fields = arrayNew(1) />

<!--- TEAM FIELD --->
<cfif len(url.team_select)>

    <cfset arrayAppend(fields,
        "<Custom_Field id='113064'>#url.team_select#</Custom_Field>") />

</cfif>

<!--- PRIORITY FIELD --->
<cfif len(url.priority_select)>

    <cfset arrayAppend(fields,
        "<Custom_Field id='113065'>#url.priority_select#</Custom_Field>") />

</cfif>

<!--- SNOOZED UNTIL FIELD --->
<cfif len(snoozed_until)
  and isDate(snoozed_until)>

    <cfset arrayAppend(fields,
        "<Custom_Field id='113069'>#dateFormat(url.snoozed_until, 'yyyy-mm-dd')#T00:00:00</Custom_Field>") />

</cfif>

<!--- CC LIST FIELD --->
<cfif len(url.email)
  and not findNoCase(url.email,url.cc_list)>

    <cfif len(url.cc_list)>
        <cfset url.email = "#url.cc_list#,#url.email#" />
    </cfif>

    <cfset arrayAppend(fields,
        "<Cc_Csr>#url.email#</Cc_Csr>") />

</cfif>


<cfif len(url.upsell_opportunity) and url.upsell_opportunity eq 'on'>
    <cfset arrayAppend(fields,
      "<Custom_Field id='112266'>true</Custom_Field>") />
<cfelse>
  <cfset arrayAppend(fields,
    "<Custom_Field id='112266'>false</Custom_Field>") />
</cfif>

<!--- EDIT THE TICKET --->
<cfset response = ticket.edit(
    ticket_id = url.ticket_id,
    customer_id = url.customer_id,
    fields = fields
) />

<cfdump var="#response#" />
