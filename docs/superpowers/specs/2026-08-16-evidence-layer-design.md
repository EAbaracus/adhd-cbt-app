# Evidence Layer — Design Spec

> Repo: `adhd-cbt-app` · Date: 2026-08-16 · Status: APPROVED (Approach 1, sections 1–5 user-approved)
> Scope: clinical claim → citation → source metadata kanıt izi + içerik zenginleştirme (A+C). B (yeni modaliteler) MVP dışı.

## 1. Goal

Mevcut 13 seansın klinik içeriğini kanıt izine bağlamak ve yeni içerikte her klinik iddiayı canonical bir kaynak registry'sine zincirlemek. Amaç: bibliography değil, denetlenebilir kanıt izi — clinician audit, içerik review ve güncelleme işini kolaylaştırmak.

**Hedef mimari:** `clinical claim → session/content element → citation → source metadata`

## 2. Locked Decisions

| # | Karar |
|---|---|
| 1 | Yaklaşım **1**: `checkpoint.evidence[]` + `content/sources/<source-id>.json` |
| 2 | Mevcut **13 seansın metnine dokunulmayacak** — zenginleştirme yalnızca yeni `read-evidence-*` checkpoint'leri ekler |
| 3 | `evidence` yalnızca **yeni içerikte**; mevcut checkpoint'lere geriye dönük işaretçi YOK |
| 4 | `evidence.source` yalnızca canonical `content/sources/` registry'sine referans verir |
| 5 | Her kaynak **tek JSON dosyası**; duplicate id validator tarafından reddedilir |
| 6 | `claim.en` + `claim.tr` checkpoint içinde; iddia ve kaynak aynı review bağlamında |
| 7 | **Positional/paragraph-index referans yok** |
| 8 | `sources/` build bundle'a girer, manifest'e girer |
| 9 | Safren/JAMA misattribution dahil tüm kaynaklar canonical registry'de **düzeltilmiş tek gerçek** |
| 10 | Validator: schema doğrulaması + source resolution + bibliyografik invariant'lar |
| 11 | **Faz ayrımı**: source-registry düzeltmesi ≠ içerik ekleme (ayrı commit'ler, ayrı gate'ler) |
| 12 | Bibliyografik invariant: journal-type → `doi` **veya** `pmid` (en az biri; ikisi serbest); book-type → `isbn` zorunlu |
| 13 | `evidence` taşıyan checkpoint id'leri `^read-evidence-` pattern'ine uymalı (convention invariant) |
| 14 | MVP'de cite edilen kaynaklar: yalnızca içeriği doğrulanabilir olanlar. Blocked kaynaklar registry'de `blocked_404` ile durur, içerik iddiası taşımaz |
| 15 | App: minimal footnote render (üst-indeks işaretçisi + kaynak kartı). Anti-engagement: modal yok, tert-ary ton |

## 3. Architecture

```
content/
├─ sources/                    # NEW — canonical source registry (10 files)
│  ├─ <source-id>.json         #   one file per source
├─ schema/
│  ├─ source.schema.json       # NEW
│  └─ session.schema.json      # + evidence alanı (Faz 2)
├─ sessions/                   # 13 dosya — Faz 1'de DOKUNULMAZ; Faz 2'de yalnızca ekleme
└─ tools/
   ├─ validate.py              # + source schema, bibliyografik invariant, evidence resolution
   └─ build.py                 # + sources/ bundle, VERSION 0.4.0, SCHEMA_VERSION 1.1.0
```

Veri akışı: `sources/<id>.json` (bibliyografik gerçek) ← `evidence.source` (checkpoint'ten referans) → `claim {en,tr}` (checkpoint içinde) → UI'da üst-indeks işaretçisi → dokununca kaynak kartı.

## 4. Source Registry (`source.schema.json`)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://adhdapp.local/schema/source.schema.json",
  "type": "object",
  "additionalProperties": false,
  "required": ["id", "author", "year", "title", "publication",
               "source_type", "access_status", "evidence_role"],
  "properties": {
    "id":            {"type": "string", "pattern": "^[a-z0-9-]+$"},
    "author":        {"type": "string", "minLength": 1},
    "year":          {"type": "integer", "minimum": 1900},
    "title":         {"type": "string", "minLength": 1},
    "publication":   {"type": "string", "minLength": 1},
    "doi":           {"type": "string", "pattern": "^10\\.\\d{4,9}/\\S+$"},
    "pmid":          {"type": "string", "pattern": "^\\d{5,9}$"},
    "isbn":          {"type": "string", "pattern": "^(97[89])?\\d{9}[\\dX]$"},
    "source_type":   {"enum": ["clinical_manual", "handbook", "patient_workbook",
                               "rct", "literature_review", "meta_analysis",
                               "pilot_study", "school_intervention_guide", "other"]},
    "access_status": {"enum": ["verified_accessible", "paywalled", "blocked_404", "unverified"]},
    "evidence_role": {"enum": ["foundational_framework", "efficacy_evidence",
                               "mechanism", "assessment_reference",
                               "contextual_background", "population_extension"]},
    "note":          {"type": "string"}
  }
}
```

**Bibliyografik invariant'lar (validator):**
- `id` == dosya adı (stem) — orphan/mismatched dosya reddedilir.
- journal-type (`rct`, `literature_review`, `meta_analysis`, `pilot_study`) → `doi` veya `pmid` en az biri; varsa her biri format-valid; ikisi birlikte serbest.
- book-type (`clinical_manual`, `handbook`, `patient_workbook`, `school_intervention_guide`) → `isbn` zorunlu.
- Duplicate `id` → red.

**id kuralı:** `author-lastname-yyyy[-descriptor]` (ör. `ramsay-rostain-2015`, `safren-2010-cbt-rct`). `year` alanı kullanıcının bibliyografik atfıyla hizalıdır; basım yılı farkı `note`'ta kaydedilir.

### Registry kataloğu (10 kaynak, 22 listeden dedupe)

| id | Kaynak | source_type | access_status | evidence_role | Identifier durumu |
|---|---|---|---|---|---|
| `ramsay-rostain-2015` | Ramsay & Rostain, CBT for Adult ADHD (2nd ed), Routledge | clinical_manual | verified_accessible (T&F TOC + abstract) | foundational_framework | ISBN 9781135072186 (2nd ed, Google Books'da doğrulandı); basım 2014, atıf 2015 (note) |
| `barkley-2015` | Barkley (Ed.), ADHD: A Handbook for Diagnosis and Treatment (4th ed), Guilford | handbook | verified_accessible (Guilford) | mechanism | ISBN 9781462517725 (hardcover, Guilford'da doğrulandı) |
| `safren-2010-cbt-rct` | Safren et al., JAMA 304(8):875-880 | rct | verified_accessible (PubMed/JAMA tam metin) | efficacy_evidence | **PMID 20736471 / DOI 10.1001/jama.2010.1192 — DOĞRULANDI; misattribution düzeltmesi note'unda** |
| `knouse-safren-2010` | Knouse & Safren, Psychiatr Clin North Am 33(3):497-509 | literature_review | blocked_404 | contextual_background | identifier **uygulamada doğrulanacak** (Crossref/PubMed) |
| `sprich-2016-adolescent` | Sprich et al., J Clin Psychiatry 77(11):1449-1455 | rct | blocked_404 | population_extension | identifier **uygulamada doğrulanacak** |
| `solanto-2008-mct` | Solanto et al., J Atten Disord 11(6):728-736 | pilot_study | verified_accessible (SAGE abstract) | efficacy_evidence | DOI 10.1177/1087054707305100 — DOĞRULANDI |
| `mitchell-2013-mindfulness` | Mitchell et al., J Atten Disord 17(2):110-119 | pilot_study | blocked_404 | contextual_background | identifier **uygulamada doğrulanacak** (verilen DOI SAGE'de bulunamadı) |
| `antshel-barkley-2020` | Antshel & Barkley, Child Adolesc Psychiatr Clin N Am 29(3) | literature_review | blocked_404 | contextual_background | identifier **uygulamada doğrulanacak** |
| `kendall-braswell-1993` | Kendall & Braswell, CBT for Impulsive Children (2nd ed), Guilford | clinical_manual | blocked_404 | foundational_framework | ISBN 9780898620138 (kullanıcı URL'si) |
| `dupaul-stoner-2016` | DuPaul & Stoner, ADHD in the Schools (3rd ed), Guilford | school_intervention_guide | verified_accessible (Guilford) | assessment_reference | ISBN 9781462526000 (paperback, Guilford'da doğrulandı) |

**Doğrulanamayan identifier'lar (knouse-safren, sprich, mitchell, antshel):** registry'ye `unverified`/`blocked_404` ile girer; Faz 1'de Crossref/PubMed üzerinden çözülür. Çözülemeyen kayıt `note` ile işaretlenir ve MVP'de cite edilmez. LOW-confidence → unresolved (kullanıcı standardı).

**Safren misattribution notu** (`note` alanı): Kullanıcı listesindeki 186352 URL'si bir MMWR makalesine (reçeteli ilaç ED başvuruları) çözülüyordu — Safren RCT'si değil. Canonical kayıt PMID 20736471 / DOI 10.1001/jama.2010.1192'dir; [4]/[8]/[15]/[21] girdileri bu tek kayda dedupe edilir.

## 5. Checkpoint `evidence` Uzantısı (`session.schema.json`, Faz 2)

Checkpoint `$defs`'ine opsiyonel alan:

```json
"evidence": {
  "type": "array",
  "minItems": 1,
  "items": {
    "type": "object",
    "additionalProperties": false,
    "required": ["source", "claim"],
    "properties": {
      "source": {"type": "string", "pattern": "^[a-z0-9-]+$"},
      "claim":  {"$ref": "#/$defs/localized"}
    }
  }
}
```

- Mevcut `localized` $defs'i yeniden kullanılır (en zorunlu, tr opsiyonel — pratikte her claim iki dilde).
- Positional referans şemada imkânsız (karar #7).
- **Convention invariant:** `evidence` taşıyan checkpoint id'si `^read-evidence-` pattern'ine uymalı (karar #13).
- Validator: `evidence.source` → registry'de çözülmeli.

## 6. Zenginleştirme Kapsamı (Faz 2 — 6 yeni checkpoint)

Her zenginleştirilmiş seansa yeni `read-evidence-*` checkpoint'i eklenir; mevcut checkpoint'lerin `content` dizileri DEĞİŞMEZ (diff yalnızca eklenen düğümleri gösterir).

| Seans | Checkpoint id | Claim (EN) | Claim (TR) | Kaynak |
|---|---|---|---|---|
| 01 | `read-evidence-combined` | "For adults whose ADHD symptoms persist despite medication, adding structured CBT skills training can further reduce symptoms compared with relaxation and educational support." | "İlaç tedavisine rağmen DEHB belirtileri süren yetişkinlerde yapılandırılmış BDT beceri eğitiminin eklenmesi, gevşeme ve eğitim desteğine kıyasla belirtileri daha fazla azaltabilir." | `safren-2010-cbt-rct` |
| 01 | `read-evidence-biology` | "ADHD affects core domains of attention, impulsivity, and activity regulation, with executive-function and emotional-regulation difficulties also relevant to clinical impairment." | "DEHB dikkat, dürtüsellik ve hareketlilik düzenlemesi gibi çekirdek alanları etkiler; yürütücü işlev ve duygusal düzenleme güçlükleri de klinik işlevsellikle ilişkilidir." | `barkley-2015` |
| 04 | `read-evidence-mct` | "A group program focused on time management, organization, and planning showed significant pre-to-post improvement in inattention and executive-function measures in a small open study." | "Zaman yönetimi, organizasyon ve planlama becerilerine odaklanan bir grup programı, küçük bir açık çalışmada dikkatsizlik ve yürütücü işlev ölçümlerinde öncesine göre anlamlı iyileşme gösterdi." | `solanto-2008-mct` |
| 08 | `read-evidence-ef` | "Executive-function difficulties (planning, working memory, self-regulation) are central to ADHD's clinical picture; skills training targets these areas." | "Yürütücü işlev güçlükleri (planlama, çalışma belleği, öz-düzenleme) DEHB'nin klinik tablosunun merkezindedir; beceri eğitimi bu alanları hedefler." | `barkley-2015` |
| 12 | `read-evidence-implementation` | "Adults with ADHD often know what to do but struggle to carry it out; treatment emphasizes implementation strategies that make follow-through easier." | "DEHB'li yetişkinler çoğu zaman ne yapacağını bilir ama uygulamakta zorlanır; tedavi, uygulamayı kolaylaştıran stratejilere önem verir." | `ramsay-rostain-2015` |
| 13 | `read-evidence-maintenance` | (1) "Follow-up and maintenance are part of the clinical treatment protocol." / (2) "In the trial, CBT responders maintained their gains at 6 and 12 months." | (1) "İzlem ve bakım, klinik tedavi protokolünün parçasıdır." / (2) "Çalışmada BDT yanıt verenler kazanımlarını 6 ve 12 ayda korudu." | `ramsay-rostain-2015` + `safren-2010-cbt-rct` (iki ayrı evidence girişi) |

**Kapsam dışı (bilinçli):** 05 problem-solving ve 06 papers için kaynak yok — doğrudan ve doğrulanabilir eşleşme olmayan modüle, görüntü uğruna citation eklenmez (scope-control). B (yeni modaliteler: mindfulness, MCT-modülü, okul müdahaleleri) MVP dışı.

## 7. Validator / Build / Test Değişiklikleri

**`validate.py`** (ekler; mevcut invariant'lar değişmez):
1. `sources/*.json` → `source.schema.json` doğrulaması.
2. `id` == filename stem.
3. Bibliyografik invariant'lar (§4).
4. Evidence resolution: her checkpoint'in her `evidence.source`'u registry'de çözülür.
5. Convention invariant: evidence taşıyan checkpoint id `^read-evidence-`.

**`build.py`**: `BUNDLE_DIRS += ("sources",)`; `VERSION = "0.4.0"`; `SCHEMA_VERSION = "1.1.0"`.

**Testler** (`test_content.py` + yeni dosyalar):
- Kaynak kataloğu: 10 beklenen id eksiksiz (`test_sources_catalog_complete`).
- Bibliyografik invariant'lar: journal-type doi-or-pmid; book-type isbn; format hataları yakalanır.
- `id`-stem mismatch reddedilir.
- Evidence resolution: bilinmeyen `evidence.source` reddedilir.
- Convention: evidence'lı checkpoint id pattern'i.
- Bundle: `len(files) == 13 + 8 + 2 + len(sources)` (dinamik).

**App (minimal, Faz 2):** `content_runtime` reading checkpoint'lerinde `evidence` varsa üst-indeks işaretçisi (¹²³) render eder; dokununca kaynak kartı (author, year, title, publication). Anti-engagement: tert-ary ton, modal yok, form/durum katmanına dokunulmaz.

## 8. Testing Strategy

- **Faz 1:** registry invariant testleri (catalog completeness, bibliyografik, id-stem, format). `env -u PYTHONPATH ./.venv/Scripts/python.exe -m pytest tests -q` yeşil; `tools/validate.py` exit 0; `tools/build.py` manifest'te sources.
- **Faz 2:** evidence resolution + convention + bundle count; Flutter tarafı widget testi (footnote işaretçisi render, kaynak kartı açılır).
- Faz gate: Faz 1 yeşil commit olmadan Faz 2 başlamaz.

## 9. Phasing

**Faz 1 — Registry düzeltmesi (içerik dosyalarına SIFIR dokunuş):**
- `sources/` (10 dosya, identifier'ları Crossref/PubMed'de doğrulanır) + `source.schema.json` + validator ekleri + testler + build güncellemesi.
- `sessions/*.json` hiç değişmez; git diff yalnızca `sources/`, `schema/`, `tools/`, `tests/` gösterir.
- Bağımsız commit + tam test run.

**Faz 2 — İçerik zenginleştirme:**
- `session.schema.json`'a `evidence` + 6 `read-evidence-*` checkpoint (kilitli claim wording'leri, EN+TR) + evidence resolution testleri + app footnote rendering.
- Bağımsız commit + tam test run (content + backend + app).

## 10. Open Items

1. Doğrulanamayan identifier'lar (knouse-safren, sprich, mitchell, antshel) — Faz 1'de Crossref/PubMed çözümü; çözülemeyenler `note` ile işaretlenir, cite edilmez.
2. `ramsay-rostain-2015` yıl alanı: kullanıcı atfı 2015 (2nd ed basımı 2014-09-25). `year=2015` kaydedilir, note'a basım farkı yazılır.
3. App footnote kartı kopyası (EN/TR) — Faz 2'de AppStrings üzerinden.
