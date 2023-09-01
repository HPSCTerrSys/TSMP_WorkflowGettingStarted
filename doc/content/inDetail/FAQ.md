# FAQ

## Update of the documentation does not show up on website

If your update to the documentation but this update does not show up in the online documentation, in most cases you can fix this by doing one of the following.   

1. Clear your browser cache. Sometimes your browser caches a web page to increase the speed at which a web page loads. If the browser does not notice that the original page has been updated, the browser will show you the old page and you will not see your changes. If this happens, clear your browser's cache using your browser's settings.
2. The automatic rendering and deployment process of the GitHub workflows does not delete the old rendered document, it overwrites it. This sometimes causes an error, especially when new pages are added to the documentation. While the cause of this behaviour is not clear, you can work around it by manually triggering the [RenderCleanMasterSphinxDocumentation](https://github.com/HPSCTerrSys/TSMP_WorkflowGettingStarted/actions/workflows/RenderCleanMainSphinxDocumentation.yml) workflow by clicking `run workflow` and applying it to the `main` branch. This workflow is the same as the normal workflow, but specifically deletes the contents of the `gh-page` branch before rendering.