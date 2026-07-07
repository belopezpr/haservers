if (-not ([System.Management.Automation.PSTypeName]'ISOFileStreamHelper').Type) {
    $cSharpCode = @"
    using System;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Runtime.InteropServices.ComTypes;

    public class ISOFileStreamHelper {
        public static void WriteStreamToFile(object comStream, string filePath) {
            IStream srcStream = (IStream)comStream;
            using (FileStream destStream = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.None)) {
                byte[] buffer = new byte[1048576]; 
                IntPtr bytesReadPtr = Marshal.AllocHGlobal(sizeof(int));
                try {
                    while (true) {
                        srcStream.Read(buffer, buffer.Length, bytesReadPtr);
                        int bytesRead = Marshal.ReadInt32(bytesReadPtr);
                        if (bytesRead == 0) break;
                        destStream.Write(buffer, 0, bytesRead);
                    }
                }
                finally {
                    Marshal.FreeHGlobal(bytesReadPtr);
                }
            }
        }
    }
"@
    Add-Type -TypeDefinition $cSharpCode
}

function New-IsoFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,

        [Parameter(Mandatory=$true, Position=1)]
        [string[]]$SourcePath,

        [Parameter(Mandatory=$false)]
        [string]$VolumeName = "cidata",

        [Switch]$Force
    )

    process {
        $Path = [System.IO.Path]::GetFullPath($Path)
        $parentFolder = [System.IO.Path]::GetDirectoryName($Path)
        
        if (-not (Test-Path $parentFolder)) {
            New-Item -ItemType Directory -Path $parentFolder -Force | Out-Null
        }

        if (Test-Path $Path) {
            if ($Force) {
                Remove-Item $Path -Force
            } else {
                Write-Error "El archivo de destino '$Path' ya existe."
                return
            }
        }

        try {
            $imageResult = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
            # 7 = Crear ISO9660 + Joliet + UDF (Compatibilidad máxima con Hyper-V, KVM y VMware)
            $imageResult.FileSystemsToCreate = 7 
            $imageResult.VolumeName = $VolumeName
        } catch {
            Write-Error "No se pudieron cargar las interfaces COM de IMAPI2."
            return
        }

        foreach ($element in $SourcePath) {
            $element = [System.IO.Path]::GetFullPath($element)
            if (Test-Path $element) {
                if ([System.IO.Directory]::Exists($element)) {
                    # CAMBIO CLAVE: Cambiado a $false para volcar el CONTENIDO en la raíz de la ISO
                    $imageResult.Root.AddTree($element, $false) 
                } else {
                    $imageResult.Root.AddFile($element, [System.IO.Path]::GetFileName($element))
                }
            } else {
                Write-Warning "El origen '$element' no existe."
            }
        }

        try {
            Write-Progress -Activity "Generando ISO Cloud-Init" -Status "Indexando metadatos..."
            $isoData = $imageResult.CreateResultImage()
            
            Write-Progress -Activity "Generando ISO Cloud-Init" -Status "Escribiendo cidata en: $Path"
            [ISOFileStreamHelper]::WriteStreamToFile($isoData.ImageStream, $Path)
            
            Write-Host "ISO generada con éxito en: $Path" -ForegroundColor Green
            Write-Host "Estructura raíz correcta para Cloud-Init detectada con etiqueta de volumen: $VolumeName" -ForegroundColor Cyan
        } catch {
            Write-Error "Error crítico al escribir el archivo ISO: $_"
        }
    }
}
