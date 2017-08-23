<!---cfdev01 has a different datasource name for the rss DB.--->
<cfif FindNoCase( 'cfdev01' , cgi.server_name) gt 0 > 	
	<cfset ds = 'rss_cfauxsql03'>
<cfelse>
	<cfset ds = 'rss'>
</cfif>


<cfset useSandbox = false>
<cfif isDefined('URL.customerID') >
	
	<cfset cust = getCustomerInfo( URL.customerID ) >
	<cfdump var="#cust#">
<cfelse>
	<h1>Get Customer Data</h1>
	<p>Please enter the Parature CustomerID</p>
	<form>
		<input type="text" name="customerID" size="15" />
		<input type="submit" />
	</form>
</cfif>

<cffunction name="getCustomerInfo">
	<cfargument name="customerID">

	<cfquery name="getCustomer" datasource="#ds#">
	SELECT	customerID, firstName, lastName, email, accountID, finalsiteAdminID, finalsiteAdminUsername, finalsiteAdminGroup, vip, position, lastUpdated, sandbox, gender, phoneNumber, role
	FROM	parature_customers
	WHERE 	customerID = <cfqueryparam value="#URL.customerID#"> 
		and sandbox = <cfqueryparam value="#useSandbox#">;
	</cfquery>

	<cfscript>
	if ( getCustomer.RecordCount gt 0 ) {
		if  ( DateFormat(getCustomer.lastUpdated) neq DateFormat(Now()) ) {
			customer = updateCustomerData( URL.customerID );
		} else {
			customer = {};
			customer.id = getCustomer.customerID;
			customer.firstName = getCustomer.firstName;
			customer.lastName = getCustomer.lastName;
			customer.email = getCustomer.email;
			customer.accountID = getCustomer.accountID;
			customer.finalsiteAdminID = getCustomer.finalsiteAdminID;
			customer.finalsiteAdminUsername = getCustomer.finalsiteAdminUsername;
			customer.finalsiteAdminGroup = getCustomer.finalsiteAdminGroup;
			customer.vip = getCustomer.vip;
			customer.position = getCustomer.position;
			customer.gender = getCustomer.gender;
			customer.phone = getCustomer.phoneNumber;
			customer.role = getCustomer.role;
			customer.account = getAccountInfo( customer.accountID );
		}
	} else { 
		customer = updateCustomerData( URL.customerID );
	}
	
	return customer;
	</cfscript>

</cffunction>

<cffunction name="updateCustomerData">
	<cfargument name="custID" required="true">

	<cfset TICKET = createObject("component","global.parature.ticket") />
	<cfset TICKET.SANDBOX = useSandbox />
	<cfset customerData = TICKET.call('Customer', custID)>
	
	<!---<cfdump var="#customerData#">--->
	
	<cfscript>
	customer = {};
	if ( isDefined("customerData.Customer") ) {
		
		c = customerData.Customer;
		
		customer.id = custID;
		customer.firstName = c.First_Name["##text"];
		customer.lastName = c.Last_Name["##text"];
		customer.email = c.Email["##text"];
		customer.role = c.Customer_Role.CustomerRole.Name["##text"];
		customer.account = getAccountInfo( c.Account.Account["@id"] );
		
		customer.finalsiteAdminID = '';
		customer.finalsiteAdminUsername = '';
		customer.finalsiteAdminGroup =  '';
		customer.vip = '';
		customer.position = '';
		customer.gender = '';
		
		if ( isDefined( "c.Custom_Field" )) {
			for ( cf in c.Custom_Field ) {
				switch( cf["@display-name"] ) {
					case "Admin Username (finalsite)":
						try { customer.finalsiteAdminUsername = cf["##text"]; } catch (any e) { }
						break;
					case "Gender":
						try { customer.gender = cf["##text"]; } catch (any e) { }
						break;
					case "Admin Group (finalsite)":
						try { customer.finalsiteAdminGroup = cf["##text"]; } catch (any e) { }
						break;
					case "VIP Contact":
						try { customer.vip = cf["##text"]; } catch (any e) { customer.vip = false; }
						break;
					case "Admin ID (finalsite)":
						try { customer.finalsiteAdminID = cf["##text"]; } catch (any e) { }
						break;
					case "Position/Title":
						try { customer.position = cf["##text"]; } catch (any e) { }
						break;
					case "Telephone":
						try { customer.phone = cf["##text"]; } catch (any e) { }
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
					<cfqueryparam value="#customer.account.id#">,
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
		SELECT	accountID, accountName, keyword, url, server, address, city, state, zip, country, clientType, sla, projectManager, redirectIP, cdnEnabled, diskSpaceCurrent, diskSpaceMax, internalNotes, timeZone, lastUpdated, sandbox, phoneNumber, googleAccountID, accelerator
		FROM	parature_accounts
		WHERE 	accountID = <cfqueryparam value="#accountID#"> 
			and sandbox = <cfqueryparam value="#useSandbox#">;
	</cfquery>
	<cfscript>
	if ( getAccount.RecordCount gt 0 ) {
		if  ( DateFormat(getAccount.lastUpdated) neq DateFormat(Now()) ) {
			account = updateAccountData( accountID );
		} else {
			account = {};
			account.id = getAccount.accountID;
			account.name = getAccount.accountName;
			account.keyword = getAccount.keyword;
			account.url = getAccount.url;
			account.server = getAccount.server;
			account.address1 = getAccount.address;
			account.city = getAccount.city;
			account.state = getAccount.state;
			account.zip = getAccount.zip;
			account.country = getAccount.country;
			account.clientType = getAccount.clientType;
			account.sla = getAccount.sla;
			account.projectManager = getAccount.projectManager;
			account.redirectIP = getAccount.redirectIP;
			account.cdn = getAccount.cdnEnabled;
			account.diskSpaceUsed = getAccount.diskSpaceCurrent;
			account.diskSpaceMax = getAccount.diskSpaceMax;
			account.notes = getAccount.internalNotes;
			account.timeZone = getAccount.timeZone;
			account.phone = getAccount.phoneNumber;
			account.googleAccountID = getAccount.googleAccountID;
			account.accelerator = getAccount.accelerator;
		}
	} else { 
		account = updateAccountData( accountID );
	}
	
	return account;
	</cfscript>

	
</cffunction>

<!---
<cfset c = TICKET.call('Customer', URL.customerID)>
<cfset t = TICKET.call('Ticket', URL.ticketNum)>
--->
<!---<cfdump var="#a#">
<h1>Customer</h1>
<cfdump var="#c#">


<h1>Ticket</h1>
<cfdump var="#t#">--->

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


	
<cffunction name="updateAccountData">
	<cfargument name="accID" required="true">

	
	<cfset TICKET = createObject("component","global.parature.ticket") />
	<cfset TICKET.SANDBOX = useSandbox />
	<cfset accountData = TICKET.call('Account', accID)>
	<cfscript>
	
	account = {};
	account.id = accID;
	account.name = '';
	account.server = '';
	account.url = '';
	account.address1 = '';
	account.country = '';
	account.city = '';
	account.state = '';
	account.phone = '';
	account.zip = '';
	
	if ( IsDefined("accountData.Account") ) {
	
		acc = accountData.Account;
	
		if ( isDefined("acc.Account_Name") ) {
			account.name = acc.Account_Name["##text"];
		}
		if ( isDefined("acc.Sla") ) {
			account.sla = acc.Sla.Sla["@id"];
		}

		if ( isDefined( "acc.Custom_Field" )) {
			for ( cf in acc.Custom_Field ) {
				
				switch( cf["@display-name"] ) {
				
					case "Server Number":
						try { account.server = cf["##text"]; } catch (any e) { }
						break;
					case "Country":
						try { account.country = cf["##text"]; } catch (any e) { }
						break;
					case "Address1":
						try { account.address1 = cf["##text"]; } catch (any e) { }
						break;
					case "City":
						try { account.city = cf["##text"]; } catch (any e) { }
						break;
					case "Telephone":
						try { account.phone = cf["##text"]; } catch (any e) { }
						break;
					case "Zip Code":
						try { account.zip = cf["##text"]; } catch (any e) { }
						break;
					case "State/Province":
						account.state = getSelected( cf.Option );
						break;
				}

			}
		}
	}
	</cfscript>

	<cfquery name="siteInfo" dataSource="sites">
		SET ARITHABORT ON;
		SELECT 
			server,
			ds AS keyword, -- Data Source
			diskpercent, -- Disk Usage Percentage Used
			integrationInfo, -- Integration Notes
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
			/* SALESFORCE Data */
			sf_project_manager, -- Project Manager
			sf_support_comments, -- Anthonys Client Comments
			sf_hosting, -- Total Purchased Disk Space
			sf_billingCity,
			sf_billingState,
			sf_billingCountry,
			sf_acc_stage,
			redirectIP
			FROM sites inner join redirect on sites.redirectID = redirect.redirectID
			WHERE sitestats.value('(/sitestats//metaInfo/siteInfo/parature_account/node())[1]', 'varchar(300)') LIKE (<cfqueryparam value="#URL.accountID#">) AND sitename not like ('%Batch:%') and sitename not like ('%Enotify:%') AND sitename not like ('%ical:%') AND sitename not like ('%alert:%');
		</cfquery>
	
	<cfloop query="siteInfo">
		<cfscript>
		
			account.keyword = trim(siteInfo.keyword);
			account.diskSpaceUsed = trim(siteInfo.diskSpaceUsed);
			account.accelerator = trim(siteInfo.accelerator);
			account.notes = trim(siteInfo.internal_notes);
			account.url = trim(siteInfo.site_url);
			account.cdn = trim(siteInfo.cdn);
			account.googleAccountID = trim(siteInfo.ga_account);
			account.clientType = trim(siteInfo.clientType);
			account.projectManager = trim(siteInfo.sf_project_manager);
			account.redirectIP = trim(siteInfo.redirectIP);
			account.diskSpaceMax = trim(siteInfo.diskSpace);
			account.timeZone = trim(siteInfo.timeZone);
			
		
		</cfscript>
	</cfloop>
	
	<cfquery name="updateAccount" datasource="#ds#">
		IF NOT EXISTS (SELECT accountID FROM parature_accounts WHERE accountID = <cfqueryparam value="#account.id#"> and sandbox = <cfqueryparam value="#useSandbox#">)
			BEGIN
				INSERT INTO parature_accounts (
					accountID,
					accountName,
					keyword,
					url,
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
					sandbox,
					lastUpdated )
				VALUES (
					<cfqueryparam value="#account.id#">,
					<cfqueryparam value="#account.name#">,
					<cfqueryparam value="#account.keyword#">,
					<cfqueryparam value="#account.url#">,
					<cfqueryparam value="#account.server#">,
					<cfqueryparam value="#account.address1#">,
					<cfqueryparam value="#account.city#">,
					<cfqueryparam value="#account.state#">,
					<cfqueryparam value="#account.zip#">,
					<cfqueryparam value="#account.country#">,
					<cfqueryparam value="#account.clientType#">,
					<cfqueryparam value="#account.sla#">,
					<cfqueryparam value="#account.projectManager#">,
					<cfqueryparam value="#account.redirectIP#">,
					<cfqueryparam value="#account.cdn#">,
					<cfqueryparam value="#account.diskSpaceUsed#">,
					<cfqueryparam value="#account.diskSpaceMax#">,
					<cfqueryparam value="#account.notes#">,
					<cfqueryparam value="#account.timeZone#">,
					<cfqueryparam value="#account.phone#">,
					<cfqueryparam value="#account.googleAccountID#">,
					<cfqueryparam value="#account.accelerator#">,
					<cfqueryparam value="#useSandbox#">,
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				);
			END
			ELSE 
			BEGIN
				UPDATE parature_accounts
				SET
					accountName = <cfqueryparam value="#account.name#">,
					keyword = <cfqueryparam value="#account.keyword#">,
					url = <cfqueryparam value="#account.url#">,
					server = <cfqueryparam value="#account.server#">,
					address = <cfqueryparam value="#account.address1#">,
					city = <cfqueryparam value="#account.city#">,
					state = <cfqueryparam value="#account.state#">,
					zip = <cfqueryparam value="#account.zip#">,
					country = <cfqueryparam value="#account.country#">,
					clientType = <cfqueryparam value="#account.clientType#">,
					sla = <cfqueryparam value="#account.sla#">,
					projectManager = <cfqueryparam value="#account.projectManager#">,
					redirectIP = <cfqueryparam value="#account.redirectIP#">,
					cdnEnabled = <cfqueryparam value="#account.cdn#">,
					diskSpaceCurrent = <cfqueryparam value="#account.diskSpaceUsed#">,
					diskSpaceMax = <cfqueryparam value="#account.diskSpaceMax#">,
					internalNotes = <cfqueryparam value="#account.notes#">,
					timeZone = <cfqueryparam value="#account.timeZone#">,
					phoneNumber = <cfqueryparam value="#account.phone#">,
					googleAccountID = <cfqueryparam value="#account.googleAccountID#">,
					accelerator = <cfqueryparam value="#account.accelerator#">,
					lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				WHERE accountID = <cfqueryparam value="#account.id#"> and sandbox = <cfqueryparam value="#useSandbox#">;
			END
	</cfquery>
	<cfreturn account>
</cffunction>