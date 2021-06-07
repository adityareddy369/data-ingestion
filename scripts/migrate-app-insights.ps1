az extension add -n application-insights
az monitor app-insights component update --app dmp-appi-runway-build-001 -g rg-DMPEnterpriseDataIngestion-build-001 --workspace "/subscriptions/60b60000-6cbd-4c1b-94b3-2440bd6bbe00/resourcegroups/rg-dmpenterprisedataingestion-build-001/providers/microsoft.operationalinsights/workspaces/dmp-la-runway-build-001"
