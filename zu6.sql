-- Bevor diese Datei offiziell wird, wird in jedem Einzelfall geprüft werden, ob die Änderungen tatsächlich umgesetzt wurden und ob weitere Punkte (z.B. Datenübernahmen) zu beachten sind

-- aus CR zu Version 5.3
-- aus CR-011
--"BP_Bebauung"."BP_BaugebietsTeilFlaeche" und "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" Konformitätsregel neu vorhanden?

-- aus CR-013: zwei Attribute als evtl. wegfallend gekennzeichnet
ALTER TABLE "XP_Basisobjekte"."XP_ExterneReferenz" DROP COLUMN "georefMimeType";
ALTER TABLE "XP_Basisobjekte"."XP_ExterneReferenz" DROP COLUMN "informationssystemURL";

--aus CR 026: ein Attribut als evtl. wegfallend gekennzeichnet 
ALTER TABLE "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon" DROP COLUMN "index";

-- aus CR 032 XP_Objekt.gehoertzuBereich wird Pflichtattribut
-- Realisierung durch einen AFTER-INSERT-Trigger. Soll das überhaupt realisiert werden? Was passiert, wenn kein Bereich vorhanden ist? Wird dann das XP_Objekt wieder gelöscht? Und wenn Bereiche vorhanden sind, welcher soll dann genommen werden? Die Konformitätsregel sollte eher über QGIS realisiert werden. 
