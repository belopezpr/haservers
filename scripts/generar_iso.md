# registrar el comando ps1
`. <path del archivo ps1>\New-ISOFile.ps1`

# Generar archivo iso
## SourcePath: directorio que contiene los archivos meta-data, network-config, user-data
## Path: directorio donde queda el archivo iso
## VolumeName: etiqueta del archivo creado debe ser cidata
`New-ISOFile -SourcePath "C:\Users\Admin\Documents\Nomad\nomad-server-01\" -Path "C:\Users\Admin\Documents\Nomad\isos\test.iso" -VolumeName "cidata"`