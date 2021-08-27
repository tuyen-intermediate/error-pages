$ErrorActionPreference = "Stop"

$azureStaticWebAppconfigPath = './src/staticwebapp.config.json'
$azureStaticWebAppconfig = Get-Content -LiteralPath $azureStaticWebAppconfigPath | ConvertFrom-Json
# $roleName = 'optimizely_es'

function Get-AzureStaticWebAppRoute($routeName) {
  return $azureStaticWebAppconfig.routes | Where-Object { $_.name -eq $routeName }
}

function Add-AzureStaticWebAppRouteRole($routeName, $roleName) {
  $route = $azureStaticWebAppconfig.routes | Where-Object { $_.name -eq $routeName }
  if ($route) {
    $route.allowedRoles += $roleName
  }
}

function Remove-AzureStaticWebAppRouteNames() {
  $azureStaticWebAppconfig.routes | ForEach-Object {
    if ($_.name) {
      $_.PSObject.Properties.Remove('name')
    }
  }
}

function Add-AdditionalAzureStaticWebAppRoutesFromPath($path) {
  $config = Get-Content -LiteralPath $path | ConvertFrom-Json
  $azureStaticWebAppconfig.routes += $config.routes;
}

function Add-GlobalAzureStaticWebAppRoutes() {
  $azureStaticWebAppconfig.routes += $azureStaticWebAppconfig.globalRoutes;

  $azureStaticWebAppconfig.PSObject.Properties.Remove('globalRoutes')
}

function Set-AzureStaticWebAppConfig() {
  $isDefaultRouteExist = Get-AzureStaticWebAppRoute -routeName 'default'
  if (!$isDefaultRouteExist) {
    throw "Default route is not added."
  }

  Remove-AzureStaticWebAppRouteNames($azureStaticWebAppconfig.routes)
  $azureStaticWebAppconfig | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $azureStaticWebAppconfigPath
}

# Add-AdditionalAzureStaticWebAppRoutesFromPath -path './src/additional-routes.json'
# Add-GlobalAzureStaticWebAppRoutes
# Add-AzureStaticWebAppRouteRole -routeName 'default' -roleName $roleName
# Add-AzureStaticWebAppRouteRole -routeName 'defaultImages' -roleName $roleName

# Set-AzureStaticWebAppConfig