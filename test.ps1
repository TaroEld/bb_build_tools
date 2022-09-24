$preloadPath = "./template/scripts/!mods_preload/template.nut" 
$preloadFile = Get-Content "template_preload.nut" 
$name = "testmod"
$preloadFile[1] = "        ID = ""$name"""
$preloadFile