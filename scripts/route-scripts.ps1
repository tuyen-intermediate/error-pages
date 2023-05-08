$ErrorActionPreference = 'Stop'
$anonymousRole = 'anonymous'
$authenticatedRole = 'authenticated'

$azureStaticWebAppconfigPath = './src/staticwebapp.config.json'
$azureStaticWebAppconfig = Get-Content -LiteralPath $azureStaticWebAppconfigPath | ConvertFrom-Json -AsHashtable
# $roleName = 'optimizely_es'

function Get-AzureStaticWebAppRoute($routeName) {
  return $azureStaticWebAppconfig.routes | Where-Object { $_.route -eq $routeName }
}

function Add-AzureStaticWebAppRouteRole($routeName, $roleName) {
  $route = @{
    route        = '?';
    allowedRoles = "administrator", "tuyen_foundation";
    headers      = @{
      'Cache-Control' = 'no-cache'
    }
  }

  if ($routeName -eq 'defaultImages') {
    $route.route = '/*.{png,jpg,jpeg,gif,webp,tiff,mp4}'
    $route.headers['Cache-Control'] = 'public, max-age=31536000, immutable'

    if (($roleName -ne 'administrator') -and ($roleName -ne 'tuyen_foundation')) {
      $route.allowedRoles += $roleName
    }
    
    $azureStaticWebAppconfig.routes += $route;
    return;
  }

  if ($routeName -eq 'default') {
    $route.route = '/*'

    if (($roleName -ne 'administrator') -and ($roleName -ne 'tuyen_foundation')) {
      $route.allowedRoles += $roleName
    }
    
    $azureStaticWebAppconfig.routes += $route;
    return;
  }

  throw "Cannot found route '$routeName'"
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
  # Do nothing
}

function Set-AzureStaticWebAppRewritePath($code, $path) {
  $azureStaticWebAppconfig.responseOverrides[$code].rewrite = $path
}

function Set-AzureStaticWebAppConfig() {
  $isDefaultRouteExist = Get-AzureStaticWebAppRoute -route '/*'
  if (!$isDefaultRouteExist) {
    throw "Default route is not added."
  }

  Remove-AzureStaticWebAppRouteNames($azureStaticWebAppconfig.routes)
  $azureStaticWebAppconfig | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $azureStaticWebAppconfigPath -NoNewline
}

# Add-AdditionalAzureStaticWebAppRoutesFromPath -path './src/additional-routes.json'
# Add-GlobalAzureStaticWebAppRoutes
# Add-AzureStaticWebAppRouteRole -routeName 'default' -roleName $roleName
# Add-AzureStaticWebAppRouteRole -routeName 'defaultImages' -roleName $roleName

# Set-AzureStaticWebAppConfig