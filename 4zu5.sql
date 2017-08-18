-- Änderung CR-001
-- lässt sich in der DB nicht abbilden

-- Änderung CR-002
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';

-- Änderung CR-003
ALTER "XP_Raster"."XP_RasterplanAenderung" RENAME besonderheiten TO besonderheit;
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."besonderheit" IS 'Besonderheit der Änderung';

-- Änderung CR-004
-- war bereits implementiert

-- Änderung CR-006
ALTER TABLE "XP_Basisobjekte"."XP_Plan" DROP COLUMN "xPlanGMLVersion";

-- Änderung CR-007
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertNachrichtlichZuBereich" RENAME TO "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" RENAME "gehoertNachrichtlichZuBereich" TO "gehoertZuBereich";
ALTER TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" RENAME CONSTRAINT "gehoertNachrichtlichZuBereich_pkey" TO "gehoertZuBereich_pkey";
COMMENT ON TABLE "XP_Basisobjekte"."XP_Objekt_gehoertZuBereich" IS 'Verweis auf den Bereich, zu dem der Planinhalt gehört.';
-- für weitere Änderungen warten auf Antwort Dr. Brenner
