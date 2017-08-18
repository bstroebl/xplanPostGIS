-- Änderung CR-001
-- lässt sich in der DB nicht abbilden

-- Änderung CR-002
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."art" IS '"Art" gibt den Namen des Attributs an, das mit dem Präsentationsobjekt dargestellt werden soll.
Die Attributart "Art" darf im Regelfall nur bei "Freien Präsentationsobjekten" (dientZurDarstellungVon = NULL) nicht belegt sein.';

-- Änderung CR-003
ALTER "XP_Raster"."XP_RasterplanAenderung" RENAME besonderheiten TO besonderheit;
COMMENT ON COLUMN  "XP_Raster"."XP_RasterplanAenderung"."besonderheit" IS 'Besonderheit der Änderung';
