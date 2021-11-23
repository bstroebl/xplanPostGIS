-- Bevor diese Datei offiziell wird, wird in jedem Einzelfall geprüft werden, ob die Änderungen tatsächlich umgesetzt wurden und ob weitere Punkte (z.B. Datenübernahmen) zu beachten sind

-- aus CR zu Version 5.3
-- aus CR-011
--"BP_Bebauung"."BP_BaugebietsTeilFlaeche" und "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" Konformitätsregel neu vorhanden?

-- aus CR-013: zwei Attribute als evtl. wegfalend gekennzeichnet
ALTER TABLE "XP_Basisobjekte"."XP_ExterneReferenz" DROP COLUMN "georefMimeType";
ALTER TABLE "XP_Basisobjekte"."XP_ExterneReferenz" DROP COLUMN "informationssystemURL";
