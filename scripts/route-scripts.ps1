$azureStaticWebAppconfigPath = './src/staticwebapp.config.json'
$azureStaticWebAppconfig = Get-Content -LiteralPath $azureStaticWebAppconfigPath | ConvertFrom-Json
# $roleName = 'optimizely_es'

function Add-AzureStaticWebAppRouteRole($routes, $routeName, $roleName) {
  $route = $routes | Where-Object { $_.name -eq $routeName }
  if ($route) {
    $route.allowedRoles += $roleName
  }
}

function Remove-AzureStaticWebAppRouteNames($routes) {
  $routes | ForEach-Object {
    if ($_.name) {
      $_.PSObject.Properties.Remove('name')
    }
  }
}

function Set-AzureStaticWebAppConfig() {
  $azureStaticWebAppconfig | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $azureStaticWebAppconfigPath
}

# Add-AzureStaticWebAppRouteRole -routes $azureStaticWebAppconfig.routes -routeName 'default' -roleName $roleName
# Add-AzureStaticWebAppRouteRole -routes $azureStaticWebAppconfig.routes -routeName 'defaultImages' -roleName $roleName
# Remove-AzureStaticWebAppRouteNames($azureStaticWebAppconfig.routes)

# Set-AzureStaticWebAppConfig