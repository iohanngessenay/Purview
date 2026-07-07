# ============================================================
#  Sensitivity Labels - Multi-Language Configuration
#  Supported languages: en-US, fr-FR, de-DE
# ============================================================

# --- Languages ---
$Languages = @("en-US", "fr-FR", "de-DE")

# ============================================================
#  IDENTITY CONFIGURATION
#  Set the Identity value for each label exactly as it appears
#  in Microsoft Purview (display name, GUID, or immutable ID).
# ============================================================
$LabelIdentities = [ordered]@{
    Public                       = "Public"
    General                      = "General"
    Confidential                 = "Confidential"
    Confidential_Standard        = "Confidential\Standard"
    Confidential_Watermark       = "Confidential\Watermark"
    Confidential_Encrypted       = "Confidential\Encrypted"
    HighlyConfidential           = "Highly Confidential"
    HighlyConfidential_Standard  = "Highly Confidential\Standard"
    HighlyConfidential_Watermark = "Highly Confidential\Watermark"
    HighlyConfidential_Encrypted = "Highly Confidential\Encrypted"
    Personal                     = "Personal"
}

# ============================================================
#  TRANSLATION TABLE
#  Each entry contains DisplayNames and Tooltips arrays
#  in the same order as $Languages above: en-US, fr-FR, de-DE
# ============================================================
$LabelTranslations = @{

    Public = @{
        DisplayNames = @(
            "Public",
            "Public",
            "Öffentlich"
        )
        Tooltips = @(
            "Non-business data, published for public consumption. No restrictions apply.",
            "Données non professionnelles publiées pour le grand public. Aucune restriction.",
            "Nicht geschäftliche Daten zur öffentlichen Nutzung. Keine Einschränkungen."
        )
    }

    General = @{
        DisplayNames = @(
            "General",
            "Général",
            "Allgemein"
        )
        Tooltips = @(
            "Business data intended for internal use. Not sensitive, but should not be shared publicly.",
            "Données professionnelles à usage interne. Pas sensibles, mais ne doivent pas être partagées publiquement.",
            "Geschäftsdaten für den internen Gebrauch. Nicht sensibel, aber nicht für die Öffentlichkeit bestimmt."
        )
    }

    Confidential = @{
        DisplayNames = @(
            "Confidential",
            "Confidentiel",
            "Vertraulich"
        )
        Tooltips = @(
            "Sensitive business data. Sharing outside the organization must be approved.",
            "Données professionnelles sensibles. Le partage hors de l'organisation doit être approuvé.",
            "Sensible Geschäftsdaten. Die Weitergabe außerhalb der Organisation muss genehmigt werden."
        )
    }

    Confidential_Standard = @{
        DisplayNames = @(
            "Confidential \ Standard",
            "Confidentiel \ Standard",
            "Vertraulich \ Standard"
        )
        Tooltips = @(
            "Confidential data for standard internal use. Access restricted to authorized personnel.",
            "Données confidentielles pour usage interne standard. Accès limité au personnel autorisé.",
            "Vertrauliche Daten für den internen Standardgebrauch. Zugang nur für autorisiertes Personal."
        )
    }

    Confidential_Watermark = @{
        DisplayNames = @(
            "Confidential \ Watermark",
            "Confidentiel \ Filigrane",
            "Vertraulich \ Wasserzeichen"
        )
        Tooltips = @(
            "Confidential data protected with a watermark. Do not distribute without authorization.",
            "Données confidentielles protégées par un filigrane. Ne pas distribuer sans autorisation.",
            "Vertrauliche Daten mit Wasserzeichen geschützt. Keine Weitergabe ohne Genehmigung."
        )
    }

    Confidential_Encrypted = @{
        DisplayNames = @(
            "Confidential \ Encrypted",
            "Confidentiel \ Chiffré",
            "Vertraulich \ Verschlüsselt"
        )
        Tooltips = @(
            "Confidential data that is encrypted. Only authorized recipients can access the content.",
            "Données confidentielles chiffrées. Seuls les destinataires autorisés peuvent accéder au contenu.",
            "Vertrauliche Daten, die verschlüsselt sind. Nur autorisierte Empfänger können auf den Inhalt zugreifen."
        )
    }

    HighlyConfidential = @{
        DisplayNames = @(
            "Highly Confidential",
            "Hautement Confidentiel",
            "Streng Vertraulich"
        )
        Tooltips = @(
            "Highly sensitive business data. Unauthorized disclosure would cause serious damage to the organization.",
            "Données professionnelles hautement sensibles. Une divulgation non autorisée causerait de graves préjudices.",
            "Hochsensible Geschäftsdaten. Eine unbefugte Offenlegung würde der Organisation erheblichen Schaden zufügen."
        )
    }

    HighlyConfidential_Standard = @{
        DisplayNames = @(
            "Highly Confidential \ Standard",
            "Hautement Confidentiel \ Standard",
            "Streng Vertraulich \ Standard"
        )
        Tooltips = @(
            "Highly confidential data for standard access. Strictly limited to authorized individuals.",
            "Données hautement confidentielles pour accès standard. Strictement limité aux personnes autorisées.",
            "Streng vertrauliche Daten für den Standardzugang. Ausschließlich auf autorisierte Personen beschränkt."
        )
    }

    HighlyConfidential_Watermark = @{
        DisplayNames = @(
            "Highly Confidential \ Watermark",
            "Hautement Confidentiel \ Filigrane",
            "Streng Vertraulich \ Wasserzeichen"
        )
        Tooltips = @(
            "Highly confidential data protected with a watermark. Strictly prohibited from redistribution.",
            "Données hautement confidentielles protégées par filigrane. Redistribution strictement interdite.",
            "Streng vertrauliche Daten mit Wasserzeichen. Weitergabe ist streng verboten."
        )
    }

    HighlyConfidential_Encrypted = @{
        DisplayNames = @(
            "Highly Confidential \ Encrypted",
            "Hautement Confidentiel \ Chiffré",
            "Streng Vertraulich \ Verschlüsselt"
        )
        Tooltips = @(
            "Highly confidential data that is encrypted. Accessible only to explicitly authorized recipients.",
            "Données hautement confidentielles chiffrées. Accessibles uniquement aux destinataires explicitement autorisés.",
            "Streng vertrauliche Daten, die verschlüsselt sind. Nur für ausdrücklich autorisierte Empfänger zugänglich."
        )
    }

    Personal = @{
        DisplayNames = @(
            "Personal",
            "Personnel",
            "Persönlich"
        )
        Tooltips = @(
            "Personal, non-business data. Not subject to corporate governance policies.",
            "Données personnelles, non professionnelles. Non soumises aux politiques de gouvernance d'entreprise.",
            "Persönliche, nicht geschäftliche Daten. Unterliegen nicht den Unternehmensrichtlinien."
        )
    }
}

# ============================================================
#  APPLY MULTI-LANGUAGE SETTINGS
# ============================================================
foreach ($key in $LabelIdentities.Keys) 
{
    $identity    = $LabelIdentities[$key]
    $translation = $LabelTranslations[$key]
    Write-Host "Configuring label: $identity" -ForegroundColor Cyan
    # Build DisplayName locale settings
    $DisplayNameLocaleSettings = [PSCustomObject]@{
        LocaleKey = 'DisplayName'
        Settings  = @(
            @{ key = $Languages[0]; Value = $translation.DisplayNames[0] },
            @{ key = $Languages[1]; Value = $translation.DisplayNames[1] },
            @{ key = $Languages[2]; Value = $translation.DisplayNames[2] }
        )
    }
    # Build Tooltip locale settings
    $TooltipLocaleSettings = [PSCustomObject]@{
        LocaleKey = 'Tooltip'
        Settings  = @(
            @{ key = $Languages[0]; Value = $translation.Tooltips[0] },
            @{ key = $Languages[1]; Value = $translation.Tooltips[1] },
            @{ key = $Languages[2]; Value = $translation.Tooltips[2] }
        )
    }

    Set-Label -Identity $identity -LocaleSettings `
        (ConvertTo-Json $DisplayNameLocaleSettings -Depth 3 -Compress),
        (ConvertTo-Json $TooltipLocaleSettings     -Depth 3 -Compress)

    Write-Host "  Done: $identity" -ForegroundColor Green
}
Write-Host "`nAll sensitivity labels updated successfully." -ForegroundColor Yellow
