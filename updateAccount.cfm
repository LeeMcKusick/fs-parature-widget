<cfset accID = URL.account>
	
	<cfset ac = {} >
	

		<cfset ac['id'] = accID>
		
		<cfquery name="siteInfo" dataSource="sites">
			SET ARITHABORT ON;
			SELECT 
				sitename,
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
				sf_billingStreet,
				sf_billingPostalCode,
				sf_phone,
				sf_account_owner,
				sf_website,
				sf_acc_stage,
				sf_client_gauge,
				redirectIP
				FROM sites inner join redirect on sites.redirectID = redirect.redirectID
				WHERE sitestats.value('(/sitestats//metaInfo/siteInfo/parature_account/node())[1]', 'nvarchar(300)') LIKE (<cfqueryparam value="#ac['id']#">) AND sitename not like ('%Batch:%') and sitename not like ('%Enotify:%') AND sitename not like ('%ical:%') AND sitename not like ('%alert:%');
			</cfquery>
		<cfif siteInfo.RecordCount gt 0 > 	
			<cfloop query="siteInfo">
			<cfscript>
			
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
						lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
					WHERE accountID = <cfqueryparam value="#ac['id']#"> 
						and sandbox = <cfqueryparam value="#useSandbox#">;
				END
		</cfquery>
	</cfif>
