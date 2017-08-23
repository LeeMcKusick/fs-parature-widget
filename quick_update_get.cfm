<cftry>
<cfoutput>
<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!---
        CREATED: BLAKE EDDINS

        THIS IS THE QUICK TICKET UPDATE VIEW.  IT ALLOWS A PARATURE USERS
        TO EDIT SELECT FIELDS WITHOUT LEAVING THEIR CURRENT VIEW BY
        LEVERAGING THE WIDGET REALISTATE.

        THIS SCRIPT WAS BROKEN OUT SEPARATELY FROM THE OTHER WIDGET CODE
        SO IT COULD MAKE DIRECT CALLS TO THE PARATURE API ASYNCRONOUSLY.
        THE REST OF THE WIDGET WRITES AND READS A CACHED VERSION OF THE
        TICKET IN A DATABASE.  TICKET UPDATES SHOULD BE REAL TIME.
                                                                             --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->
<!--- ====================================================================== --->

    <style>
        ##ticket_update input {
            width:95%;
            height:100%;
        }
    </style>

    <!--- DEPENDS ON THE TICKET AND WEBSERVICE CFC AT THE ROOT LEVEL --->
    <cfparam name="url.ticketNumber" default="0" />

    <cfset parature = createObject("component", "ticket") />
    <cfset parature.sandbox = false />

    <cfset parature.init(
        ticket_id = #url.ticketNumber#
    ) />

    <cfset ticket = parature.ticket.ticket />

    <hr />

    <h1>Quick Updates</h1>

    <!--- Prepare Select Fields for Output --->
    <cfset select_fields = setFieldOptions(
        ticket = ticket,
        field_names = "Priority,Team"
    ) />

    <cfset cc_list = "" />
    <cfif structKeyExists(ticket, 'cc_csr')
      and structKeyExists(ticket.cc_csr, '##text')>
        <cfset cc_list = ticket.cc_csr['##text'] />
    </cfif>

    <cfset upsell = 'false'>
    <cfloop array="#ticket.Custom_Field#" index="cf">
      <cfscript>
        	if ( cf["@display-name"] IS "Upsell Opportunity") {
            try {
              upsell = cf["##text"];
            } catch (any e) {
              upsell = 'false';
            }
          }
      </cfscript>
    </cfloop>

    <form>
        <table>
            <tbody>

                <!--- LOOP THROUGH SELECT FIELDS --->
                <cfloop array="#select_fields#" index="select_field">
                    <tr>
                        <td class="tableLabel">#select_field.name#:</td>
                        <td>
                            <select name="#lcase(select_field.name)#_select">
                                <option>&nbsp;<option>

                                <!--- Loop through all options --->
                                <cfloop from="1" to="#select_field.size#" index="order">
                                    <option value="#select_field[order].id#"
                                            #select_field[order].selected#>#select_field[order].value#</option>
                                </cfloop>

                            </select>
                        </td>
                    </tr>
                </cfloop>

                <tr>
                    <td class="tableLabel">Snoozed Until:</td>
                    <td><input name="snoozed_until" type="input" class="datepicker" placeholder="mm/dd/yyyy" readonly></td>
                </tr>
                <tr>
                    <td class="tableLabel">Upsell Opportunity:</td>
                    <td><input name="upsell_opportunity" type="checkbox" <cfif upsell eq "true">checked</cfif>/></td>
                </tr>
                <!--- REMOVED BY BLAKE 12/26/2015
                <tr>
                    <td class="tableLabel">Email Me Client Responses:</td>
                    <td>
                        <input name="email" type="email" placeholder="Enter email address" />
                        <input name="cc_list" type="hidden" value="#cc_list#" />
                    </td>
                </tr>
                --->
                <tr>
                    <td></td>
                    <td><button style="width:100%">Update</button></td>
                </tr>
            </tbody>
        </table>
        <input type="hidden" name="ticket_id" value="#url.ticketNumber#" />
        <input type="hidden" name="customer_id" value="#ticket.ticket_customer.customer['@id']#" />
    </form>
    <cfif isDefined("url.dump")>
      <cfdump var="#ticket#">
    </cfif>
</cfoutput>
<cfcatch>
    <p>There was an error.  Try refreshing the page.</p>
</cfcatch>
</cftry>

<!--- ========================== --->
<!---   ORDER FIELD SELECTIONS   --->
<!--- ========================== --->
<cffunction name="setFieldOptions" output="false" returntype="array">
    <cfargument name="ticket" required="true" type="struct" />
    <cfargument name="field_names" required="true" type="string" />

    <cfset local.return = arrayNew(1) />

    <cfloop array="#ticket.custom_field#" index="custom_field">
        <cfif listFindNoCase(arguments.field_names, custom_field['@display-name'])>

            <cfset options = structNew() />
            <cfset size = 0 />

            <!--- Loop through all options for a field we want to output --->
            <cfloop array="#custom_field.option#" index="option">

                <!--- set field values for the html select --->
                <cfset options[option['@viewOrder']] = structNew() />
                <cfset options[option['@viewOrder']].id = option['@id'] />
                <cfset options[option['@viewOrder']].value = option.value />
                <cfset options[option['@viewOrder']].selected = "" />

                <cfif structKeyExists(option, '@selected')>
                    <cfset options[option['@viewOrder']].selected = "selected" />
                </cfif>

                <!--- set number of options --->
                <cfset size++ />

            </cfloop>

            <cfset options.name = custom_field['@display-name'] />
            <cfset options.size = size />
            <cfset arrayAppend(local.return, options) />

        </cfif>
    </cfloop>

    <cfreturn local.return />
</cffunction>
