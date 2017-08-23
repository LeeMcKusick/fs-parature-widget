
<cfset kw = URL.keyword>
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
						
			sf_project_manager, -- Project Manager
			sf_support_comments, -- Anthonys Client Comments
			sf_hosting, -- Total Purchased Disk Space
			sf_billingCity,
			sf_billingState,
			sf_billingCountry,
			sf_billingStreet,
			sf_billingPostalCode,
			sf_account_owner,
			sf_acc_stage,
			sf_client_gauge,
			redirectIP 
			FROM sites inner join redirect on sites.redirectID = redirect.redirectID
			WHERE ds = (<cfqueryparam value="#kw#">) AND sitename not like ('%Batch:%') and sitename not like ('%Enotify:%') AND sitename not like ('%ical:%') AND sitename not like ('%alert:%');
		</cfquery>
	
	<cfset account = {} >
	
	<cfloop query="siteInfo">
		<cfscript>
		
			account['name'] = trim(siteInfo.sitename);
			account['server'] = trim(siteInfo.server);
			account['keyword'] = trim(siteInfo.keyword);
			account['diskSpaceUsed'] = trim(siteInfo.diskSpaceUsed);
			account['accelerator'] = trim(siteInfo.accelerator);
			account['notes'] = trim(siteInfo.internal_notes);
			account['url'] = trim(siteInfo.site_url);
			account['cdn'] = trim(siteInfo.cdn);
			account['googleAccountID'] = trim(siteInfo.ga_account);
			account['clientType'] = trim(siteInfo.clientType);
			account['projectManager'] = trim(siteInfo.sf_project_manager);
			account['redirectIP'] = trim(siteInfo.redirectIP);
			account['diskSpaceMax'] = trim(siteInfo.diskSpace);
			account['timeZone'] = trim(siteInfo.timeZone);
			account['city'] = trim(siteInfo.sf_billingCity);
			account['state'] = trim(siteInfo.sf_billingState);
			account['country'] = trim(siteInfo.sf_billingCountry);
			account['address1'] = trim(siteInfo.sf_billingStreet);
			account['zip'] = trim(siteInfo.sf_billingPostalCode);
			account['clientSuccess'] = trim(siteInfo.sf_account_owner);
			account['happiness'] = trim(siteInfo.sf_client_gauge);
			
		
		</cfscript>
	</cfloop>

<cfoutput>#SerializeJSON(account)#</cfoutput>