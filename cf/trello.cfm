<cfset trello = createObject('component', 'web_service') />
<cfset trelloSettings = trello.call('lists/5579a9bb5e73ca758cee2083/cards')>

<cfloop array="#trelloSettings#" index="i">
	<cfset VARIABLES['' & i.name] = i.desc>
</cfloop>