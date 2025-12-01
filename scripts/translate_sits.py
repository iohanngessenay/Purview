"""
translate_sits.py
Translates SIT term files to different languages using Azure OpenAI or similar API
"""

import os
import sys
from pathlib import Path
from typing import Dict, List
import time

# Translation mappings - you can use Azure Translator API, OpenAI, or other services
# For now, I'll create a script that uses direct mappings and common translations

TRANSLATIONS = {
    "fr": {
        # Common HR/Legal terms
        "applicant": "candidat",
        "recruiting": "recrutement",
        "recruitment": "recrutement",
        "candidate": "candidat",
        "resume": "CV",
        "curriculum vitae": "curriculum vitae",
        "cover letter": "lettre de motivation",
        "interview": "entretien",
        "job": "emploi",
        "position": "poste",
        "hiring": "embauche",
        "employee": "employé",
        "staff": "personnel",
        "personnel": "personnel",
        "contract": "contrat",
        "agreement": "accord",
        "salary": "salaire",
        "compensation": "rémunération",
        "wage": "salaire",
        "payment": "paiement",
        "payroll": "paie",
        "banking": "bancaire",
        "bank": "banque",
        "account": "compte",
        "IBAN": "IBAN",
        "medical": "médical",
        "health": "santé",
        "insurance": "assurance",
        "performance": "performance",
        "review": "évaluation",
        "evaluation": "évaluation",
        "training": "formation",
        "certification": "certification",
        "emergency": "urgence",
        "contact": "contact",
        "passport": "passeport",
        "identification": "identification",
        "ID": "pièce d'identité",
        "expense": "dépense",
        "reimbursement": "remboursement",
        "invoice": "facture",
        "disciplinary": "disciplinaire",
        "legal": "juridique",
        "confidential": "confidentiel",
        "client": "client",
        "privileged": "privilégié",
        "attorney": "avocat",
        "lawyer": "avocat",
        "compliance": "conformité",
        "investigation": "enquête",
        "litigation": "contentieux",
        "case": "affaire",
        "court": "tribunal",
        "patent": "brevet",
        "intellectual property": "propriété intellectuelle",
        "trademark": "marque",
        "merger": "fusion",
        "acquisition": "acquisition",
        "NDA": "accord de confidentialité",
        "non-disclosure": "non-divulgation",
        "regulatory": "réglementaire",
        "filing": "dépôt",
        "submission": "soumission",
        "board": "conseil d'administration",
        "corporate governance": "gouvernance d'entreprise",
        "whistleblower": "lanceur d'alerte",
        "sanction": "sanction",
        "export control": "contrôle des exportations",
        "data processing": "traitement des données",
        "DPA": "accord de traitement des données",
        "opinion": "avis",
        "counsel": "conseil",
        "memorandum": "mémorandum",
    },
    "es": {
        # Common HR/Legal terms in Spanish
        "applicant": "solicitante",
        "recruiting": "reclutamiento",
        "recruitment": "reclutamiento",
        "candidate": "candidato",
        "resume": "currículum",
        "curriculum vitae": "currículum vitae",
        "cover letter": "carta de presentación",
        "interview": "entrevista",
        "job": "empleo",
        "position": "puesto",
        "hiring": "contratación",
        "employee": "empleado",
        "staff": "personal",
        "personnel": "personal",
        "contract": "contrato",
        "agreement": "acuerdo",
        "salary": "salario",
        "compensation": "compensación",
        "wage": "salario",
        "payment": "pago",
        "payroll": "nómina",
        "banking": "bancario",
        "bank": "banco",
        "account": "cuenta",
        "IBAN": "IBAN",
        "medical": "médico",
        "health": "salud",
        "insurance": "seguro",
        "performance": "desempeño",
        "review": "evaluación",
        "evaluation": "evaluación",
        "training": "capacitación",
        "certification": "certificación",
        "emergency": "emergencia",
        "contact": "contacto",
        "passport": "pasaporte",
        "identification": "identificación",
        "ID": "documento de identidad",
        "expense": "gasto",
        "reimbursement": "reembolso",
        "invoice": "factura",
        "disciplinary": "disciplinario",
        "legal": "legal",
        "confidential": "confidencial",
        "client": "cliente",
        "privileged": "privilegiado",
        "attorney": "abogado",
        "lawyer": "abogado",
        "compliance": "cumplimiento",
        "investigation": "investigación",
        "litigation": "litigio",
        "case": "caso",
        "court": "tribunal",
        "patent": "patente",
        "intellectual property": "propiedad intelectual",
        "trademark": "marca registrada",
        "merger": "fusión",
        "acquisition": "adquisición",
        "NDA": "acuerdo de confidencialidad",
        "non-disclosure": "no divulgación",
        "regulatory": "regulatorio",
        "filing": "presentación",
        "submission": "presentación",
        "board": "junta directiva",
        "corporate governance": "gobierno corporativo",
        "whistleblower": "denunciante",
        "sanction": "sanción",
        "export control": "control de exportaciones",
        "data processing": "procesamiento de datos",
        "DPA": "acuerdo de procesamiento de datos",
        "opinion": "opinión",
        "counsel": "asesor",
        "memorandum": "memorando",
    }
}

def translate_term(term: str, target_lang: str) -> str:
    """Translate a single term to target language"""
    term_lower = term.lower().strip()
    
    if target_lang in TRANSLATIONS:
        # Try exact match first
        if term_lower in TRANSLATIONS[target_lang]:
            translated = TRANSLATIONS[target_lang][term_lower]
            # Preserve original case if it was uppercase
            if term.isupper():
                return translated.upper()
            elif term[0].isupper() if term else False:
                return translated.capitalize()
            return translated
    
    # If no translation found, return original
    return term

def translate_file(source_file: Path, target_file: Path, target_lang: str):
    """Translate a single file"""
    try:
        with open(source_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        translated_lines = []
        for line in lines:
            line = line.rstrip('\n\r')
            # Split on common delimiters but preserve them
            words = line.split()
            translated_words = [translate_term(word, target_lang) for word in words]
            translated_lines.append(' '.join(translated_words))
        
        with open(target_file, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(translated_lines))
        
        return True
    except Exception as e:
        print(f"Error translating {source_file}: {e}")
        return False

def translate_sit_folder(sit_path: Path, target_lang: str):
    """Translate all term files in a SIT folder for target language"""
    en_folder = sit_path / "en"
    target_folder = sit_path / target_lang
    
    if not en_folder.exists() or not target_folder.exists():
        return False
    
    files_to_translate = ["context.txt", "primary.txt", "regex_patterns.txt"]
    
    for filename in files_to_translate:
        source_file = en_folder / filename
        target_file = target_folder / filename
        
        if source_file.exists():
            print(f"  Translating {sit_path.name}/{target_lang}/{filename}")
            translate_file(source_file, target_file, target_lang)
    
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: python translate_sits.py <root_path> <target_lang>")
        print("Example: python translate_sits.py C:\\DEV\\Private\\Purview fr")
        sys.exit(1)
    
    root_path = Path(sys.argv[1])
    target_lang = sys.argv[2]
    
    if not root_path.exists():
        print(f"Error: Path {root_path} does not exist")
        sys.exit(1)
    
    if target_lang not in TRANSLATIONS:
        print(f"Error: Language {target_lang} not supported. Supported: {list(TRANSLATIONS.keys())}")
        sys.exit(1)
    
    print(f"Translating SITs to {target_lang}...")
    print()
    
    # Find all SIT folders (folders containing en/ and target_lang/ subdirectories)
    count = 0
    for category in ["HR", "LEGAL"]:
        category_path = root_path / category
        if not category_path.exists():
            continue
        
        for sit_folder in category_path.iterdir():
            if sit_folder.is_dir():
                if translate_sit_folder(sit_folder, target_lang):
                    count += 1
    
    print()
    print(f"Translation complete! Processed {count} SIT folders")

if __name__ == "__main__":
    main()
