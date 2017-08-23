<!---cfdev01 has a different datasource name for the rss DB.--->
<cfif FindNoCase( 'cfdev01' , cgi.server_name) gt 0 >
	<cfset ds = 'rss_cfauxsql03'>
<cfelse>
	<cfset ds = 'rss'>
</cfif>

<cfinclude template="cf/trello.cfm">

<cfset useSandbox = false>

<cfset myTicket = getTicketInfo( URL.ticketNumber ) >

<cfoutput>#SerializeJSON( myTicket )#</cfoutput>

<cffunction name="getTicketInfo">
	<cfargument name="ticketNumber">

	<cfquery name="getTicket" datasource="#ds#">
	SELECT	ticketNumber, customerID, dateCreated, dateUpdated, ticketStatus, summary, details, productFamily, ticketType, module, urgency, internalType, devNumber, team, priority, serviceType, assignedTo, relevantURL, upsell, sandbox, lastUpdated, queue, serviceDeskURL
	FROM	parature_tickets
	WHERE 	ticketNumber = <cfqueryparam value="#ticketNumber#">
		and sandbox = <cfqueryparam value="#useSandbox#">;
	</cfquery>

	<cfscript>
	if ( getTicket.RecordCount gt 0 ) {

			theTicket = {};
			theTicket["number"] = getTicket.ticketNumber;
			theTicket["customer"] = getCustomerInfo( getTicket.customerID );
			theTicket["dateCreated"] = getTicket.dateCreated;
			theTicket["dateUpdated"] = getTicket.dateUpdated;
			theTicket["status"] = getTicket.ticketStatus;
			theTicket["queue"] = getTicket.queue;
			theTicket["summary"] = getTicket.summary;
			theTicket["details"] = getTicket.details;
			theTicket["productFamily"] = getTicket.productFamily;
			theTicket["ticketType"] = getTicket.ticketType;
			theTicket["module"] = getTicket.module;
			theTicket["urgency"] = getTicket.urgency;
			theTicket["internalType"] = getTicket.internalType;
			theTicket["devNumber"] = getTicket.devNumber;
			theTicket["team"] = getTicket.team;
			theTicket["priority"] = getTicket.priority;
			theTicket["serviceType"] = getTicket.serviceType;
			theTicket["assignedTo"] = getTicket.assignedTo;
			theTicket["relevantURL"] = getTicket.relevantURL;
			theTicket["upsell"] = getTicket.upsell;
			theTicket["serviceDeskURL"] = getTicket.serviceDeskURL;
		
	} else {
		theTicket = updateTicketData( ticketNumber );
	}

	return theTicket;
	</cfscript>

</cffunction>

<cffunction name="updateTicketData">
	<cfargument name="ticketNum" required="true">

	<cfset PARATURETICKET = createObject("component","ticket") />
	<cfset PARATURETICKET.SANDBOX = useSandbox />
	<cfset ticketData = PARATURETICKET.call('Ticket', ticketNum)>

	<!---<cfdump var="#ticketData#">--->

	<cfscript>
	ticket = {};
	if ( isDefined("ticketData.Ticket") ) {

		t = ticketData.Ticket;

		ticket["number"] = ticketNum;
		ticket["customer"] = getCustomerInfo( t.Ticket_Customer.Customer["@id"] );
		ticket["dateCreated"] = t.Date_Created["##text"];
		ticket["dateUpdated"] = t.Date_Updated["##text"];
		ticket["status"] = t.Ticket_Status.Status.Name["##text"];
		ticket["serviceDeskURL"] = t['@service-desk-uri'];

		ticket["queue"] = '';
		if ( IsDefined('t.Ticket_Queue') ) {
			ticket["queue"] = t.Ticket_Queue.Queue.Name['##text'];
		}

		ticket["assignedTo"] = '';
		if ( IsDefined('t.Assigned_To') ) {
			ticket["assignedTo"] = t.Assigned_To.Csr.Full_Name["##text"];
		}

		ticket["summary"] = '';
		ticket["details"] = '';
		ticket["productFamily"] =  0;
		ticket["ticketType"] = 0;
		ticket["module"] = 0;
		ticket["urgency"] = 0;
		ticket["internalType"] = 0;
		ticket["devNumber"] = '';
		ticket["team"] = 0;
		ticket["priority"] = 0;
		ticket["serviceType"] = 0;
		ticket["relevantURL"] = '';
		ticket["relevantURL"] = '';
		ticket["upsell"] = false;

		if ( isDefined( "t.Custom_Field" )) {
			for ( cf in t.Custom_Field ) {
				switch( cf["@display-name"] ) {
					case "Summary":
						try { ticket["summary"] = cf["##text"]; } catch (any e) { }
						break;
					case "Details":
						try { ticket["details"] = cf["##text"]; } catch (any e) { }
						break;
					case "URL of Relevant Page":
						try { ticket["relevantURL"] = cf["##text"]; } catch (any e) { }
						break;
					case "Dev Number":
						try { ticket["devNumber"] = cf["##text"]; } catch (any e) { }
						break;
					case "Product Family":
						try { ticket["productFamily"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Ticket Type":
						try { ticket["ticketType"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Module":
						try { ticket["module"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Urgency":
						try { ticket["urgency"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Internal Type":
						try { ticket["internalType"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Team":
						try { ticket["team"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Priority":
						try { ticket["priority"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Service Type":
						try { ticket["serviceType"] = getSelectedID( cf.Option ); } catch (any e) { }
						break;
					case "Upsell opportunity":
						try { ticket["upsell"] = cf["##text"]; } catch (any e) { }
						break;
				}
			}
		}
	}
	</cfscript>

	<cfquery name="updateTicket" datasource="#ds#">
		IF NOT EXISTS (SELECT ticketNumber FROM parature_tickets WHERE ticketNumber = <cfqueryparam value="#ticket['number']#"> and sandbox = <cfqueryparam value="#useSandbox#">)
			BEGIN
				INSERT INTO parature_tickets (
					ticketNumber,
					customerID,
					dateCreated,
					dateUpdated,
					ticketStatus,
					summary,
					details,
					productFamily,
					ticketType,
					module,
					urgency,
					internalType,
					devNumber,
					team,
					priority,
					serviceType,
					assignedTo,
					relevantURL,
					upsell,
					queue,
					serviceDeskURL,
					sandbox,
					lastUpdated )
				VALUES (
					<cfqueryparam value="#ticket.number#">,
					<cfqueryparam value="#ticket.customer.id#">,
					<cfqueryparam value="#parseParatureDateFormat(ticket.dateCreated)#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#parseParatureDateFormat(ticket.dateUpdated)#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#ticket.status#">,
					<cfqueryparam value="#ticket.summary#">,
					<cfqueryparam value="#ticket.details#">,
					<cfqueryparam value="#ticket.productFamily#">,
					<cfqueryparam value="#ticket.ticketType#">,
					<cfqueryparam value="#ticket.module#">,
					<cfqueryparam value="#ticket.urgency#">,
					<cfqueryparam value="#ticket.internalType#">,
					<cfqueryparam value="#ticket.devNumber#">,
					<cfqueryparam value="#ticket.team#">,
					<cfqueryparam value="#ticket.priority#">,
					<cfqueryparam value="#ticket.serviceType#">,
					<cfqueryparam value="#ticket.assignedTo#">,
					<cfqueryparam value="#ticket.relevantURL#">,
					<cfqueryparam value="#ticket.upsell#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#ticket.queue#">,
					<cfqueryparam value="#ticket.serviceDeskURL#">,
					<cfqueryparam value="#useSandbox#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				);
			END
		ELSE
			BEGIN
				UPDATE parature_tickets
				SET
					customerID = <cfqueryparam value="#ticket.customer.id#">,
					dateCreated = <cfqueryparam value="#parseParatureDateFormat(ticket.dateCreated)#" cfsqltype="cf_sql_timestamp">,
					dateUpdated = <cfqueryparam value="#parseParatureDateFormat(ticket.dateUpdated)#" cfsqltype="cf_sql_timestamp">,
					ticketStatus = <cfqueryparam value="#ticket.status#">,
					summary = <cfqueryparam value="#ticket.summary#">,
					details = <cfqueryparam value="#ticket.details#">,
					productFamily = <cfqueryparam value="#ticket.productFamily#">,
					ticketType = <cfqueryparam value="#ticket.ticketType#">,
					module = <cfqueryparam value="#ticket.module#">,
					urgency = <cfqueryparam value="#ticket.urgency#">,
					internalType = <cfqueryparam value="#ticket.internalType#">,
					devNumber = <cfqueryparam value="#ticket.devNumber#">,
					team = <cfqueryparam value="#ticket.team#">,
					priority = <cfqueryparam value="#ticket.priority#">,
					serviceType = <cfqueryparam value="#ticket.serviceType#">,
					assignedTo = <cfqueryparam value="#ticket.assignedTo#">,
					relevantURL = <cfqueryparam value="#ticket.relevantURL#">,
					upsell = <cfqueryparam value="#ticket.upsell#" cfsqltype="cf_sql_bit">,
					queue = <cfqueryparam value="#ticket.queue#">,
					serviceDeskURL = <cfqueryparam value="#ticket.serviceDeskURL#">,
					lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				WHERE ticketNumber = <cfqueryparam value="#ticket.number#"> and sandbox = <cfqueryparam value="#useSandbox#" cfsqltype="cf_sql_bit">;
			END
	</cfquery>
	<cfreturn ticket>

</cffunction>



<cffunction name="getCustomerInfo">
	<cfargument name="customerID">

	<cfquery name="getCustomer" datasource="#ds#">
	SELECT	customerID, firstName, lastName, email, accountID, finalsiteAdminID, finalsiteAdminUsername, finalsiteAdminGroup, vip, position, lastUpdated, sandbox, gender, phoneNumber, role
	FROM	parature_customers
	WHERE 	customerID = <cfqueryparam value="#customerID#">
		and sandbox = <cfqueryparam value="#useSandbox#">;
	</cfquery>

	<cfscript>
	if ( getCustomer.RecordCount gt 0 ) {
		if  ( DateCompare( getCustomer.lastUpdated, Now(), ticketRefreshInterval ) eq -1 ) {
			customer = updateCustomerData( customerID );
		} else {
			customer = {};
			customer["id"] = getCustomer.customerID;
			customer["firstName"] = getCustomer.firstName;
			customer["lastName"] = getCustomer.lastName;
			customer["email"] = getCustomer.email;
			customer["accountID"] = getCustomer.accountID;
			customer["finalsiteAdminID"] = getCustomer.finalsiteAdminID;
			customer["finalsiteAdminUsername"] = getCustomer.finalsiteAdminUsername;
			customer["finalsiteAdminGroup"] = getCustomer.finalsiteAdminGroup;
			customer["vip"] = getCustomer.vip;
			customer["position"] = getCustomer.position;
			customer["gender"] = getCustomer.gender;
			customer["phone"] = getCustomer.phoneNumber;
			customer["role"] = getCustomer.role;
			customer["account"] = getAccountInfo( customer.accountID );
		}
	} else {
		customer = updateCustomerData( customerID );
	}

	return customer;
	</cfscript>

</cffunction>

<cffunction name="updateCustomerData">
	<cfargument name="custID" required="true">

	<cfset CUSTOMER = createObject("component","ticket") />
	<cfset CUSTOMER.SANDBOX = useSandbox />
	<cfset customerData = CUSTOMER.call('Customer', custID)>

	<!---<cfdump var="#customerData#">--->

	<cfscript>
	customer = {};
	if ( isDefined("customerData.Customer") ) {

		c = customerData.Customer;

		customer["id"] = custID;
		customer["firstName"] = c.First_Name["##text"];
		customer["lastName"] = c.Last_Name["##text"];
		customer["email"] = c.Email["##text"];
		customer["role"] = c.Customer_Role.CustomerRole.Name["##text"];


		if ( isDefined( "c.Account.Account" )) {

			customer["account"] = getAccountInfo( c.Account.Account["@id"] );
			customer["account"]["id"] = c.Account.Account["@id"];
		} else {
			customer["account"]["id"] = 0;
		}

		customer["finalsiteAdminID"] = '';
		customer["finalsiteAdminUsername"] = '';
		customer["finalsiteAdminGroup"] =  '';
		customer["vip"] = false;
		customer["position"] = '';
		customer["gender"] = '';
		customer["phone"] = '';

		if ( isDefined( "c.Custom_Field" )) {
			for ( cf in c.Custom_Field ) {
				switch( cf["@display-name"] ) {
					case "Admin Username (finalsite)":
						try { customer["finalsiteAdminUsername"] = cf["##text"]; } catch (any e) { }
						break;
					case "Gender":
						try { customer["gender"] = cf["##text"]; } catch (any e) { }
						break;
					case "Admin Group (finalsite)":
						try { customer["finalsiteAdminGroup"] = cf["##text"]; } catch (any e) { }
						break;
					case "VIP Contact":
						try { customer["vip"] = cf["##text"]; } catch (any e) { }
						break;
					case "Admin ID (finalsite)":
						try { customer["finalsiteAdminID"] = cf["##text"]; } catch (any e) { }
						break;
					case "Position/Title":
						try { customer["position"] = cf["##text"]; } catch (any e) { }
						break;
					case "Telephone":
						try { customer["phone"] = cf["##text"]; } catch (any e) { }
						break;
				}

			}
		}


	}



	</cfscript>

	<cfquery name="updateCustomer" datasource="#ds#">
		IF NOT EXISTS (SELECT customerID FROM parature_customers WHERE customerID = <cfqueryparam value="#customer.id#"> and sandbox = <cfqueryparam value="#useSandbox#">)
			BEGIN
				INSERT INTO parature_customers (
					customerID,
					firstName,
					lastName,
					email,
					accountID,
					finalsiteAdminID,
					finalsiteAdminUsername,
					finalsiteAdminGroup,
					vip,
					position,
					lastUpdated,
					sandbox,
					gender,
					phoneNumber,
					role )
				VALUES (
					<cfqueryparam value="#customer.id#">,
					<cfqueryparam value="#customer.firstName#">,
					<cfqueryparam value="#customer.lastName#">,
					<cfqueryparam value="#customer.email#">,
					<cfif IsDefined("customer.account.id")>
						<cfqueryparam value="#customer.account.id#">
					<cfelse>
						<cfqueryparam value="0">
					</cfif>,
					<cfqueryparam value="#customer.finalsiteAdminID#">,
					<cfqueryparam value="#customer.finalsiteAdminUsername#">,
					<cfqueryparam value="#customer.finalsiteAdminGroup#">,
					<cfqueryparam value="#customer.vip#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#customer.position#">,
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#useSandbox#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#customer.gender#">,
					<cfqueryparam value="#customer.phone#">,
					<cfqueryparam value="#customer.role#">
				);
			END
		ELSE
			BEGIN
				UPDATE parature_customers
				SET
					firstName = <cfqueryparam value="#customer.firstName#">,
					lastName = <cfqueryparam value="#customer.lastName#">,
					email = <cfqueryparam value="#customer.email#">,
					accountID = <cfqueryparam value="#customer.account.id#">,
					finalsiteAdminID = <cfqueryparam value="#customer.finalsiteAdminID#">,
					finalsiteAdminUsername = <cfqueryparam value="#customer.finalsiteAdminUsername#">,
					finalsiteAdminGroup = <cfqueryparam value="#customer.finalsiteAdminGroup#">,
					vip = <cfqueryparam value="#customer.vip#" cfsqltype="cf_sql_bit">,
					position = <cfqueryparam value="#customer.position#">,
					gender = <cfqueryparam value="#customer.gender#">,
					phoneNumber = <cfqueryparam value="#customer.phone#">,
					role = <cfqueryparam value="#customer.role#">,
					lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				WHERE customerID = <cfqueryparam value="#customer.id#"> and sandbox = <cfqueryparam value="#useSandbox#" cfsqltype="cf_sql_bit">;
			END
	</cfquery>

	<cfreturn customer>

</cffunction>


<cffunction name="getAccountInfo">
	<cfargument name="accountID">

	<cfquery name="getAccount" datasource="#ds#">
		SELECT	accountID, accountName, keyword, url, sf_url, server, address, city, state, zip, country, clientType, sla, projectManager, redirectIP, cdnEnabled, diskSpaceCurrent, diskSpaceMax, internalNotes, timeZone, lastUpdated, sandbox, phoneNumber, googleAccountID, accelerator, happiness, clientSuccessManager, theme, composer, composer_redesign, status, sfSIS, apply
		FROM	parature_accounts
		WHERE 	accountID = <cfqueryparam value="#accountID#">
			and sandbox = <cfqueryparam value="#useSandbox#">;
	</cfquery>
	<cfscript>
	account = {};
	if ( getAccount.RecordCount gt 0 ) {
		if  ( arguments.accountID eq 158697 ) {
			account = updateAccountData( arguments.accountID );
		} else {

		//if  ( DateFormat(getAccount.lastUpdated) neq DateFormat(Now()) ) {
			//account = updateAccountData( accountID );
		//} else {
			account = {};
			account["id"] = getAccount.accountID;
			account["name"] = getAccount.accountName;
			account["keyword"] = getAccount.keyword;
			account["url"] = getAccount.url;
			account["sf_url"] = getAccount.sf_url;
			account["server"] = getAccount.server;
			account["address1"] = getAccount.address;
			account["city"] = getAccount.city;
			account["state"] = getAccount.state;
			account["zip"] = getAccount.zip;
			account["country"] = getAccount.country;
			account["clientType"] = getAccount.clientType;
			account["sla"] = getAccount.sla;
			account["projectManager"] = getAccount.projectManager;
			account["redirectIP"] = getAccount.redirectIP;
			account["cdn"] = getAccount.cdnEnabled;
			account["diskSpaceUsed"] = getAccount.diskSpaceCurrent;
			account["diskSpaceMax"] = getAccount.diskSpaceMax;
			account["notes"] = getAccount.internalNotes;
			account["timeZone"] = getAccount.timeZone;
			account["phone"] = getAccount.phoneNumber;
			account["googleAccountID"] = getAccount.googleAccountID;
			account["accelerator"] = getAccount.accelerator;
			account["happiness"] = getAccount.happiness;
			account["clientSuccessManager"] = getAccount.clientSuccessManager;
			account["theme"] = getAccount.theme;
			account["composer"] = getAccount.composer;
			account["composer_redesign"] = getAccount.composer_redesign;
			account["status"] = getAccount.status;
			account["sis"] = getAccount.sfSIS;
			account["apply"] = getAccount.apply;
		}
	} else {
		//account = updateAccountData( accountID );
	}

	return account;
	</cfscript>

</cffunction>

<!---
<cfset c = PARATURETICKET.call('Customer', URL.customerID)>
<cfset t = PARATURETICKET.call('Ticket', URL.ticketNum)>
--->
<!---<cfdump var="#a#">
<h1>Customer</h1>
<cfdump var="#c#">


<h1>Ticket</h1>
<cfdump var="#t#">--->





<cffunction name="updateAccountData">
	<cfargument name="accID" required="true">

	<cfset ac = {} >


		<cfset ac['id'] = arguments.accID>

		<cfquery name="siteInfo" dataSource="sites">
			SET ARITHABORT ON;
			SELECT
				sitename,
				server,
				ds AS keyword, -- Data Source
				diskpercent, -- Disk Usage Percentage Used
				integrationInfo, -- Integration Notes
				sitestats,
				/*
				sitestats.value('(/sitestats//metaInfo/siteInfo/accelerator/node())[1]', 'bit') AS accelerator,
				sitestats.value('(/sitestats//metaInfo/siteInfo/clienttype/node())[1]', 'varchar(500)') AS clientType,
				sitestats.value('(/sitestats//metaInfo/siteInfo/internalnotes/node())[1]', 'varchar(5000)') AS internal_notes,
				sitestats.value('(/sitestats//metaInfo/siteInfo/url/node())[1]', 'varchar(200)') AS site_url,
				sitestats.value('(/sitestats//metaInfo/siteInfo/country/node())[1]', 'varchar(200)') AS country,
				sitestats.value('(/sitestats//metaInfo/siteInfo/cdn/node())[1]', 'varchar(200)') AS cdn, --CDN Enabled 1 or 0
				sitestats.value('(/sitestats//metaInfo/siteInfo/diskspace/node())[1]', 'int') AS diskspacetotal,
				sitestats.value('(/sitestats//metaInfo/siteInfo/ga_account/node())[1]', 'varchar(200)') AS ga_account,
				sitestats.value('(/sitestats//metaInfo/siteInfo/diskSpaceUsed/node())[1]', 'float') AS diskSpaceUsed,
				sitestats.value('(/sitestats//metaInfo/siteInfo/diskspace/node())[1]', 'int') AS diskSpace,
				sitestats.value('(/sitestats//metaInfo/siteInfo/timezoneid/node())[1]', 'varchar(200)') AS timeZone,

				*/
				/* SALESFORCE Data */
				sf_project_manager, -- Project Manager
				sf_support_comments, -- Anthonys Client Comments
				sf_hosting, -- Total Purchased Disk Space
				sf_billingCity,
				sf_billingState,
				sf_billingCountry,
				sf_billingStreet,
				sf_billingPostalCode,
				sf_phone,
				sf_account_owner,
				sf_website,
				sf_acc_stage,
				sf_client_gauge,
				sf_assets,
				composer,
				redirectIP
				FROM sites inner join redirect on sites.redirectID = redirect.redirectID
				WHERE sitestats.value('(/sitestats//metaInfo/siteInfo/parature_account/node())[1]', 'varchar(300)') LIKE (<cfqueryparam value="#ac['id']#">) AND sitename not like ('%Batch:%') and sitename not like ('%Enotify:%') AND sitename not like ('%ical:%') AND sitename not like ('%alert:%');
			</cfquery>
		<cfif siteInfo.RecordCount gt 0 >
			<cfloop query="siteInfo">
			<cfscript>

			/*Sitestats Manipulation*/
				stats = XmlParse(trim(siteInfo.sitestats));
				//mailMe(stats);

				ac['name'] = trim(siteInfo.sitename);
				ac['server'] = trim(siteInfo.server);
				ac['keyword'] = trim(siteInfo.keyword);
				ac['diskSpaceUsed'] = trim(siteInfo.diskSpaceUsed);
				ac['accelerator'] = trim(siteInfo.accelerator);
				ac['notes'] = trim(siteInfo.internal_notes);
				ac['url'] = trim(siteInfo.site_url);
				ac['sf_url'] = trim(LCase(siteInfo.sf_website));
				ac['cdn'] = trim(siteInfo.cdn);
				ac['sla'] = '';
				ac['phone'] = trim(siteInfo.sf_phone);
				ac['googleAccountID'] = trim(siteInfo.ga_account);
				ac['clientType'] = trim(siteInfo.clientType);
				ac['projectManager'] = trim(siteInfo.sf_project_manager);
				ac['redirectIP'] = trim(siteInfo.redirectIP);
				ac['diskSpaceMax'] = trim(siteInfo.diskSpace);
				ac['timeZone'] = trim(siteInfo.timeZone);
				ac['city'] = trim(siteInfo.sf_billingCity);
				ac['state'] = trim(siteInfo.sf_billingState);
				ac['country'] = trim(siteInfo.sf_billingCountry);
				ac['address1'] = trim(siteInfo.sf_billingStreet);
				ac['zip'] = trim(siteInfo.sf_billingPostalCode);
				ac['clientSuccessManager'] = trim(siteInfo.sf_account_owner);
				ac['happiness'] = trim(siteInfo.sf_client_gauge);
				ac['composer'] = siteInfo.composer;
				ac['theme'] = false;

				try {
					themes = XmlSearch( sf_assets, "//asset[ contains( name/text(), 'Theme-based') ]");
					if ( ArrayLen(themes) ) {
						ac['theme'] = true;
					}
				}	catch(any e) {

				}

			</cfscript>
		</cfloop>

		<cfquery name="updateAccount" datasource="#ds#">
			IF NOT EXISTS (SELECT accountID FROM parature_accounts WHERE accountID = <cfqueryparam value="#ac['id']#"> and sandbox = <cfqueryparam value="#useSandbox#">)
				BEGIN
					INSERT INTO parature_accounts (
						accountID,
						accountName,
						keyword,
						url,
						sf_url,
						server,
						address,
						city,
						state,
						zip,
						country,
						clientType,
						sla,
						projectManager,
						redirectIP,
						cdnEnabled,
						diskSpaceCurrent,
						diskSpaceMax,
						internalNotes,
						timeZone,
						phoneNumber,
						googleAccountID,
						accelerator,
						happiness,
						clientSuccessManager,
						theme,
						composer,
						sandbox,
						lastUpdated )
					VALUES (
						<cfqueryparam value="#ac['id']#">,
						<cfqueryparam value="#ac['name']#">,
						<cfqueryparam value="#ac['keyword']#">,
						<cfqueryparam value="#ac['url']#">,
						<cfqueryparam value="#ac['sf_url']#">,
						<cfqueryparam value="#ac['server']#">,
						<cfqueryparam value="#ac['address1']#">,
						<cfqueryparam value="#ac['city']#">,
						<cfqueryparam value="#ac['state']#">,
						<cfqueryparam value="#ac['zip']#">,
						<cfqueryparam value="#ac['country']#">,
						<cfqueryparam value="#ac['clientType']#">,
						<cfqueryparam value="#ac['sla']#">,
						<cfqueryparam value="#ac['projectManager']#">,
						<cfqueryparam value="#ac['redirectIP']#">,
						<cfqueryparam value="#ac['cdn']#">,
						<cfqueryparam value="#ac['diskSpaceUsed']#">,
						<cfqueryparam value="#ac['diskSpaceMax']#">,
						<cfqueryparam value="#ac['notes']#">,
						<cfqueryparam value="#ac['timeZone']#">,
						<cfqueryparam value="#ac['phone']#">,
						<cfqueryparam value="#ac['googleAccountID']#">,
						<cfqueryparam value="#ac['accelerator']#">,
						<cfqueryparam value="#ac['happiness']#">,
						<cfqueryparam value="#ac['clientSuccessManager']#">,
						<cfqueryparam value="#ac['theme']#">,
						<cfqueryparam value="#ac['composer']#">,
						<cfqueryparam value="#useSandbox#">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
					);
				END
				ELSE
				BEGIN
					UPDATE parature_accounts
					SET
						accountName = <cfqueryparam value="#ac['name']#">,
						keyword = <cfqueryparam value="#ac['keyword']#">,
						url = <cfqueryparam value="#ac['url']#">,
						sf_url = <cfqueryparam value="#ac['sf_url']#">,
						server = <cfqueryparam value="#ac['server']#">,
						address = <cfqueryparam value="#ac['address1']#">,
						city = <cfqueryparam value="#ac['city']#">,
						state = <cfqueryparam value="#ac['state']#">,
						zip = <cfqueryparam value="#ac['zip']#">,
						country = <cfqueryparam value="#ac['country']#">,
						clientType = <cfqueryparam value="#ac['clientType']#">,
						sla = <cfqueryparam value="#ac['sla']#">,
						projectManager = <cfqueryparam value="#ac['projectManager']#">,
						redirectIP = <cfqueryparam value="#ac['redirectIP']#">,
						cdnEnabled = <cfqueryparam value="#ac['cdn']#">,
						diskSpaceCurrent = <cfqueryparam value="#ac['diskSpaceUsed']#">,
						diskSpaceMax = <cfqueryparam value="#ac['diskSpaceMax']#">,
						internalNotes = <cfqueryparam value="#ac['notes']#">,
						timeZone = <cfqueryparam value="#ac['timeZone']#">,
						phoneNumber = <cfqueryparam value="#ac['phone']#">,
						googleAccountID = <cfqueryparam value="#ac['googleAccountID']#">,
						accelerator = <cfqueryparam value="#ac['accelerator']#">,
						happiness = <cfqueryparam value="#ac['happiness']#">,
						clientSuccessManager = <cfqueryparam value="#ac['clientSuccessManager']#">,
						theme = <cfqueryparam value="#ac['theme']#">,
						composer = <cfqueryparam value="#ac['composer']#">,
						lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
					WHERE accountID = <cfqueryparam value="#ac['id']#">
						and sandbox = <cfqueryparam value="#useSandbox#">;
				END
		</cfquery>
	</cfif>
	<cfreturn ac>
</cffunction>

<cffunction name="parseParatureDateFormat" output="false" returntype="String" hint="I return the date in a useable datebase date format.">
  <cfargument name="paratureDate" required="true" type="string" hint="The Parature date." />
  <cfset theDate = Replace(arguments.paratureDate, 'T', ' ')>
  <cfset theDate = Replace(theDate, 'Z', '')>
  <cfreturn CreateODBCDateTime(theDate) >
</cffunction>

<cffunction name="getSelected">
	<cfargument name="field">

	<cfset arrayIndex = -1>
	<cfloop from="1" to="#ArrayLen(field)#" index="counter">

		<cftry>
			<cfset test = field[counter]["@selected"]>
			<cfset arrayIndex = counter>
		<cfcatch>
		</cfcatch>
		</cftry>

	</cfloop>
	<cfif arrayIndex gt -1>
		<cfreturn trim(field[arrayIndex].Value) >
	<cfelse>
		<cfreturn '--'>
	</cfif>
</cffunction>

<cffunction name="getSelectedID">
	<cfargument name="field">

	<cfset arrayIndex = -1>
	<cfloop from="1" to="#ArrayLen(field)#" index="counter">

		<cftry>
			<cfset test = field[counter]["@selected"]>
			<cfset arrayIndex = counter>
		<cfcatch>
		</cfcatch>
		</cftry>

	</cfloop>
	<cfif arrayIndex gt -1>
		<cfreturn trim(field[arrayIndex]["@id"]) >
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction name="mailMe">
	<cfargument name="theText">

	<cfmail to="lee.mckusick@finalsite.com" from="widget@finalsite.com" subject="mail" type="html">
	<cfdump var="#arguments.theText#">
	</cfmail>
</cffunction>
